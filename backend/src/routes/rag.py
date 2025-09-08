# mst/backend/src/routes/rag.py
from fastapi import APIRouter, Depends, HTTPException, status
from sqlmodel import Session

from ..services.rag_service import rag_service
from ..services.pinecone_service import pinecone_service
from ..services.ai_service import ai_service
from .utils.database import get_session
from .utils.auth import get_current_active_admin

router = APIRouter(prefix="/rag", tags=["RAG System"])

@router.get("/health")
async def rag_health_check():
    """Check the health of the RAG system components."""
    try:
        health_info = await rag_service.health_check()
        
        # Add detailed component status
        health_info["components"] = {
            "ai_service": ai_service.is_enabled(),
            "pinecone_service": pinecone_service.is_enabled(),
            "embedding_service": True,  # Assuming it's always enabled
            "document_service": True    # Assuming it's always enabled
        }
        
        return health_info
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to check RAG health: {str(e)}"
        )

@router.get("/stats")
async def rag_statistics(admin=Depends(get_current_active_admin)):
    """Get statistics about the RAG system."""
    try:
        # This would require additional methods in the services
        # to get statistics about stored vectors, processed documents, etc.
        return {
            "status": "success",
            "message": "RAG statistics endpoint - implementation pending",
            "suggested_metrics": [
                "total_documents_processed",
                "total_vectors_stored",
                "average_query_response_time",
                "most_common_query_types"
            ]
        }
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to get RAG statistics: {str(e)}"
        )