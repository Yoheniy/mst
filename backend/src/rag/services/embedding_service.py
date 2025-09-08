# # mst/backend/src/services/embedding_service.py
# import os
# import logging
# from typing import List, Optional
# from fastapi import HTTPException, status
# import requests
# from sentence_transformers import SentenceTransformer

# # Configure logging
# logging.basicConfig(level=logging.INFO)
# logger = logging.getLogger(__name__)

# class EmbeddingService:
#     def __init__(self):
#         """Initialize embedding service with multiple providers."""
#         self._enabled = True
#         self.groq_api_key = os.getenv("GROQ_API_KEY")
#         self.groq_model = os.getenv("GROQ_EMBEDDING_MODEL", "llama-text-embed-v2")
#         self.groq_url = "https://api.groq.com/openai/v1/embeddings"
        
#         # Fallback to Hugging Face
#         self.hf_model_name = os.getenv("HF_EMBEDDING_MODEL", "sentence-transformers/all-MiniLM-L6-v2")
#         self.hf_model = None
#         self.hf_dimension = 384  # Default for all-MiniLM-L6-v2
        
#         logger.info("Embedding Service initialized")
    
#     def is_enabled(self) -> bool:
#         """Check if embedding service is enabled."""
#         return self._enabled
    
#     async def generate_embeddings_groq(self, texts: List[str]) -> Optional[List[List[float]]]:
#         """Generate embeddings using Groq API."""
#         if not self.groq_api_key:
#             return None
            
#         try:
#             headers = {
#                 "Authorization": f"Bearer {self.groq_api_key}",
#                 "Content-Type": "application/json"
#             }
            
#             embeddings = []
#             for text in texts:
#                 payload = {
#                     "input": text,
#                     "model": self.groq_model
#                 }
                
#                 response = requests.post(self.groq_url, headers=headers, json=payload, timeout=30)
#                 response.raise_for_status()
                
#                 data = response.json()
#                 embeddings.append(data["data"][0]["embedding"])
            
#             return embeddings
            
#         except Exception as e:
#             logger.error(f"Groq embedding failed: {str(e)}")
#             return None
    
#     async def generate_embeddings_hf(self, texts: List[str]) -> List[List[float]]:
#         """Generate embeddings using Hugging Face model."""
#         try:
#             # Lazy load model to save memory
#             if self.hf_model is None:
#                 logger.info(f"Loading Hugging Face model: {self.hf_model_name}")
#                 self.hf_model = SentenceTransformer(self.hf_model_name)
            
#             embeddings = self.hf_model.encode(texts, convert_to_tensor=False)
#             return embeddings.tolist()
            
#         except Exception as e:
#             logger.error(f"Hugging Face embedding failed: {str(e)}")
#             raise HTTPException(
#                 status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
#                 detail=f"Failed to generate embeddings: {str(e)}"
#             )
    
#     async def generate_embeddings(self, texts: List[str]) -> List[List[float]]:
#         """Generate embeddings with fallback strategy."""
#         if not texts:
#             return []
        
#         # Try Groq first
#         groq_embeddings = await self.generate_embeddings_groq(texts)
#         if groq_embeddings:
#             logger.info(f"Generated {len(groq_embeddings)} embeddings using Groq")
#             return groq_embeddings
        
#         # Fallback to Hugging Face
#         logger.info("Falling back to Hugging Face embeddings")
#         return await self.generate_embeddings_hf(texts)
    
#     def get_embedding_dimension(self) -> int:
#         """Get the dimension of embeddings."""
#         if self.groq_api_key:
#             # Groq's llama-text-embed-v2 has 1024 dimensions
#             return 1024
#         else:
#             return self.hf_dimension

# # Create global instance
# embedding_service = EmbeddingService()

# mst/backend/src/services/embedding_service.py
import os
import logging
from typing import List, Optional
import requests
from fastapi import HTTPException, status

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class EmbeddingService:
    def __init__(self):
        """Initialize embedding service with online APIs only."""
        self._enabled = True
        self.groq_api_key = os.getenv("GROQ_API_KEY")
        self.openai_api_key = os.getenv("OPENAI_API_KEY")  # Optional fallback
        
        logger.info("Embedding Service initialized (online APIs only)")
    
    def is_enabled(self) -> bool:
        """Check if embedding service is enabled."""
        return self._enabled and (self.groq_api_key or self.openai_api_key)
    
    async def generate_embeddings_groq(self, texts: List[str]) -> Optional[List[List[float]]]:
        """Generate embeddings using Groq API."""
        if not self.groq_api_key:
            return None
            
        try:
            headers = {
                "Authorization": f"Bearer {self.groq_api_key}",
                "Content-Type": "application/json"
            }
            
            embeddings = []
            for text in texts:
                payload = {
                    "input": text,
                    "model": "llama-text-embed-v2"
                }
                
                response = requests.post(
                    "https://api.groq.com/openai/v1/embeddings", 
                    headers=headers, 
                    json=payload, 
                    timeout=30
                )
                response.raise_for_status()
                
                data = response.json()
                embeddings.append(data["data"][0]["embedding"])
            
            logger.info(f"Generated {len(embeddings)} embeddings using Groq")
            return embeddings
            
        except Exception as e:
            logger.error(f"Groq embedding failed: {str(e)}")
            return None
    
    async def generate_embeddings_openai(self, texts: List[str]) -> Optional[List[List[float]]]:
        """Generate embeddings using OpenAI API as fallback."""
        if not self.openai_api_key:
            return None
            
        try:
            headers = {
                "Authorization": f"Bearer {self.openai_api_key}",
                "Content-Type": "application/json"
            }
            
            embeddings = []
            for text in texts:
                payload = {
                    "input": text,
                    "model": "text-embedding-ada-002"
                }
                
                response = requests.post(
                    "https://api.openai.com/v1/embeddings", 
                    headers=headers, 
                    json=payload, 
                    timeout=30
                )
                response.raise_for_status()
                
                data = response.json()
                embeddings.append(data["data"][0]["embedding"])
            
            logger.info(f"Generated {len(embeddings)} embeddings using OpenAI")
            return embeddings
            
        except Exception as e:
            logger.error(f"OpenAI embedding failed: {str(e)}")
            return None
    
    async def generate_embeddings(self, texts: List[str]) -> List[List[float]]:
        """Generate embeddings with online APIs only."""
        if not texts:
            return []
        
        # Try Groq first
        groq_embeddings = await self.generate_embeddings_groq(texts)
        if groq_embeddings:
            return groq_embeddings
        
        # Try OpenAI as fallback
        openai_embeddings = await self.generate_embeddings_openai(texts)
        if openai_embeddings:
            return openai_embeddings
        
        # If both fail, raise error
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="No embedding service available. Check API keys for Groq or OpenAI."
        )
    
    def get_embedding_dimension(self) -> int:
        """Get the dimension of embeddings."""
        if self.groq_api_key:
            return 1024  # Groq's llama-text-embed-v2
        elif self.openai_api_key:
            return 1536  # OpenAI's text-embedding-ada-002
        else:
            return 1024  # Default to Groq dimension

# Create global instance
embedding_service = EmbeddingService()