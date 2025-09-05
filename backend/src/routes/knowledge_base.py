from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File, Form
from sqlmodel import Session, select
from typing import List, Optional
from datetime import datetime
import json
from ..services.document_service import document_service
from .utils.database import get_session
from ..model.models import (
    KnowledgeBaseContent, 
    Document,
    KnowledgeBaseContentCreate, KnowledgeBaseContentRead,
    ContentType
)
from .utils.auth import get_current_active_admin, get_current_user
from .utils.cloudinary_service import cloudinary_service

router = APIRouter(prefix="/knowledge-base",
 tags=["Knowledge Base"])

# Create Knowledge Base Content with File Upload
@router.post("/", response_model=KnowledgeBaseContentRead, status_code=status.HTTP_201_CREATED)
async def create_knowledge_base_content(
    content: str = Form(...),  # JSON string for KnowledgeBaseContentCreate
    file: Optional[UploadFile] = File(None),
    session: Session = Depends(get_session),
    current_user: dict = Depends(get_current_active_admin)
):
    try:
        # Parse content JSON into KnowledgeBaseContentCreate
        data = json.loads(content)
        # Ensure uploader_id is present for validation; take from current user
        try:
            user_id_val = current_user.user_id
        except Exception:
            # Fallback if dependency returns dict-like
            user_id_val = current_user.get("user_id")  # type: ignore
        data.setdefault("uploader_id", user_id_val)
        kb_create = KnowledgeBaseContentCreate(**data)

        # Validate content type vs. file/text requirements
        if kb_create.content_type in [ContentType.DOCUMENT, ContentType.VIDEO] and not file:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"File is required for content type: {kb_create.content_type}"
            )
        if kb_create.content_type == ContentType.FAQ and not kb_create.content_text:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Content text is required for FAQ content type"
            )

        external_url = None
        if file:
            file_content = await file.read()
            file_name = file.filename

            if kb_create.content_type == ContentType.VIDEO:
                upload_result = await cloudinary_service.upload_video(file_content, file_name)
            elif kb_create.content_type == ContentType.DOCUMENT:
                result = await document_service.process_upload_file(file)
                document_content = Document(
                    title=result["filename"],
                    content=result["content"],
                    document_type=kb_create.content_type,
                    machine_type=kb_create.machine_type,
                    file_path=result["file_path"]
                )
                upload_result = await cloudinary_service.upload_document(file_content, file_name)
            else:
                upload_result = await cloudinary_service.upload_image(file_content, file_name)

            external_url = upload_result["url"]

        # Create DB record
        db_content = KnowledgeBaseContent(
            **kb_create.dict(exclude={"external_url", "uploader_id"}),
            external_url=external_url,
            uploader_id=user_id_val,
            created_at=datetime.utcnow(),
            updated_at=datetime.utcnow()
        )

        session.add(db_content)
        session.commit()
        session.refresh(db_content)

        return db_content

    except json.JSONDecodeError:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid JSON format for content"
        )
    except HTTPException:
        raise
    except Exception as e:
        session.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to create knowledge base content: {str(e)}"
        )

# Get All Knowledge Base Content
@router.get("/", response_model=List[KnowledgeBaseContentRead])
async def get_knowledge_base_content(
    skip: int = 0,
    limit: int = 100,
    content_type: Optional[ContentType] = None,
    search: Optional[str] = None,
    tags: Optional[str] = None,  # JSON string
    machine_model: Optional[str] = None,
    error_code_id: Optional[int] = None,
    session: Session = Depends(get_session),
    current_user: dict = Depends(get_current_user)
):
    
    try:
        query = select(KnowledgeBaseContent)
        
        # Apply filters
        if content_type:
            query = query.where(KnowledgeBaseContent.content_type == content_type)
        
        if search:
            search_filter = (
                KnowledgeBaseContent.title.contains(search) |
                KnowledgeBaseContent.content_text.contains(search)
            )
            query = query.where(search_filter)
        
        if tags:
            try:
                tags_list = json.loads(tags)
                # Filter by tags (assuming tags is a JSON array)
                query = query.where(KnowledgeBaseContent.tags.contains(tags_list))
            except json.JSONDecodeError:
                pass
        
        if machine_model:
            query = query.where(KnowledgeBaseContent.applies_to_models.contains([machine_model]))
        
        if error_code_id:
            query = query.where(KnowledgeBaseContent.related_error_code_id == error_code_id)
        
        # Apply pagination
        query = query.offset(skip).limit(limit)
        
        # Execute query
        content_list = session.exec(query).all()
        
        return content_list
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to retrieve knowledge base content: {str(e)}"
        )

# Get Knowledge Base Content by ID
@router.get("/{kb_id}", response_model=KnowledgeBaseContentRead)
async def get_knowledge_base_content_by_id(
    kb_id: int,
    session: Session = Depends(get_session),
    current_user: dict = Depends(get_current_user)
):
   
    try:
        content = session.get(KnowledgeBaseContent, kb_id)
        
        if not content:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Knowledge base content with ID {kb_id} not found"
            )
        
        return content
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to retrieve knowledge base content: {str(e)}"
        )

# Update Knowledge Base Content
@router.put("/{kb_id}", response_model=KnowledgeBaseContentRead)
async def update_knowledge_base_content(
    kb_id: int,
    title: Optional[str] = Form(None),
    content_type: Optional[ContentType] = Form(None),
    content_text: Optional[str] = Form(None),
    tags: Optional[str] = Form(None),  # JSON string
    applies_to_models: Optional[str] = Form(None),  # JSON string
    related_error_code_id: Optional[int] = Form(None),
    file: Optional[UploadFile] = File(None),
    session: Session = Depends(get_session),
    current_user: dict = Depends(get_current_active_admin)
):
   
    try:
        # Get existing content
        db_content = session.get(KnowledgeBaseContent, kb_id)
        
        if not db_content:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Knowledge base content with ID {kb_id} not found"
            )
        
        # Extract user id and role, compatible with object or dict
        try:
            current_user_id = current_user.user_id  # type: ignore[attr-defined]
        except Exception:
            current_user_id = current_user.get("user_id")  # type: ignore[assignment]
        try:
            current_user_role = current_user.role  # type: ignore[attr-defined]
        except Exception:
            current_user_role = current_user.get("role")  # type: ignore[assignment]

        # Check if user is the uploader or has admin privileges
        if (db_content.uploader_id != current_user_id and 
            current_user_role != "admin"):
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Only the uploader or admin can update this content"
            )
        
        # Parse JSON strings if provided
        if tags is not None:
            try:
                tags_list = json.loads(tags) if tags else []
                db_content.tags = tags_list
            except json.JSONDecodeError:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Invalid JSON format for tags"
                )
        
        if applies_to_models is not None:
            try:
                models_list = json.loads(applies_to_models) if applies_to_models else []
                db_content.applies_to_models = models_list
            except json.JSONDecodeError:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Invalid JSON format for applies_to_models"
                )
        
        # Handle file replacement if provided
        if file:
            # Delete old file from Cloudinary if it exists
            if db_content.external_url:
                # Extract public_id from URL (simplified approach)
                old_file_info = await cloudinary_service.get_file_info(db_content.external_url)
                if old_file_info:
                    await cloudinary_service.delete_file(old_file_info["public_id"])
            
            # Upload new file
            file_content = await file.read()
            file_name = file.filename
            
            if db_content.content_type == ContentType.VIDEO:
                upload_result = await cloudinary_service.upload_video(file_content, file_name)
            elif db_content.content_type == ContentType.DOCUMENT:
                upload_result = await cloudinary_service.upload_document(file_content, file_name)
            else:
                upload_result = await cloudinary_service.upload_image(file_content, file_name)
            
            db_content.external_url = upload_result["url"]
        
        # Update other fields
        if title is not None:
            db_content.title = title
        if content_type is not None:
            db_content.content_type = content_type
        if content_text is not None:
            db_content.content_text = content_text
        if related_error_code_id is not None:
            db_content.related_error_code_id = related_error_code_id
        
        db_content.updated_at = datetime.utcnow()
        
        session.add(db_content)
        session.commit()
        session.refresh(db_content)
        
        return db_content
        
    except HTTPException:
        raise
    except Exception as e:
        session.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to update knowledge base content: {str(e)}"
        )

# Delete Knowledge Base Content
@router.delete("/{kb_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_knowledge_base_content(
    kb_id: int,
    session: Session = Depends(get_session),
    current_user: dict = Depends(get_current_user)
):
    try:
        # Get existing content
        db_content = session.get(KnowledgeBaseContent, kb_id)
        
        if not db_content:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Knowledge base content with ID {kb_id} not found"
            )
        
        # Extract user id and role, compatible with object or dict
        try:
            current_user_id = current_user.user_id  # type: ignore[attr-defined]
        except Exception:
            current_user_id = current_user.get("user_id")  # type: ignore[assignment]
        try:
            current_user_role = current_user.role  # type: ignore[attr-defined]
        except Exception:
            current_user_role = current_user.get("role")  # type: ignore[assignment]

        # Check if user is the uploader or has admin privileges
        if (db_content.uploader_id != current_user_id and 
            current_user_role != "admin"):
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Only the uploader or admin can delete this content"
            )
        
        # Delete file from Cloudinary if it exists
        if db_content.external_url:
            try:
                # Extract public_id from URL (simplified approach)
                old_file_info = await cloudinary_service.get_file_info(db_content.external_url)
                if old_file_info:
                    await cloudinary_service.delete_file(old_file_info["public_id"])
            except Exception as e:
                # Log error but continue with deletion
                print(f"Warning: Failed to delete file from Cloudinary: {str(e)}")
        
        # Delete from database
        session.delete(db_content)
        session.commit()
        
        return None
        
    except HTTPException:
        raise
    except Exception as e:
        session.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to delete knowledge base content: {str(e)}"
        )

# Upload File Only (for existing content)
@router.post("/{kb_id}/upload-file", response_model=KnowledgeBaseContentRead)
async def upload_file_for_content(
    kb_id: int,
    file: UploadFile = File(...),
    session: Session = Depends(get_session),
    current_user: dict = Depends(get_current_user)
):
   
    try:
        # Get existing content
        db_content = session.get(KnowledgeBaseContent, kb_id)
        
        if not db_content:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Knowledge base content with ID {kb_id} not found"
            )
        
        # Extract user id and role, compatible with object or dict
        try:
            current_user_id = current_user.user_id  # type: ignore[attr-defined]
        except Exception:
            current_user_id = current_user.get("user_id")  # type: ignore[assignment]
        try:
            current_user_role = current_user.role  # type: ignore[attr-defined]
        except Exception:
            current_user_role = current_user.get("role")  # type: ignore[assignment]

        # Check if user is the uploader or has admin privileges
        if (db_content.uploader_id != current_user_id and 
            current_user_role != "admin"):
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Only the uploader or admin can upload files for this content"
            )
        
        # Delete old file if it exists
        if db_content.external_url:
            try:
                old_file_info = await cloudinary_service.get_file_info(db_content.external_url)
                if old_file_info:
                    await cloudinary_service.delete_file(old_file_info["public_id"])
            except Exception as e:
                print(f"Warning: Failed to delete old file: {str(e)}")
        
        # Upload new file
        file_content = await file.read()
        file_name = file.filename
        
        if db_content.content_type == ContentType.VIDEO:
            upload_result = await cloudinary_service.upload_video(file_content, file_name)
        elif db_content.content_type == ContentType.DOCUMENT:
            upload_result = await cloudinary_service.upload_document(file_content, file_name)
        else:
            upload_result = await cloudinary_service.upload_image(file_content, file_name)
        
        # Update content with new file URL
        db_content.external_url = upload_result["url"]
        db_content.updated_at = datetime.utcnow()
        
        session.add(db_content)
        session.commit()
        session.refresh(db_content)
        
        return db_content
        
    except HTTPException:
        raise
    except Exception as e:
        session.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to upload file: {str(e)}"
        )

# Get Content by Content Type
@router.get("/type/{content_type}", response_model=List[KnowledgeBaseContentRead])
async def get_content_by_type(
    content_type: ContentType,
    skip: int = 0,
    limit: int = 100,
    session: Session = Depends(get_session),
    current_user: dict = Depends(get_current_user)
):
    
    try:
        query = select(KnowledgeBaseContent).where(
            KnowledgeBaseContent.content_type == content_type
        )
        
        # Apply pagination
        query = query.offset(skip).limit(limit)
        
        content_list = session.exec(query).all()
        return content_list
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to retrieve content by type: {str(e)}"
        )

# Search Content by Tags
@router.get("/search/tags", response_model=List[KnowledgeBaseContentRead])
async def search_content_by_tags(
    tags: str,  # Comma-separated tags
    session: Session = Depends(get_session),
    current_user: dict = Depends(get_current_user)
):

    try:
        tag_list = [tag.strip() for tag in tags.split(",") if tag.strip()]
        
        if not tag_list:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="At least one tag must be provided"
            )
        
        # Search for content containing any of the specified tags
        query = select(KnowledgeBaseContent).where(
            KnowledgeBaseContent.tags.contains(tag_list)
        )
        
        content_list = session.exec(query).all()
        return content_list
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to search content by tags: {str(e)}"
        )

# Get Content Statistics
@router.get("/stats/summary")
async def get_content_statistics(
    session: Session = Depends(get_session),
    current_user: dict = Depends(get_current_user)
):
    try:
        # Get total count
        total_content = session.exec(select(KnowledgeBaseContent)).all()
        total_count = len(total_content)
        
        # Count by content type
        type_counts = {}
        for content_type in ContentType:
            count = len([c for c in total_content if c.content_type == content_type])
            type_counts[content_type] = count
        
        # Count by uploader
        uploader_counts = {}
        for content in total_content:
            uploader_id = content.uploader_id
            uploader_counts[uploader_id] = uploader_counts.get(uploader_id, 0) + 1
        
        return {
            "total_content": total_count,
            "by_content_type": type_counts,
            "by_uploader": uploader_counts,
            "with_files": len([c for c in total_content if c.external_url]),
            "with_error_codes": len([c for c in total_content if c.related_error_code_id])
        }
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to retrieve content statistics: {str(e)}"
        )
