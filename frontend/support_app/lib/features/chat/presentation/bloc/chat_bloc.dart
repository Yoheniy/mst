import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/chat_entities.dart';
import '../../domain/repositories/chat_repository.dart';

// Events
abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class LoadChatSessions extends ChatEvent {}

class CreateChatSession extends ChatEvent {
  final String title;
  final int? machineId;

  const CreateChatSession(this.title, {this.machineId});

  @override
  List<Object?> get props => [title, machineId];
}

class LoadSessionMessages extends ChatEvent {
  final int sessionId;

  const LoadSessionMessages(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}

class SendMessage extends ChatEvent {
  final String message;
  final int? sessionId;
  final String? context;
  final String? machineType;
  final String? chunkTypeFilter;

  const SendMessage(
    this.message, {
    this.sessionId,
    this.context,
    this.machineType,
    this.chunkTypeFilter,
  });

  @override
  List<Object?> get props =>
      [message, sessionId, context, machineType, chunkTypeFilter];
}

class DeleteSession extends ChatEvent {
  final int sessionId;

  const DeleteSession(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}

// States
abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatSessionsLoaded extends ChatState {
  final List<ChatSession> sessions;

  const ChatSessionsLoaded(this.sessions);

  @override
  List<Object?> get props => [sessions];
}

class SessionMessagesLoaded extends ChatState {
  final int sessionId;
  final List<ChatMessage> messages;

  const SessionMessagesLoaded(this.sessionId, this.messages);

  @override
  List<Object?> get props => [sessionId, messages];
}

class MessageSent extends ChatState {
  final AIChatResponse response;
  final int sessionId;

  const MessageSent(this.response, this.sessionId);

  @override
  List<Object?> get props => [response, sessionId];
}

class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _chatRepository;

  ChatBloc(this._chatRepository) : super(ChatInitial()) {
    on<LoadChatSessions>(_onLoadChatSessions);
    on<CreateChatSession>(_onCreateChatSession);
    on<LoadSessionMessages>(_onLoadSessionMessages);
    on<SendMessage>(_onSendMessage);
    on<DeleteSession>(_onDeleteSession);
  }

  Future<void> _onLoadChatSessions(
    LoadChatSessions event,
    Emitter<ChatState> emit,
  ) async {
    try {
      emit(ChatLoading());
      final sessions = await _chatRepository.getUserSessions();
      emit(ChatSessionsLoaded(sessions));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onCreateChatSession(
    CreateChatSession event,
    Emitter<ChatState> emit,
  ) async {
    try {
      emit(ChatLoading());
      await _chatRepository.createChatSession(
        event.title,
        machineId: event.machineId,
      );
      final sessions = await _chatRepository.getUserSessions();
      emit(ChatSessionsLoaded(sessions));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onLoadSessionMessages(
    LoadSessionMessages event,
    Emitter<ChatState> emit,
  ) async {
    try {
      emit(ChatLoading());
      final messages =
          await _chatRepository.getSessionMessages(event.sessionId);
      emit(SessionMessagesLoaded(event.sessionId, messages));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatState> emit,
  ) async {
    try {
      emit(ChatLoading());
      final response = await _chatRepository.sendMessage(
        event.message,
        sessionId: event.sessionId,
        context: event.context,
        machineType: event.machineType,
        chunkTypeFilter: event.chunkTypeFilter,
      );
      emit(MessageSent(response, response.sessionId));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onDeleteSession(
    DeleteSession event,
    Emitter<ChatState> emit,
  ) async {
    try {
      emit(ChatLoading());
      await _chatRepository.deleteSession(event.sessionId);
      final sessions = await _chatRepository.getUserSessions();
      emit(ChatSessionsLoaded(sessions));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }
}
