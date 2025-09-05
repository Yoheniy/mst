from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, status
from sqlmodel import Session, select
from datetime import datetime

from ..model.models import (
    ChatMessage, ChatSession, 
    ChatSessionCreate, ChatSessionResponse,
    MessageCreate, MessageResponse,
    AIChatRequest, AIChatResponse,
    AdvancedChatRequest, MessageRole
)
from ..services.rag_service import rag_service
from ..routes.utils.database import get_session
from ..routes.utils.auth import get_current_user
from ..model.models import User

router = APIRouter(
    prefix="/chat",
    tags=["Chat"]
)

@router.post("/sessions/", response_model=ChatSessionResponse, status_code=status.HTTP_201_CREATED)
async def create_chat_session(
    session_data: ChatSessionCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_session)
):
    try:
        # Create new chat session
        chat_session = ChatSession(
            user_id=current_user.user_id,
            machine_id=session_data.machine_id,
            title=session_data.title or f"Chat Session {datetime.utcnow().strftime('%Y-%m-%d %H:%M')}"
        )
        
        db.add(chat_session)
        db.commit()
        db.refresh(chat_session)
        
        return ChatSessionResponse(
            session_id=chat_session.session_id,
            user_id=chat_session.user_id,
            machine_id=chat_session.machine_id,
            title=chat_session.title,
            created_at=chat_session.created_at,
            updated_at=chat_session.updated_at,
            is_active=chat_session.is_active,
            messages=[]
        )
        
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to create chat session: {str(e)}"
        )

@router.get("/sessions/", response_model=List[ChatSessionResponse])
async def get_user_sessions(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_session)
):
    """Get all chat sessions for the current user."""
    try:
        sessions = db.exec(
            select(ChatSession)
            .where(ChatSession.user_id == current_user.user_id)
            .order_by(ChatSession.updated_at.desc())
        ).all()
        
        return [
            ChatSessionResponse(
                session_id=session.session_id,
                user_id=session.user_id,
                machine_id=session.machine_id,
                title=session.title,
                created_at=session.created_at,
                updated_at=session.updated_at,
                is_active=session.is_active,
                messages=[]
            )
            for session in sessions
        ]
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to retrieve chat sessions: {str(e)}"
        )

@router.get("/sessions/{session_id}/messages/", response_model=List[MessageResponse])
async def get_session_messages(
    session_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_session)
):
    """Get all messages for a specific chat session."""
    try:
        # Verify session belongs to user
        session = db.get(ChatSession, session_id)
        if not session or session.user_id != current_user.user_id:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Chat session not found"
            )
        
        messages = db.exec(
            select(ChatMessage)
            .where(ChatMessage.session_id == session_id)
            .order_by(ChatMessage.timestamp.asc())
        ).all()
        
        return [
            MessageResponse(
                message_id=msg.message_id,
                session_id=msg.session_id,
                role=msg.role,
                content=msg.content,
                timestamp=msg.timestamp,
                message_metadata=msg.message_metadata
            )
            for msg in messages
        ]
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to retrieve messages: {str(e)}"
        )

@router.post("/ai/chat", response_model=AIChatResponse)
async def chat_with_ai(
    chat_request: AIChatRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_session)
):
    """Send a message to AI and get response."""
    try:
        # Get or create chat session
        if chat_request.session_id:
            session = db.get(ChatSession, chat_request.session_id)
            if not session or session.user_id != current_user.user_id:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail="Chat session not found"
                )
        else:
            # Create new session
            session = ChatSession(
                user_id=current_user.user_id,
                title=f"Chat Session {datetime.utcnow().strftime('%Y-%m-%d %H:%M')}"
            )
            db.add(session)
            db.commit()
            db.refresh(session)
        
        # Save user message
        user_message = ChatMessage(
            session_id=session.session_id,
            role=MessageRole.USER,
            content=chat_request.message
        )
        db.add(user_message)
        db.commit()
        db.refresh(user_message)
        
        # Get chat history for context
        history_messages = db.exec(
            select(ChatMessage)
            .where(ChatMessage.session_id == session.session_id)
            .order_by(ChatMessage.timestamp.desc())
            .limit(10)  # Last 10 messages for context
        ).all()
        
        # Prepare messages for AI
        ai_messages = []
        for msg in reversed(history_messages):  # Reverse to get chronological order
            ai_messages.append({
                "role": msg.role.value,
                "content": msg.content
            })
        
        # Get machine type from session for context filtering
        machine_type = None
        if session.machine_id:
            # You could fetch machine details here for filtering
            # For now, we'll use the general approach
            pass
        
        # Get AI response using RAG
        try:
            rag_response = await rag_service.generate_rag_response(
                query=chat_request.message,
                machine_type=machine_type,
                context_limit=3
            )
            
            ai_response_data = {
                "response": rag_response["response"],
                "model": rag_response["model"],
                "usage": rag_response["usage"],
                "confidence": rag_response["confidence"]
            }
            
        except Exception as e:
            # Fallback to basic AI response if RAG fails
            print(f"RAG failed, using fallback: {str(e)}")
            ai_response_data = {
                "response": f"I understand you're asking about: {chat_request.message}. I'm currently experiencing some technical difficulties accessing my knowledge base, but I'm here to help with machine tool technical support. Could you please provide more specific details about your machine and the issue you're facing?",
                "model": "fallback-model",
                "usage": {"prompt_tokens": 10, "completion_tokens": 20, "total_tokens": 30},
                "confidence": 0.3
            }
        # Save AI response
        ai_message = ChatMessage(
            session_id=session.session_id,
            role=MessageRole.ASSISTANT,
            content=ai_response_data["response"],
            message_metadata={
                "model": ai_response_data["model"],
                "usage": ai_response_data["usage"],
                "confidence": ai_response_data["confidence"]
            }
        )
        db.add(ai_message)
        
        # Update session timestamp
        session.updated_at = datetime.utcnow()
        db.add(session)
        
        db.commit()
        db.refresh(ai_message)
        
        return AIChatResponse(
            response=ai_response_data["response"],
            session_id=session.session_id,
            message_id=ai_message.message_id,
            confidence=ai_response_data["confidence"],
            usage=ai_response_data["usage"],
            model=ai_response_data["model"]
        )
        
    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to process chat request: {str(e)}"
        )