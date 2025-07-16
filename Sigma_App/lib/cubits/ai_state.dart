part of 'ai_cubit.dart';

abstract class AIState extends Equatable {
  const AIState();

  @override
  List<Object?> get props => [];
}

class AIInitial extends AIState {}

class AILoading extends AIState {}

class AILoaded extends AIState {
  final List<Map<String, dynamic>> questions;
  final String? response;
  final List<ChatbotMessage>? messages;

  const AILoaded({
    this.questions = const [],
    this.response,
    this.messages,
  });

  @override
  List<Object?> get props => [questions, response, messages];
}

class AIChatLoading extends AIState {
  final List<Map<String, dynamic>> questions;
  final String? response;
  final List<ChatbotMessage>? messages;

  const AIChatLoading({
    this.questions = const [],
    this.response,
    this.messages,
  });

  @override
  List<Object?> get props => [questions, response, messages];
}

class AIError extends AIState {
  final String message;

  const AIError({required this.message});

  @override
  List<Object?> get props => [message];
}

class ChatbotMessage {
  final String text;
  final bool isUser;

  ChatbotMessage({required this.text, required this.isUser});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatbotMessage &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          isUser == other.isUser;

  @override
  int get hashCode => text.hashCode ^ isUser.hashCode;
}