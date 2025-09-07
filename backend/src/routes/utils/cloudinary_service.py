import cloudinary
import cloudinary.uploader
import cloudinary.api
from typing import Optional, Dict, Any, List
import os
from fastapi import HTTPException, status
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class CloudinaryService:
    def __init__(self):
        """Initialize Cloudinary configuration from environment variables."""
        try:
            cloudinary.config(
                cloud_name=os.getenv("CLOUDINARY_CLOUD_NAME"),
                api_key=os.getenv("CLOUDINARY_API_KEY"),
                api_secret=os.getenv("CLOUDINARY_API_SECRET")
            )
            
            # Verify configuration
            if not all([
                os.getenv("CLOUDINARY_CLOUD_NAME"),
                os.getenv("CLOUDINARY_API_KEY"),
                os.getenv("CLOUDINARY_API_SECRET")
            ]):
                logger.warning("Cloudinary environment variables not set - service will be disabled")
                self._enabled = False
                return
                
            self._enabled = True
            logger.info("Cloudinary service initialized successfully")
                
        except Exception as e:
            logger.warning(f"Failed to initialize Cloudinary: {str(e)} - service will be disabled")
            self._enabled = False

    async def upload_file(
        self,
        file_data: bytes,
        file_name: str,
        folder: str = "knowledge_base",
        resource_type: str = "auto",
        allowed_formats: Optional[List[str]] = None,
        max_size_mb: int = 10
    ) -> Dict[str, Any]:
        if not getattr(self, '_enabled', False):
            raise HTTPException(
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                detail="Cloudinary service is not configured"
            )
        
        try:
            # Check if file is empty
            if not file_data:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Cannot upload empty file"
                )

            # Validate file size
            file_size_mb = len(file_data) / (1024 * 1024)
            if file_size_mb > max_size_mb:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=f"File size {file_size_mb:.2f}MB exceeds maximum allowed size of {max_size_mb}MB"
                )
            
            # Validate file format if specified
            if allowed_formats:
                file_extension = file_name.lower().split('.')[-1]
                if file_extension not in allowed_formats:
                    raise HTTPException(
                        status_code=status.HTTP_400_BAD_REQUEST,
                        detail=f"File format .{file_extension} not allowed. Allowed formats: {', '.join(allowed_formats)}"
                    )
            
            # Generate unique public_id
            import uuid
            unique_id = str(uuid.uuid4())
            public_id = f"{folder}/{unique_id}_{file_name}"
            
            # Upload to Cloudinary
            upload_result = cloudinary.uploader.upload(
                file_data,
                public_id=public_id,
                resource_type=resource_type,
                overwrite=True,
                invalidate=True
            )
            
            logger.info(f"Successfully uploaded file: {public_id}")
            
            return {
                "public_id": upload_result.get("public_id"),
                "url": upload_result.get("secure_url"),
                "format": upload_result.get("format"),
                "resource_type": upload_result.get("resource_type"),
                "bytes": upload_result.get("bytes"),
                "width": upload_result.get("width"),
                "height": upload_result.get("height"),
                "duration": upload_result.get("duration"),
                "created_at": upload_result.get("created_at")
            }
            
        except HTTPException:
            raise
        except Exception as e:
            logger.error(f"Failed to upload file {file_name}: {str(e)}")
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Failed to upload file: {str(e)}"
            )

    async def upload_image(
        self,
        file_data: bytes,
        file_name: str,
        folder: str = "knowledge_base/images",
        transformation: Optional[Dict[str, Any]] = None
    ) -> Dict[str, Any]:
        
        allowed_formats = ["jpg", "jpeg", "png", "gif", "webp", "bmp", "tiff"]
        
        upload_result = await self.upload_file(
            file_data=file_data,
            file_name=file_name,
            folder=folder,
            resource_type="image",
            allowed_formats=allowed_formats,
            max_size_mb=5
        )
        
        # Apply transformations if specified
        if transformation:
            try:
                transformed_url = cloudinary.CloudinaryImage(upload_result["public_id"]).build_url(
                    **transformation
                )
                upload_result["transformed_url"] = transformed_url
            except Exception as e:
                logger.warning(f"Failed to apply transformations: {str(e)}")
        
        return upload_result

    async def upload_video(
        self,
        file_data: bytes,
        file_name: str,
        folder: str = "knowledge_base/videos"
    ) -> Dict[str, Any]:
        
        allowed_formats = ["mp4", "avi", "mov", "wmv", "flv", "webm", "mkv"]
        
        return await self.upload_file(
            file_data=file_data,
            file_name=file_name,
            folder=folder,
            resource_type="video",
            allowed_formats=allowed_formats,
            max_size_mb=50
        )

    async def upload_document(
        self,
        file_data: bytes,
        file_name: str,
        folder: str = "knowledge_base/documents"
    ) -> Dict[str, Any]:
        
        allowed_formats = ["pdf", "doc", "docx", "txt", "rtf", "odt"]
        
        return await self.upload_file(
            file_data=file_data,
            file_name=file_name,
            folder=folder,
            resource_type="raw",
            allowed_formats=allowed_formats,
            max_size_mb=25
        )

    async def delete_file(self, public_id: str, resource_type: str = "auto") -> bool:
       
        try:
            result = cloudinary.uploader.destroy(public_id, resource_type=resource_type)
            
            if result.get("result") == "ok":
                logger.info(f"Successfully deleted file: {public_id}")
                return True
            else:
                logger.warning(f"Failed to delete file: {public_id}, result: {result}")
                return False
                
        except Exception as e:
            logger.error(f"Failed to delete file {public_id}: {str(e)}")
            return False

    async def get_file_info(self, public_id: str, resource_type: str = "auto") -> Optional[Dict[str, Any]]:
        
        try:
            result = cloudinary.api.resource(public_id, resource_type=resource_type)
            return result
        except cloudinary.api.NotFound:
            logger.warning(f"File not found: {public_id}")
            return None
        except Exception as e:
            logger.error(f"Failed to get file info for {public_id}: {str(e)}")
            return None

    async def list_files(
        self,
        folder: str = "knowledge_base",
        resource_type: str = "auto",
        max_results: int = 100
    ) -> List[Dict[str, Any]]:
       
        try:
            result = cloudinary.api.resources(
                type="upload",
                prefix=folder,
                resource_type=resource_type,
                max_results=max_results
            )
            
            return result.get("resources", [])
            
        except Exception as e:
            logger.error(f"Failed to list files in folder {folder}: {str(e)}")
            return []

# Create global instance - lazy loaded to avoid import-time errors
_cloudinary_service_instance = None

def get_cloudinary_service():
    """Get or create Cloudinary service instance"""
    global _cloudinary_service_instance
    if _cloudinary_service_instance is None:
        try:
            _cloudinary_service_instance = CloudinaryService()
        except Exception as e:
            logger.warning(f"Cloudinary service not available: {e}")
            _cloudinary_service_instance = None
    return _cloudinary_service_instance

# For backward compatibility
cloudinary_service = get_cloudinary_service()
