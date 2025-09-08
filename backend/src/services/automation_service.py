# mst/backend/src/services/automation_service.py
import os
import logging
from typing import Dict, Any, Optional
from fastapi import BackgroundTasks
from sqlmodel import Session

from ..rag.services.rag_service import rag_service
from ..rag.services.document_service import document_service

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class AutomationService:
    def __init__(self):
        """Initialize automation service for background processing."""
        self._enabled = True
        logger.info("Automation Service initialized")
    
    def is_enabled(self) -> bool:
        """Check if automation service is enabled."""
        return self._enabled
    
    async def process_uploaded_file(
        self,
        file_content: bytes,
        file_name: str,
        metadata: Dict[str, Any],
        background_tasks: BackgroundTasks
    ) -> Dict[str, Any]:
        """Process uploaded file and add to RAG system in background."""
        try:
            logger.info(f"Processing uploaded file: {file_name}")
            
            # Extract text from file
            processing_result = await document_service.process_upload_file(file_content, file_name)
            
            # Prepare document metadata for RAG
            document_metadata = {
                "title": metadata.get("title", file_name),
                "document_type": metadata.get("content_type", "manual"),
                "machine_type": metadata.get("applies_to_models", ["general"]),
                "source": "knowledge_base_upload",
                "uploader_id": metadata.get("uploader_id"),
                "kb_id": metadata.get("kb_id")
            }
            
            # Add to RAG system in background
            background_tasks.add_task(
                self._add_to_rag_system,
                processing_result["content"],
                document_metadata
            )
            
            return {
                "status": "success",
                "message": "File processing started",
                "processing_result": processing_result
            }
            
        except Exception as e:
            logger.error(f"Failed to process uploaded file: {str(e)}")
            return {
                "status": "error",
                "message": f"Failed to process file: {str(e)}"
            }
    
    async def _add_to_rag_system(self, content: str, metadata: Dict[str, Any]):
        """Add document content to RAG system."""
        try:
            rag_result = await rag_service.process_document(
                content=content,
                title=metadata["title"],
                document_type=metadata["document_type"],
                machine_type=metadata["machine_type"][0] if metadata["machine_type"] else "general",
                use_smart_chunking=True
            )
            
            logger.info(f"Successfully added document to RAG system: {metadata['title']}")
            logger.debug(f"RAG processing result: {rag_result}")
            
        except Exception as e:
            logger.error(f"Failed to add document to RAG system: {str(e)}")
    
    async def reprocess_knowledge_base(self, db: Session):
        """Reprocess all knowledge base content through RAG system."""
        # This would iterate through all knowledge base content and reprocess it
        # Implementation would depend on your database model
        pass

# Create global instance
automation_service = AutomationService()