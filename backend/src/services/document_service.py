import os
import logging
import re
from typing import List, Dict, Any, Optional
from pypdf import PdfReader
import io
from fastapi import HTTPException, status, UploadFile
from datetime import datetime
import hashlib

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class DocumentService:
    def __init__(self):
        self._enabled = True
        self.supported_formats = ['.pdf', '.txt', '.md', '.docx']
        logger.info("Document Processing Service initialized")
    
    def is_enabled(self) -> bool:
        """Check if document service is enabled."""
        return self._enabled
    
    def _extract_metadata(self, text: str, filename: str) -> Dict[str, Any]:
        """Extract metadata from document content."""
        metadata = {
            "filename": filename,
            "file_type": self._get_file_type(filename),
            "extraction_date": datetime.utcnow().isoformat(),
            "content_hash": hashlib.md5(text.encode()).hexdigest(),
            "word_count": len(text.split()),
            "character_count": len(text),
            "estimated_pages": max(1, len(text) // 2000),  # Rough estimate
        }
        
        # Extract technical terms and keywords
        technical_terms = self._extract_technical_terms(text)
        if technical_terms:
            metadata["technical_terms"] = technical_terms
        
        # Extract document structure
        structure = self._analyze_document_structure(text)
        if structure:
            metadata["document_structure"] = structure
        
        return metadata
    
    def _get_file_type(self, filename: str) -> str:
        """Get file type from filename."""
        ext = os.path.splitext(filename.lower())[1]
        return ext if ext in self.supported_formats else "unknown"
    
    def _extract_technical_terms(self, text: str) -> List[str]:
        """Extract technical terms and machine tool related keywords."""
        # Common machine tool and technical terms
        technical_patterns = [
            r'\b(?:CNC|lathe|mill|drill|grinder|saw|press|welder|plasma|laser)\b',
            r'\b(?:tolerance|precision|accuracy|calibration|maintenance|repair)\b',
            r'\b(?:steel|aluminum|titanium|brass|copper|plastic|composite)\b',
            r'\b(?:rpm|feed rate|cutting speed|depth of cut|tool wear)\b',
            r'\b(?:G-code|M-code|programming|automation|robotics)\b',
        ]
        
        terms = set()
        for pattern in technical_patterns:
            matches = re.findall(pattern, text, re.IGNORECASE)
            terms.update(matches)
        
        return list(terms)[:20]  # Limit to top 20 terms
    
    def _analyze_document_structure(self, text: str) -> Dict[str, Any]:
        """Analyze document structure and organization."""
        lines = text.split('\n')
        structure = {
            "has_toc": any('table of contents' in line.lower() for line in lines[:50]),
            "has_chapters": len([line for line in lines if re.match(r'^Chapter \d+', line, re.IGNORECASE)]) > 0,
            "has_sections": len([line for line in lines if re.match(r'^\d+\.\d+', line)]) > 0,
            "has_diagrams": any('figure' in line.lower() or 'diagram' in line.lower() for line in lines),
            "has_tables": any('table' in line.lower() for line in lines),
        }
        
        # Count different types of content
        structure["paragraph_count"] = len([line for line in lines if line.strip() and len(line.strip()) > 50])
        structure["list_count"] = len([line for line in lines if line.strip().startswith(('-', '•', '*', '1.', '2.'))])
        
        return structure
    
    async def extract_text_from_pdf(self, file_content: bytes) -> str:
        """Extract text from PDF file content with enhanced processing."""
        try:
            # Create a PDF reader from bytes
            pdf_file = io.BytesIO(file_content)
            reader = PdfReader(pdf_file)
            
            # Extract text from all pages with better formatting
            text_parts = []
            for page_num, page in enumerate(reader.pages):
                page_text = page.extract_text()
                
                # Clean up common PDF extraction issues
                cleaned_text = self._clean_pdf_text(page_text)
                
                # Add page separator if not empty
                if cleaned_text.strip():
                    text_parts.append(f"--- Page {page_num + 1} ---\n{cleaned_text}")
            
            full_text = "\n\n".join(text_parts)
            logger.info(f"Extracted {len(full_text)} characters from PDF with {len(reader.pages)} pages")
            return full_text.strip()
            
        except Exception as e:
            logger.error(f"Error extracting text from PDF: {str(e)}")
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Failed to extract text from PDF: {str(e)}"
            )
    
    def _clean_pdf_text(self, text: str) -> str:
        """Clean up common PDF extraction artifacts."""
        # Remove excessive whitespace
        text = re.sub(r'\s+', ' ', text)
        
        # Fix common OCR issues
        text = re.sub(r'[|]', 'I', text)  # Common OCR mistake
        text = re.sub(r'[0]', 'O', text)  # Another common mistake
        
        # Remove page headers/footers (common patterns)
        text = re.sub(r'Page \d+ of \d+', '', text)
        text = re.sub(r'\d+', '', text)  # Remove standalone page numbers
        
        return text.strip()
    
    async def process_upload_file(self, file: UploadFile) -> Dict[str, Any]:
        """Process an uploaded file and extract text with enhanced metadata."""
        try:
            # Read file content
            content = await file.read()
            
            # Check file type
            if file.filename.lower().endswith('.pdf'):
                text = await self.extract_text_from_pdf(content)
            elif file.filename.lower().endswith(('.txt', '.md')):
                # For text files, try to decode as text
                try:
                    text = content.decode('utf-8')
                except UnicodeDecodeError:
                    text = content.decode('latin-1')  # Fallback encoding
            else:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=f"Unsupported file type. Supported formats: {', '.join(self.supported_formats)}"
                )
            
            # Extract enhanced metadata
            metadata = self._extract_metadata(text, file.filename)
            
            return {
                "filename": file.filename,
                "content": text,
                "size": len(content),
                "text_length": len(text),
                "metadata": metadata
            }
            
        except HTTPException:
            raise
        except Exception as e:
            logger.error(f"Error processing file: {str(e)}")
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Failed to process file: {str(e)}"
            )
    
    def smart_text_split(self, text: str, chunk_size: int = 500, chunk_overlap: int = 50) -> List[Dict[str, Any]]:
        """Smart text splitting with semantic boundaries and metadata."""
        try:
            chunks = []
            text_length = len(text)
            
            if text_length <= chunk_size:
                return [{
                    "content": text,
                    "chunk_id": 0,
                    "metadata": {"is_complete": True, "chunk_type": "single"}
                }]
            
            start = 0
            chunk_id = 0
            
            while start < text_length:
                end = start + chunk_size
                
                # Smart boundary detection
                if end < text_length:
                    # Priority 1: Sentence boundaries
                    sentence_end = self._find_sentence_boundary(text, start, end)
                    if sentence_end > start:
                        end = sentence_end
                    else:
                        # Priority 2: Paragraph boundaries
                        paragraph_end = self._find_paragraph_boundary(text, start, end)
                        if paragraph_end > start:
                            end = paragraph_end
                        else:
                            # Priority 3: Word boundaries
                            word_end = self._find_word_boundary(text, start, end)
                            if word_end > start:
                                end = word_end
                
                chunk_content = text[start:end].strip()
                if chunk_content:
                    # Determine chunk type
                    chunk_type = self._classify_chunk(chunk_content)
                    
                    chunks.append({
                        "content": chunk_content,
                        "chunk_id": chunk_id,
                        "metadata": {
                            "start_pos": start,
                            "end_pos": end,
                            "chunk_type": chunk_type,
                            "is_complete": end >= text_length,
                            "word_count": len(chunk_content.split()),
                            "has_technical_terms": bool(self._extract_technical_terms(chunk_content))
                        }
                    })
                    chunk_id += 1
                
                # Move start position with overlap
                start = max(start + 1, end - chunk_overlap)
            
            logger.info(f"Smart split text into {len(chunks)} chunks")
            return chunks
            
        except Exception as e:
            logger.error(f"Error in smart text splitting: {str(e)}")
            return [{
                "content": text,
                "chunk_id": 0,
                "metadata": {"is_complete": True, "chunk_type": "fallback"}
            }]
    
    def _find_sentence_boundary(self, text: str, start: int, end: int) -> int:
        """Find the best sentence boundary within a range."""
        # Look for sentence endings
        last_period = text.rfind('.', start, end)
        last_exclamation = text.rfind('!', start, end)
        last_question = text.rfind('?', start, end)
        
        sentence_end = max(last_period, last_exclamation, last_question)
        
        # Ensure it's not an abbreviation (e.g., "Dr.", "Mr.", "U.S.")
        if sentence_end > start:
            # Check if it's followed by a space and capital letter
            if sentence_end + 1 < len(text) and text[sentence_end + 1].isspace():
                if sentence_end + 2 < len(text) and text[sentence_end + 2].isupper():
                    return sentence_end + 1
        
        return sentence_end
    
    def _find_paragraph_boundary(self, text: str, start: int, end: int) -> int:
        """Find paragraph boundary (double newline)."""
        double_newline = text.rfind('\n\n', start, end)
        if double_newline > start:
            return double_newline + 2
        return -1
    
    def _find_word_boundary(self, text: str, start: int, end: int) -> int:
        """Find word boundary."""
        last_space = text.rfind(' ', start, end)
        return last_space if last_space > start else -1
    
    def _classify_chunk(self, chunk: str) -> str:
        """Classify the type of content in a chunk."""
        chunk_lower = chunk.lower()
        
        if any(word in chunk_lower for word in ['procedure', 'step', 'instruction', 'how to']):
            return "procedure"
        elif any(word in chunk_lower for word in ['specification', 'parameter', 'setting', 'configuration']):
            return "specification"
        elif any(word in chunk_lower for word in ['warning', 'caution', 'danger', 'safety']):
            return "safety"
        elif any(word in chunk_lower for word in ['maintenance', 'service', 'repair', 'troubleshooting']):
            return "maintenance"
        elif any(word in chunk_lower for word in ['overview', 'introduction', 'description']):
            return "overview"
        else:
            return "general"
    
    def text_split(self, text: str, chunk_size: int = 500, chunk_overlap: int = 50) -> List[str]:
        """Legacy text split method for backward compatibility."""
        chunks = self.smart_text_split(text, chunk_size, chunk_overlap)
        return [chunk["content"] for chunk in chunks]

# Create global instance
document_service = DocumentService()
