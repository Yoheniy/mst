import os
import logging
from typing import List, Dict, Any, Optional
import requests
from fastapi import HTTPException, status
from dotenv import load_dotenv
import numpy as np
import hashlib

load_dotenv('/home/jovanijo/Desktop/mst/backend/.env')

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class AIService:
    def __init__(self):
        """Initialize AI service with Groq API only."""
        self.groq_api_key = os.getenv("GROQ_API_KEY")
        self.groq_model = os.getenv("GROQ_MODEL", "llama-3.1-8b-instant")
        self.groq_max_tokens = int(os.getenv("GROQ_MAX_TOKENS", "1000"))
        self.groq_temperature = float(os.getenv("GROQ_TEMPERATURE", "0.7"))
        
        self._enabled = bool(self.groq_api_key)
        
        if self._enabled:
            logger.info(f"AIService initialized with model: {self.groq_model}")
        else:
            logger.warning("AIService disabled - GROQ_API_KEY not found")
    
    def is_enabled(self) -> bool:
        """Check if AI service is enabled."""
        return self._enabled
    
    async def generate_embeddings(self, text: str) -> List[float]:
        """Generate embeddings for text using a simple fallback method."""
        try:
            # Create a deterministic embedding based on text content
            words = text.lower().split()
            vector = np.zeros(1024)  # Pinecone expects 1024 dimensions
            
            # Create embeddings based on word positions and content
            for i, word in enumerate(words[:1024]):
                # Use hash of word + position for deterministic results
                hash_input = f"{word}_{i}".encode()
                hash_val = int(hashlib.sha256(hash_input).hexdigest()[:8], 16)
                vector[i % 1024] = (hash_val % 10000) / 10000.0
            
            # Add text length and character diversity features
            text_features = [
                len(text) / 1000.0,  # Text length feature
                len(set(text.lower())) / 100.0,  # Character diversity
                text.count(' ') / 100.0,  # Word count feature
            ]
            
            # Insert text features at specific positions
            for i, feature in enumerate(text_features):
                if i < 1024:
                    vector[i] = feature
            
            # Normalize the vector
            norm = np.linalg.norm(vector)
            if norm > 0:
                vector = vector / norm
            
            return vector.tolist()
            
        except Exception as e:
            logger.error(f"Error generating embeddings: {str(e)}")
            # Return a zero vector as fallback
            return [0.0] * 1024
    
    async def chat_completion(
        self, 
        messages: List[Dict[str, str]],
        context: Optional[str] = None,
        max_tokens: Optional[int] = None,
        temperature: Optional[float] = None
    ) -> Dict[str, Any]:
        """Generate chat completion using Groq API."""
        if not self._enabled:
            raise HTTPException(
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                detail="AI service is not configured. Please set GROQ_API_KEY."
            )
        
        try:
            # Prepare messages for Groq API
            formatted_messages = []
            
            # Add system message with context
            system_content = "You are an expert AI assistant for machine tool technical support. You help customers with troubleshooting, maintenance, and operation of manufacturing equipment."
            if context:
                system_content += f"\n\nContext Information:\n{context}"
            
            formatted_messages.append({"role": "system", "content": system_content})
            
            # Add user messages
            for msg in messages:
                if msg.get('role') in ['user', 'assistant']:
                    formatted_messages.append({"role": msg['role'], "content": msg['content']})
            
            headers = {
                "Authorization": f"Bearer {self.groq_api_key}",
                "Content-Type": "application/json"
            }
            
            payload = {
                "model": self.groq_model,
                "messages": formatted_messages,
                "max_tokens": max_tokens or self.groq_max_tokens,
                "temperature": temperature or self.groq_temperature,
                "stream": False
            }
            
            response = requests.post(
                "https://api.groq.com/openai/v1/chat/completions", 
                headers=headers, 
                json=payload, 
                timeout=60
            )
            response.raise_for_status()
            
            data = response.json()
            
            return {
                "response": data["choices"][0]["message"]["content"],
                "model": data["model"],
                "usage": data["usage"],
                "confidence": self._calculate_confidence(data["usage"])
            }
            
        except requests.exceptions.RequestException as e:
            logger.error(f"Groq API request failed: {str(e)}")
            raise HTTPException(
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                detail=f"AI service unavailable: {str(e)}"
            )
        except Exception as e:
            logger.error(f"Chat completion failed: {str(e)}")
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Failed to generate completion: {str(e)}"
            )
    
    def _calculate_confidence(self, usage: Dict[str, int]) -> float:
        """Calculate confidence score based on response characteristics."""
        # Simple confidence calculation based on token usage
        total_tokens = usage.get("total_tokens", 0)
        completion_tokens = usage.get("completion_tokens", 0)
        
        if total_tokens == 0:
            return 0.5
        
        # Higher confidence for more substantial responses
        confidence = min(0.3 + (completion_tokens / 50 * 0.1), 0.9)
        return round(confidence, 2)
    
    async def moderate_content(self, text: str) -> Dict[str, Any]:
        """Simple content moderation without external APIs."""
        flagged_keywords = [
            "hate speech", "violence", "harassment", "dangerous instructions",
            "kill", "harm", "attack", "dangerous", "illegal"
        ]
        
        text_lower = text.lower()
        flags = [kw for kw in flagged_keywords if kw in text_lower]
        
        return {
            "flagged": len(flags) > 0,
            "flags": flags,
            "safe": len(flags) == 0
        }

# Create global instance
ai_service = AIService()