from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File, Form
from sqlmodel import Session
from typing import Optional, Dict, Any
import logging
from ..services.rag_service import rag_service
from ..services.document_service import document_service
from ...routes.utils.database import get_session
from ...routes.utils.auth import get_current_active_admin, get_current_user

# Configure logging
logger = logging.getLogger(__name__)

router = APIRouter(prefix="/rag/documents", tags=["RAG Documents"])

@router.post("/upload", status_code=status.HTTP_201_CREATED)
async def upload_document_for_rag(
    file: UploadFile = File(...),
    title: str = Form(...),
    document_type: str = Form("manual"),
    machine_type: Optional[str] = Form(None),
    use_smart_chunking: bool = Form(True),
    session: Session = Depends(get_session),
    current_user: dict = Depends(get_current_active_admin)
):


    """
    Upload a document and process it through the RAG system.
    
    This endpoint:
    1. Extracts text from the uploaded file
    2. Chunks the text using smart chunking
    3. Generates embeddings for each chunk
    4. Stores vectors in Pinecone
    5. Returns processing statistics
    """
    try:
        logger.info(f"Starting RAG document upload: {file.filename}")
        
        # Validate file type
        if not file.filename.lower().endswith(('.pdf', '.txt', '.md')):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Only PDF, TXT, and MD files are supported for RAG processing"
            )
        
        # Step 1: Process the uploaded file
        logger.info(f"Processing file: {file.filename}")
        file_result = await document_service.process_upload_file(file)
        
        if not file_result.get("content"):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Failed to extract content from the uploaded file"
            )
        
        # Step 2: Process document through RAG system
        logger.info(f"Processing document through RAG system: {title}")
        rag_result = await rag_service.process_document(
            content=file_result["content"],
            title=title,
            document_type=document_type,
            machine_type=machine_type,
            use_smart_chunking=use_smart_chunking
        )
        
        # Step 3: Compile comprehensive response
        response = {
            "message": "Document successfully processed and stored in RAG system",
            "file_info": {
                "filename": file.filename,
                "size": file_result.get("size", 0),
                "text_length": file_result.get("text_length", 0),
                "metadata": file_result.get("metadata", {})
            },
            "rag_processing": rag_result,
            "status": "success"
        }
        
        logger.info(f"RAG document upload completed successfully: {title}")
        return response
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error uploading document for RAG: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to upload document for RAG processing: {str(e)}"
        )

@router.post("/query", status_code=status.HTTP_200_OK)
async def query_rag_system(
    query: str = Form(...),
    machine_type: Optional[str] = Form(None),
    chunk_type_filter: Optional[str] = Form(None),
    context_limit: int = Form(3),
    current_user: dict = Depends(get_current_user)
):
    """
    Query the RAG system to get AI responses based on uploaded documents.
    
    This endpoint:
    1. Generates embeddings for the query
    2. Searches Pinecone for relevant context
    3. Generates AI response using retrieved context
    4. Returns the response with metadata
    """
    try:
        logger.info(f"Processing RAG query: {query[:100]}...")
        
        # Generate RAG response
        rag_response = await rag_service.generate_rag_response(
            query=query,
            machine_type=machine_type,
            context_limit=context_limit
        )
        
        logger.info(f"RAG query completed successfully")
        return rag_response
        
    except Exception as e:
        logger.error(f"Error processing RAG query: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to process RAG query: {str(e)}"
        )

@router.get("/health", status_code=status.HTTP_200_OK)
async def rag_health_check():
    """
    Check the health status of the RAG system components.
    """
    try:
        health_status = rag_service.health_check()
        return health_status
        
    except Exception as e:
        logger.error(f"Error checking RAG health: {str(e)}")
        return {
            "rag_service": "error",
            "ai_service": "unknown",
            "pinecone_service": "unknown",
            "document_service": "unknown",
            "error": str(e),
            "overall_status": "error"
        }

@router.get("/stats", status_code=status.HTTP_200_OK)
async def get_rag_statistics(
    current_user: dict = Depends(get_current_user)
):
    """
    Get statistics about the RAG system and stored documents.
    """
    try:
        # This would typically query Pinecone for statistics
        # For now, return basic service status
        health_status = rag_service.health_check()
        
        return {
            "service_status": health_status,
            "message": "RAG statistics endpoint - implement Pinecone stats query for detailed metrics"
        }
        
    except Exception as e:
        logger.error(f"Error getting RAG statistics: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to get RAG statistics: {str(e)}"
        )
