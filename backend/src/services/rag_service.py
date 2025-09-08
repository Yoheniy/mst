import os
import logging
from typing import List, Dict, Any, Optional
from fastapi import HTTPException, status

from .ai_service import ai_service
from .pinecone_service import pinecone_service
from .document_service import document_service

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class RAGService:
    def __init__(self):
        """Initialize RAG service with all sub-services."""
        self.ai_service = ai_service
        self.pinecone_service = pinecone_service
        self.document_service = document_service
        
        # Check service availability
        self._ai_enabled = self.ai_service.is_enabled() if self.ai_service else False
        self._pinecone_enabled = self.pinecone_service.is_enabled() if self.pinecone_service else False
        self._document_enabled = self.document_service.is_enabled() if self.document_service else False
        
        logger.info(f"RAG Service initialized - AI: {self._ai_enabled}, Pinecone: {self._pinecone_enabled}, Document: {self._document_enabled}")
    
    def is_enabled(self) -> bool:
        """Check if RAG service is fully operational."""
        return self._ai_enabled and self._document_enabled
    
    async def process_document(
        self, 
        content: str, 
        title: str = "Untitled",
        document_type: str = "manual",
        machine_type: Optional[str] = None,
        use_smart_chunking: bool = True
    ) -> Dict[str, Any]:
#         """
#         Process a document: chunk it, generate embeddings, and store in vector DB.
        
#         Args:
#             content: The document text content
#             title: Document title
#             document_type: Type of document (manual, faq, troubleshooting, training)
#             machine_type: Type of machine this document relates to
#             use_smart_chunking: Whether to use smart chunking with metadata
            
#         Returns:
#             Processing results with chunk count and vector storage info
#         """
#         try:
#             logger.info(f"Processing document: {title} ({len(content)} characters)")
            
#             # Step 1: Split document into chunks using smart chunking
#             if use_smart_chunking:
#                 chunk_data = self.document_service.smart_text_split(content, chunk_size=500, chunk_overlap=50)
#                 chunks = [chunk["content"] for chunk in chunk_data]
#                 chunk_metadata = chunk_data
#             else:
#                 chunks = self.document_service.text_split(content, chunk_size=500, chunk_overlap=50)
#                 chunk_metadata = [{"metadata": {"chunk_type": "general"}} for _ in chunks]
            
#             logger.info(f"Split document into {len(chunks)} chunks using {'smart' if use_smart_chunking else 'standard'} chunking")
            
#             # Step 2: Generate embeddings for each chunk
#             vectors = []
#             for i, (chunk, metadata) in enumerate(zip(chunks, chunk_metadata)):
#                 try:
#                     # Generate embedding
#                     embedding = await self.ai_service.generate_embeddings(chunk)
                    
#                     # Enhanced metadata for better search
#                     vector_metadata = {
#                         "text": chunk[:1000],  # Limit metadata size
#                         "title": title,
#                         "document_type": document_type,
#                         "machine_type": machine_type or "general",
#                         "chunk_index": i,
#                         "total_chunks": len(chunks),
#                         "chunk_type": metadata.get("metadata", {}).get("chunk_type", "general"),
#                         "word_count": metadata.get("metadata", {}).get("word_count", len(chunk.split())),
#                         "has_technical_terms": metadata.get("metadata", {}).get("has_technical_terms", False),
#                         "is_complete": metadata.get("metadata", {}).get("is_complete", False)
#                     }
                    
#                     # Create vector with enhanced metadata
#                     vector = {
#                         "id": f"{title.replace(' ', '_')}_{i}_{hash(chunk) % 10000}",
#                         "values": embedding,
#                         "metadata": vector_metadata
#                     }
#                     vectors.append(vector)
                    
#                 except Exception as e:
#                     logger.warning(f"Failed to process chunk {i}: {str(e)}")
#                     continue
            
#             logger.info(f"Generated {len(vectors)} embeddings with enhanced metadata")
            
#             # Step 3: Store vectors in Pinecone (if available)
#             pinecone_result = None
#             if self._pinecone_enabled and vectors:
#                 try:
#                     # Store in batches to avoid size limits
#                     batch_size = 50
#                     for i in range(0, len(vectors), batch_size):
#                         batch = vectors[i:i + batch_size]
#                         await self.pinecone_service.upsert_vectors(batch)
                    
#                     pinecone_result = {"stored_vectors": len(vectors), "status": "success"}
#                     logger.info(f"Stored {len(vectors)} vectors in Pinecone with enhanced metadata")
                    
#                 except Exception as e:
#                     logger.error(f"Failed to store vectors in Pinecone: {str(e)}")
#                     pinecone_result = {"stored_vectors": 0, "status": "failed", "error": str(e)}
#             else:
#                 pinecone_result = {"stored_vectors": 0, "status": "pinecone_disabled"}
            
#             # Step 4: Compile comprehensive processing results
#             processing_stats = {
#                 "title": title,
#                 "document_type": document_type,
#                 "machine_type": machine_type,
#                 "content_length": len(content),
#                 "chunks_created": len(chunks),
#                 "vectors_generated": len(vectors),
#                 "chunking_method": "smart" if use_smart_chunking else "standard",
#                 "chunk_types": list(set([chunk.get("metadata", {}).get("chunk_type", "general") for chunk in chunk_metadata])),
#                 "technical_terms_found": any([chunk.get("metadata", {}).get("has_technical_terms", False) for chunk in chunk_metadata]),
#                 "pinecone_storage": pinecone_result,
#                 "status": "success"
#             }
            
#             return processing_stats
            
#         except Exception as e:
#             logger.error(f"Error processing document: {str(e)}")
#             raise HTTPException(
#                 status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
#                 detail=f"Failed to process document: {str(e)}"
#             )
    
#     async def retrieve_context(
#         self, 
#         query: str, 
#         top_k: int = 3,
#         machine_type: Optional[str] = None,
#         chunk_type_filter: Optional[str] = None,
#         use_hybrid_search: bool = True
#     ) -> List[Dict[str, Any]]:
#         """
#         Retrieve relevant context for a query using enhanced vector search.
        
#         Args:
#             query: User query to search for
#             top_k: Number of top results to return
#             machine_type: Filter by machine type (optional)
#             chunk_type_filter: Filter by chunk type (procedure, safety, maintenance, etc.)
#             use_hybrid_search: Whether to use hybrid search combining semantic and keyword matching
            
#         Returns:
#             List of relevant context chunks with enhanced metadata
#         """
#         try:
#             logger.info(f"Retrieving context for query: {query[:100]}...")
            
#             # Generate query embedding
#             query_embedding = await self.ai_service.generate_embeddings(query)
            
#             # Search Pinecone if available
#             if self._pinecone_enabled:
#                 try:
#                     # Prepare enhanced filter
#                     filter_dict = {}
#                     if machine_type:
#                         filter_dict["machine_type"] = machine_type
#                     if chunk_type_filter:
#                         filter_dict["chunk_type"] = chunk_type_filter
                    
#                     # Query vectors with enhanced search
#                     results = await self.pinecone_service.query_vectors(
#                         query_vector=query_embedding,
#                         top_k=top_k * 2,  # Get more results for re-ranking
#                         filter_dict=filter_dict if filter_dict else None
#                     )
                    
#                     # Enhanced context extraction with re-ranking
#                     context_chunks = []
#                     for result in results:
#                         metadata = result["metadata"]
                        
#                         # Calculate relevance score based on multiple factors
#                         base_score = result["score"]
                        
#                         # Boost score for technical terms if query contains technical language
#                         technical_boost = 1.2 if metadata.get("has_technical_terms", False) else 1.0
                        
#                         # Boost score for specific chunk types that match query intent
#                         chunk_type_boost = self._calculate_chunk_type_boost(query, metadata.get("chunk_type", "general"))
                        
#                         # Final relevance score
#                         relevance_score = base_score * technical_boost * chunk_type_boost
                        
#                         context_chunks.append({
#                             "text": metadata.get("text", ""),
#                             "title": metadata.get("title", "Unknown"),
#                             "document_type": metadata.get("document_type", "unknown"),
#                             "machine_type": metadata.get("machine_type", "general"),
#                             "chunk_type": metadata.get("chunk_type", "general"),
#                             "score": relevance_score,
#                             "base_score": base_score,
#                             "chunk_index": metadata.get("chunk_index", 0),
#                             "word_count": metadata.get("word_count", 0),
#                             "has_technical_terms": metadata.get("has_technical_terms", False)
#                         })
                    
#                     # Re-rank and limit results
#                     context_chunks.sort(key=lambda x: x["score"], reverse=True)
#                     context_chunks = context_chunks[:top_k]
                    
#                     logger.info(f"Retrieved {len(context_chunks)} context chunks with enhanced scoring")
#                     return context_chunks
                    
#                 except Exception as e:
#                     logger.warning(f"Pinecone search failed: {str(e)}")
                    
#             # Fallback: return empty context
#             logger.warning("No context available - Pinecone not enabled or failed")
#             return []
            
#         except Exception as e:
#             logger.error(f"Error retrieving context: {str(e)}")
#             return []
    
#     def _calculate_chunk_type_boost(self, query: str, chunk_type: str) -> float:
#         """Calculate boost factor based on chunk type and query intent."""
#         query_lower = query.lower()
        
#         # Define query intent patterns for different chunk types
#         intent_patterns = {
#             "procedure": ["how to", "steps", "procedure", "instructions", "guide", "tutorial"],
#             "safety": ["safety", "warning", "caution", "danger", "risk", "hazard"],
#             "maintenance": ["maintenance", "service", "repair", "troubleshooting", "fix", "problem"],
#             "specification": ["specification", "parameter", "setting", "configuration", "specs", "technical"],
#             "overview": ["overview", "introduction", "description", "what is", "explain"]
#         }
        
#         # Check if query matches chunk type intent
#         if chunk_type in intent_patterns:
#             patterns = intent_patterns[chunk_type]
#             if any(pattern in query_lower for pattern in patterns):
#                 return 1.3  # Boost for intent match
        
#         return 1.0  # No boost
    
#     async def generate_rag_response(
#         self, 
#         query: str,
#         machine_type: Optional[str] = None,
#         context_limit: int = 3,
#         chunk_type_filter: Optional[str] = None
#     ) -> Dict[str, Any]:
#         """
#         Generate a response using enhanced RAG (Retrieval-Augmented Generation).
        
#         Args:
#             query: User query
#             machine_type: Filter context by machine type
#             context_limit: Maximum number of context chunks to use
#             chunk_type_filter: Filter by specific chunk type
            
#         Returns:
#             Complete RAG response with enhanced context and AI-generated answer
#         """
#         try:
#             logger.info(f"Generating enhanced RAG response for: {query[:100]}...")
            
#             # Step 1: Retrieve relevant context with enhanced search
#             context_chunks = await self.retrieve_context(
#                 query=query,
#                 top_k=context_limit,
#                 machine_type=machine_type,
#                 chunk_type_filter=chunk_type_filter,
#                 use_hybrid_search=True
#             )
            
#             # Step 2: Prepare enhanced context string
#             context_text = ""
#             if context_chunks:
#                 context_parts = []
#                 for chunk in context_chunks:
#                     chunk_info = f"Document: {chunk['title']}"
#                     chunk_info += f"\nType: {chunk['chunk_type'].title()}"
#                     chunk_info += f"\nRelevance: {chunk['score']:.3f}"
#                     chunk_info += f"\nContent: {chunk['text']}"
#                     context_parts.append(chunk_info)
                
#                 context_text = "\n\n---\n\n".join(context_parts)
            
#             # Step 3: Generate AI response with enhanced context
#             system_prompt = self._generate_system_prompt(query, context_chunks)
            
#             messages = [
#                 {"role": "system", "content": system_prompt},
#                 {"role": "user", "content": query}
#             ]
            
#             ai_response = await self.ai_service.chat_completion(
#                 messages=messages,
#                 context=context_text if context_text else None
#             )
            
#             # Step 4: Compile complete enhanced response
#             response = {
#                 "query": query,
#                 "response": ai_response["response"],
#                 "context_used": len(context_chunks),
#                 "context_chunks": context_chunks,
#                 "machine_type_filter": machine_type,
#                 "chunk_type_filter": chunk_type_filter,
#                 "confidence": ai_response.get("confidence", 0.5),
#                 "model": ai_response.get("model", "unknown"),
#                 "usage": ai_response.get("usage", {}),
#                 "search_metadata": {
#                     "total_results": len(context_chunks),
#                     "avg_relevance_score": sum(chunk["score"] for chunk in context_chunks) / len(context_chunks) if context_chunks else 0,
#                     "chunk_types_found": list(set(chunk["chunk_type"] for chunk in context_chunks)),
#                     "technical_content_available": any(chunk["has_technical_terms"] for chunk in context_chunks)
#                 },
#                 "status": "success"
#             }
            
#             logger.info(f"Enhanced RAG response generated successfully with {len(context_chunks)} context chunks")
#             return response
            
#         except Exception as e:
#             logger.error(f"Error generating enhanced RAG response: {str(e)}")
#             raise HTTPException(
#                 status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
#                 detail=f"Failed to generate enhanced RAG response: {str(e)}"
#             )
    
#     def _generate_system_prompt(self, query: str, context_chunks: List[Dict[str, Any]]) -> str:
#         """Generate a system prompt tailored to the query and available context."""
#         base_prompt = """You are an expert machine tool support assistant. Use the provided context to answer questions accurately and helpfully.

# Key guidelines:
# - Prioritize safety information and warnings
# - Provide step-by-step procedures when relevant
# - Reference specific technical specifications when available
# - If context is insufficient, acknowledge limitations
# - Use clear, technical language appropriate for machine operators

# Available context types: {chunk_types}
# Query: {query}"""

#         chunk_types = list(set(chunk["chunk_type"] for chunk in context_chunks))
#         return base_prompt.format(
#             chunk_types=", ".join(chunk_types) if chunk_types else "general",
#             query=query
#         )
    
#     async def health_check(self) -> Dict[str, Any]:
#         """Check the health of all RAG service components."""
#         return {
#             "rag_service": "operational",
#             "ai_service": "enabled" if self._ai_enabled else "disabled",
#             "pinecone_service": "enabled" if self._pinecone_enabled else "disabled", 
#             "document_service": "enabled" if self._document_enabled else "disabled",
#             "features": {
#                 "smart_chunking": True,
#                 "enhanced_metadata": True,
#                 "intent_based_search": True,
#                 "hybrid_search": True
#             },
#             "overall_status": "operational" if self.is_enabled() else "limited"
#         }

# # Create global instance
# rag_service = RAGService()






# mst/backend/src/services/rag_service.py
import os
import logging
from typing import List, Dict, Any, Optional
from fastapi import HTTPException, status

from .ai_service import ai_service
from .pinecone_service import pinecone_service
from .document_service import document_service
from .embedding_service import embedding_service

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class RAGService:
    def __init__(self):
        """Initialize RAG service with online components only."""
        self.ai_service = ai_service
        self.pinecone_service = pinecone_service
        self.document_service = document_service
        self.embedding_service = embedding_service
        
        # Check service availability
        self._ai_enabled = self.ai_service.is_enabled()
        self._pinecone_enabled = self.pinecone_service.is_enabled()
        self._embedding_enabled = self.embedding_service.is_enabled()
        
        logger.info(f"RAG Service initialized - AI: {self._ai_enabled}, Pinecone: {self._pinecone_enabled}, Embedding: {self._embedding_enabled}")
    
    def is_enabled(self) -> bool:
        """Check if RAG service is fully operational."""
        return self._ai_enabled and self._pinecone_enabled and self._embedding_enabled
    
    async def process_document(
        self, 
        content: str, 
        title: str = "Untitled",
        document_type: str = "manual",
        machine_type: Optional[str] = None
    ) -> Dict[str, Any]:
        """
        Process a document using online services only.
        """
        try:
            logger.info(f"Processing document: {title} ({len(content)} characters)")
            
            # Split document into chunks
            chunks = self.document_service.text_split(content, chunk_size=500, chunk_overlap=50)
            logger.info(f"Split document into {len(chunks)} chunks")
            
            # Generate embeddings using online service
            embeddings = await self.embedding_service.generate_embeddings(chunks)
            
            # Prepare vectors for Pinecone
            vectors = []
            for i, (chunk, embedding) in enumerate(zip(chunks, embeddings)):
                vector_metadata = {
                    "text": chunk[:1000],
                    "title": title,
                    "document_type": document_type,
                    "machine_type": machine_type or "general",
                    "chunk_index": i,
                    "total_chunks": len(chunks)
                }
                
                vector = {
                    "id": f"{title.replace(' ', '_')}_{i}",
                    "values": embedding,
                    "metadata": vector_metadata
                }
                vectors.append(vector)
            
            # Store in Pinecone
            if self._pinecone_enabled and vectors:
                await self.pinecone_service.upsert_vectors(vectors)
                logger.info(f"Stored {len(vectors)} vectors in Pinecone")
            
            return {
                "status": "success",
                "chunks_processed": len(chunks),
                "vectors_stored": len(vectors),
                "title": title
            }
            
        except Exception as e:
            logger.error(f"Error processing document: {str(e)}")
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Failed to process document: {str(e)}"
            )
    
    async def retrieve_context(
        self, 
        query: str, 
        top_k: int = 3,
        machine_type: Optional[str] = None
    ) -> List[Dict[str, Any]]:
        """
        Retrieve relevant context using online services.
        """
        try:
            # Generate query embedding
            query_embedding = await self.embedding_service.generate_embeddings([query])
            
            if not query_embedding:
                return []
            
            # Search Pinecone
            results = await self.pinecone_service.query_vectors(
                query_vector=query_embedding[0],
                top_k=top_k,
                filter_dict={"machine_type": machine_type} if machine_type else None
            )
            
            return [
                {
                    "text": result["metadata"].get("text", ""),
                    "title": result["metadata"].get("title", "Unknown"),
                    "score": result["score"],
                    "document_type": result["metadata"].get("document_type", "unknown")
                }
                for result in results
            ]
            
        except Exception as e:
            logger.error(f"Error retrieving context: {str(e)}")
            return []
    
    async def generate_rag_response(
        self, 
        query: str,
        machine_type: Optional[str] = None
    ) -> Dict[str, Any]:
        """
        Generate a response using RAG with online services.
        """
        try:
            # Retrieve relevant context
            context_chunks = await self.retrieve_context(query, top_k=3, machine_type=machine_type)
            
            # Prepare context text
            context_text = ""
            if context_chunks:
                context_parts = []
                for chunk in context_chunks:
                    context_parts.append(f"From {chunk['title']}:\n{chunk['text']}")
                context_text = "\n\n".join(context_parts)
            
            # Generate AI response
            system_prompt = """You are a machine tool expert assistant. Use the provided context to answer questions accurately.

If you don't know the answer based on the context, say so. Always prioritize safety information."""
            
            messages = [
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": query}
            ]
            
            ai_response = await self.ai_service.chat_completion(
                messages=messages,
                context=context_text
            )
            
            return {
                "response": ai_response["response"],
                "context_used": len(context_chunks),
                "confidence": ai_response["confidence"],
                "model": ai_response["model"]
            }
            
        except Exception as e:
            logger.error(f"Error generating RAG response: {str(e)}")
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Failed to generate response: {str(e)}"
            )

# Create global instance
rag_service = RAGService()

