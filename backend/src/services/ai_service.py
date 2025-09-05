import os
import logging
from typing import Dict, List, Optional, Any
from fastapi import HTTPException, status
from groq import Groq

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class AIService:
    def __init__(self):
        """Initialize AI service with Groq API."""
        try:
            # Get Groq API key from environment
            api_key = os.getenv("GROQ_API_KEY")
            if not api_key:
                logger.warning("GROQ_API_KEY not found in environment variables")
                self._enabled = False
                return
            
            # Initialize Groq client - SIMPLE VERSION
            from groq import Groq
            self.client = Groq(api_key=api_key)
            
            # Configuration
            self.model = os.getenv("GROQ_MODEL", "llama3-8b-8192")
            self.max_tokens = int(os.getenv("GROQ_MAX_TOKENS", "1000"))
            self.temperature = float(os.getenv("GROQ_TEMPERATURE", "0.7"))
            
            self._enabled = True
            logger.info(f"AI Service initialized with Groq model: {self.model}")
            
        except ImportError:
            logger.warning("Groq library not installed. AI service disabled.")
            self._enabled = False
        except Exception as e:
            logger.error(f"Failed to initialize AI Service: {str(e)}")
            self._enabled = False
    def is_enabled(self) -> bool:
        """Check if AI service is properly configured."""
        return self._enabled
    
    async def chat_completion(
        self, 
        messages: List[Dict[str, str]], 
        context: Optional[str] = None
    ) -> Dict[str, Any]:
        """
        Generate AI response using Groq API.
        """
        if not self._enabled:
            raise HTTPException(
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                detail="AI service is not configured"
            )
        
        try:
            # Prepare system message with context
            system_content = """You are an expert AI assistant for machine tool technical support. You help customers with troubleshooting, maintenance, and operation of manufacturing equipment."""

            if context:
                system_content += f"\n\nContext Information: {context}"

            # Prepare messages for Groq API
            groq_messages = [{"role": "system", "content": system_content}]
            
            for msg in messages:
                if msg.get('role') in ['user', 'assistant']:
                    groq_messages.append({"role": msg['role'], "content": msg['content']})

            # Generate response using direct Groq API
            response = self.client.chat.completions.create(
                model=self.model,
                messages=groq_messages,
                max_tokens=self.max_tokens,
                temperature=self.temperature
            )
            
            ai_response = response.choices[0].message.content
            
            # Calculate token usage
            total_tokens = response.usage.total_tokens if hasattr(response, 'usage') and response.usage else len(str(groq_messages) + ai_response) // 4
            
            logger.info(f"AI response generated successfully using Groq {self.model}")
            
            return {
                "response": ai_response.strip(),
                "model": self.model,
                "usage": {
                    "prompt_tokens": total_tokens // 2,
                    "completion_tokens": total_tokens // 2,
                    "total_tokens": total_tokens
                },
                "confidence": await self.analyze_confidence(ai_response, messages[-1]['content'] if messages else "")
            }
            
        except Exception as e:
            logger.error(f"Error generating AI response: {str(e)}")
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Failed to generate AI response: {str(e)}"
            )
    
    async def generate_embeddings(self, text: str) -> List[float]:
        """
        Generate embeddings using Groq API (if available) with fallback.
        """
        if not self._enabled:
            raise HTTPException(
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                detail="AI service is not configured"
            )
        
        try:
            # Try Groq embeddings first (if supported)
            try:
                # Note: Groq might not support embeddings yet, so we'll use a fallback
                response = self.client.embeddings.create(
                    model="text-embedding-ada-002",  # Fallback model
                    input=text
                )
                return response.data[0].embedding
            except Exception as groq_error:
                logger.warning(f"Groq embeddings not available: {groq_error}. Using fallback.")
                
                # Fallback: Simple but consistent embeddings
                import numpy as np
                import hashlib
                
                # Create a deterministic embedding based on text content
                words = text.lower().split()
                vector = np.zeros(384)  # Standard embedding dimension
                
                # Create embeddings based on word positions and content
                for i, word in enumerate(words[:384]):
                    # Use hash of word + position for deterministic results
                    hash_input = f"{word}_{i}".encode()
                    hash_val = int(hashlib.sha256(hash_input).hexdigest()[:8], 16)
                    vector[i % 384] = (hash_val % 10000) / 10000.0
                
                # Add text length and character diversity features
                text_features = [
                    len(text) / 1000.0,  # Text length feature
                    len(set(text.lower())) / 100.0,  # Character diversity
                    text.count(' ') / 100.0,  # Word count feature
                ]
                
                # Insert text features at specific positions
                for i, feature in enumerate(text_features):
                    if i < 384:
                        vector[i] = feature
                
                # Normalize the vector
                norm = np.linalg.norm(vector)
                if norm > 0:
                    vector = vector / norm
                
                return vector.tolist()
            
        except Exception as e:
            logger.error(f"Error generating embeddings: {str(e)}")
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Failed to generate embeddings: {str(e)}"
            )
    
    async def analyze_confidence(self, response: str, query: str) -> float:
        """
        Analyze the confidence level of an AI response.
        """
        if not response or len(response.strip()) < 10:
            return 0.1
        
        if "I don't know" in response or "I'm not sure" in response:
            return 0.3
        
        if len(response) > 100:
            return 0.8
        
        return 0.6

# Create global instance
ai_service = AIService()
