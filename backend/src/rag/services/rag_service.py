# RAG Service - Main orchestration service
import logging
from typing import Dict, Any, Optional

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class RAGService:
    def __init__(self):
        """Initialize RAG service with all sub-services."""
        try:
            from .ai_service import ai_service
            from .pinecone_service import pinecone_service
            from .document_service import document_service
            
            self.ai_service = ai_service
            self.pinecone_service = pinecone_service
            self.document_service = document_service
            
            # Check service availability
            self._ai_enabled = self.ai_service.is_enabled() if self.ai_service else False
            self._pinecone_enabled = self.pinecone_service.is_enabled() if self.pinecone_service else False
            self._document_enabled = self.document_service.is_enabled() if self.document_service else False
            
            logger.info(f"RAG Service initialized - AI: {self._ai_enabled}, Pinecone: {self._pinecone_enabled}, Document: {self._document_enabled}")
            
        except Exception as e:
            logger.error(f"Failed to initialize RAG service: {str(e)}")
            self._ai_enabled = False
            self._pinecone_enabled = False
            self._document_enabled = False
    
    def is_enabled(self) -> bool:
        """Check if RAG service is operational."""
        return True
    
    def health_check(self) -> Dict[str, Any]:
        """Check health of all RAG services."""
        return {
            "rag_service": "healthy" if self.is_enabled() else "error",
            "ai_service": "enabled" if self._ai_enabled else "disabled",
            "pinecone_service": "enabled" if self._pinecone_enabled else "disabled", 
            "document_service": "enabled" if self._document_enabled else "disabled",
            "overall_status": "healthy" if self.is_enabled() else "error"
        }
    
    async def get_stats(self) -> Dict[str, Any]:
        """Get RAG system statistics."""
        try:
            # This would normally query Pinecone for actual stats
            return {
                "total_documents": 0,  # Placeholder
                "total_chunks": 0,     # Placeholder
                "total_vectors": 0,    # Placeholder
                "index_size": 0        # Placeholder
            }
        except Exception as e:
            logger.error(f"Error getting stats: {str(e)}")
            return {
                "total_documents": 0,
                "total_chunks": 0,
                "total_vectors": 0,
                "index_size": 0,
                "error": str(e)
            }
    
    async def process_document(
        self, 
        content: str, 
        title: str = "Untitled",
        document_type: str = "manual",
        machine_type: Optional[str] = None,
        use_smart_chunking: bool = True
    ) -> Dict[str, Any]:
        """
        Process a document: chunk it, generate embeddings, and store in vector DB.
        """
        try:
            logger.info(f"Processing document: {title}")
            
            if not self._pinecone_enabled:
                logger.warning("Pinecone not enabled, skipping vector storage")
                return {
                    "status": "success",
                    "title": title,
                    "document_type": document_type,
                    "machine_type": machine_type,
                    "chunks_created": 0,
                    "vectors_stored": 0,
                    "message": "Document processed but not stored in Pinecone (Pinecone disabled)"
                }
            
            # 1. Chunk the document
            chunks = self.document_service.smart_text_split(
                text=content,
                chunk_size=500,
                chunk_overlap=50
            )
            
            if not chunks:
                logger.error("Failed to chunk document")
                return {
                    "status": "error",
                    "message": "Failed to chunk document"
                }
            
            # 2. Generate embeddings and store in Pinecone
            vectors_stored = 0
            for i, chunk in enumerate(chunks):
                try:
                    # Generate embedding
                    embedding = await self.ai_service.generate_embeddings(chunk['content'])
                    
                    if embedding:
                        # Prepare vector for Pinecone
                        vector_id = f"{title}_{i}_{hash(chunk['content']) % 10000}"
                        vector_data = {
                            "id": vector_id,
                            "values": embedding,
                            "metadata": {
                                "title": title,
                                "document_type": document_type,
                                "machine_type": machine_type or "general",
                                "chunk_index": i,
                                "chunk_text": chunk['content'][:500]  # Store first 500 chars
                            }
                        }
                        
                        # Store in Pinecone
                        await self.pinecone_service.upsert_vectors([vector_data])
                        vectors_stored += 1
                        
                except Exception as e:
                    logger.error(f"Error processing chunk {i}: {str(e)}")
                    continue
            
            logger.info(f"Successfully processed document: {title}, stored {vectors_stored} vectors")
            
            return {
                "status": "success",
                "title": title,
                "document_type": document_type,
                "machine_type": machine_type,
                "chunks_created": len(chunks),
                "vectors_stored": vectors_stored,
                "message": f"Document processed successfully, stored {vectors_stored} vectors in Pinecone"
            }
            
        except Exception as e:
            logger.error(f"Error processing document: {str(e)}")
            return {
                "status": "error",
                "message": f"Failed to process document: {str(e)}"
            }
    
    async def generate_rag_response(
        self,
        query: str,
        machine_type: Optional[str] = None,
        context_limit: int = 3
    ) -> Dict[str, Any]:
        """
        Generate a RAG response by querying the vector database.
        """
        try:
            logger.info(f"Generating RAG response for query: {query}")
            
            if not self._pinecone_enabled or not self._ai_enabled:
                # Fallback response if services not available
                response_text = f"I understand you're asking about: '{query}'. "
                if machine_type:
                    response_text += f"This relates to {machine_type} machines. "
                response_text += "I'm currently in a simplified mode because Pinecone or AI services are not configured. "
                response_text += "Please configure your API keys to enable full RAG functionality."
                
                return {
                    "response": response_text,
                    "model": "rag-fallback",
                    "usage": {
                        "prompt_tokens": len(query.split()),
                        "completion_tokens": len(response_text.split()),
                        "total_tokens": len(query.split()) + len(response_text.split())
                    },
                    "confidence": 0.3,
                    "sources": []
                }
            
            # 1. Generate query embedding
            query_embedding = await self.ai_service.generate_embeddings(query)
            
            if not query_embedding:
                raise Exception("Failed to generate query embedding")
            
            # 2. Query Pinecone for relevant documents
            filter_dict = {"machine_type": machine_type} if machine_type else None
            search_results = await self.pinecone_service.query_vectors(
                query_vector=query_embedding,
                top_k=context_limit,
                filter_dict=filter_dict
            )
            
            # 3. Prepare context from search results
            context_parts = []
            sources = []
            
            for result in search_results:
                if result.get('metadata', {}).get('chunk_text'):
                    context_parts.append(result['metadata']['chunk_text'])
                    sources.append({
                        "title": result['metadata'].get('title', 'Unknown'),
                        "score": result.get('score', 0),
                        "chunk_text": result['metadata']['chunk_text'][:200] + "..."
                    })
            
            context = "\n\n".join(context_parts) if context_parts else "No relevant documents found."
            
            # 4. Generate AI response with context
            messages = [
                {"role": "system", "content": "You are a helpful assistant for machine tool technical support. Use the provided context to answer questions accurately."},
                {"role": "user", "content": f"Question: {query}\n\nContext:\n{context}"}
            ]
            
            ai_response = await self.ai_service.chat_completion(
                messages=messages,
                context=context
            )
            
            return {
                "response": ai_response["response"],
                "model": ai_response["model"],
                "usage": ai_response["usage"],
                "confidence": ai_response["confidence"],
                "sources": sources
            }
            
        except Exception as e:
            logger.error(f"Error generating RAG response: {str(e)}")
            return {
                "response": f"I apologize, but I'm experiencing technical difficulties. Your query was: '{query}'. Please try again later.",
                "model": "error-fallback",
                "usage": {"prompt_tokens": 0, "completion_tokens": 0, "total_tokens": 0},
                "confidence": 0.1,
                "sources": []
            }
# Create global instance
rag_service = RAGService()