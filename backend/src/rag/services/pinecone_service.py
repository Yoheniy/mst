import os
import logging
from typing import List, Dict, Any, Optional
from pinecone import Pinecone, ServerlessSpec
from fastapi import HTTPException, status
from dotenv import load_dotenv


load_dotenv('/home/jovanijo/Desktop/mst/backend/.env')
# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class PineconeService:
    def __init__(self):
        """Initialize Pinecone client with Serverless configuration."""
        try:
            # Get Pinecone API key from environment
            api_key = os.getenv("PINECONE_API_KEY")
            index_name = os.getenv("PINECONE_INDEX_NAME", "machine-tool-kb")
            
            if not api_key:
                logger.warning("PINECONE_API_KEY not found in environment variables")
                self._enabled = False
                return
            
            # Initialize Pinecone client (Serverless)
            self.pc = Pinecone(api_key=api_key)
            
            # Get or create index
            existing_indexes = [idx.name for idx in self.pc.list_indexes()]
            if index_name not in existing_indexes:
                logger.info(f"Creating Pinecone index: {index_name}")
                self.pc.create_index(
                    name=index_name,
                    dimension=384,  # Dimension for our embedding model
                    metric="cosine",
                    spec=ServerlessSpec(
                        cloud="aws",
                        region="us-east-1"
                    )
                )
            
            self.index = self.pc.Index(index_name)
            self.index_name = index_name
            self._enabled = True
            
            logger.info(f"Pinecone service initialized with index: {index_name}")
            
        except Exception as e:
            logger.error(f"Failed to initialize Pinecone service: {str(e)}")
            self._enabled = False
    
    def is_enabled(self) -> bool:
        """Check if Pinecone service is properly configured."""
        return self._enabled
    
    async def upsert_vectors(
        self, 
        vectors: List[Dict[str, Any]], 
        namespace: str = "default"
    ) -> bool:
        """
        Upsert vectors to Pinecone index.
        
        Args:
            vectors: List of vectors with 'id', 'values', and 'metadata'
            namespace: Namespace for the vectors
        
        Returns:
            True if successful, False otherwise
        """
        if not self._enabled:
            raise HTTPException(
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                detail="Pinecone service is not configured"
            )
        
        try:
            self.index.upsert(vectors=vectors, namespace=namespace)
            logger.info(f"Successfully upserted {len(vectors)} vectors to namespace: {namespace}")
            return True
            
        except Exception as e:
            logger.error(f"Error upserting vectors: {str(e)}")
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Failed to upsert vectors: {str(e)}"
            )
    
    async def query_vectors(
        self, 
        query_vector: List[float], 
        top_k: int = 5, 
        namespace: str = "default",
        filter_dict: Optional[Dict[str, Any]] = None
    ) -> List[Dict[str, Any]]:
        """
        Query vectors from Pinecone index.
        
        Args:
            query_vector: Query vector to search for
            top_k: Number of top results to return
            namespace: Namespace to search in
            filter_dict: Optional filter for metadata
        
        Returns:
            List of matching vectors with scores
        """
        if not self._enabled:
            raise HTTPException(
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                detail="Pinecone service is not configured"
            )
        
        try:
            results = self.index.query(
                vector=query_vector,
                top_k=top_k,
                namespace=namespace,
                filter=filter_dict,
                include_metadata=True
            )
            
            logger.info(f"Successfully queried vectors, found {len(results.matches)} matches")
            return [
                {
                    "id": match.id,
                    "score": match.score,
                    "metadata": match.metadata
                }
                for match in results.matches
            ]
            
        except Exception as e:
            logger.error(f"Error querying vectors: {str(e)}")
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Failed to query vectors: {str(e)}"
            )
    
    async def delete_vectors(
        self, 
        ids: List[str], 
        namespace: str = "default"
    ) -> bool:
        """
        Delete vectors from Pinecone index.
        
        Args:
            ids: List of vector IDs to delete
            namespace: Namespace containing the vectors
        
        Returns:
            True if successful, False otherwise
        """
        if not self._enabled:
            raise HTTPException(
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                detail="Pinecone service is not configured"
            )
        
        try:
            self.index.delete(ids=ids, namespace=namespace)
            logger.info(f"Successfully deleted {len(ids)} vectors from namespace: {namespace}")
            return True
            
        except Exception as e:
            logger.error(f"Error deleting vectors: {str(e)}")
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Failed to delete vectors: {str(e)}"
            )

# Create global instance
pinecone_service = PineconeService()