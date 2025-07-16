import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:segma/services/ai_service.dart';

part 'ai_state.dart';

class AiCubit extends Cubit<AIState> {
  AiCubit() : super(AIInitial());

  void loadQuestions(String condition) async {
    print('📋 Loading questions for condition: $condition');
    emit(AILoading());
    try {
      final questions = await AIService.getQuestions(condition);
      print('✅ Questions loaded: ${questions.map((q) => q['feature']).toList()}');
      emit(AILoaded(questions: questions));
    } catch (e) {
      print('❌ Error loading questions: $e');
      emit(AIError(message: 'Failed to load questions: $e'));
    }
  }

  void submitAnswers(String condition, Map<String, String> answers) async {
    print('📤 Submitting answers for condition: $condition');
    print('📥 Raw answers: $answers');
    emit(AILoading());
    try {
      final response = await AIService.predict(condition, answers);
      print('✅ Prediction response: $response');
      final currentState = state is AILoaded ? state as AILoaded : null;
      emit(AILoaded(
        questions: currentState?.questions ?? [],
        response: response,
        messages: currentState?.messages,
      ));
    } catch (e) {
      print('❌ Error submitting answers: $e');
      emit(AIError(message: 'Failed to get prediction: $e'));
    }
  }

  Future<void> sendMessage(String message) async {
    print('💬 Sending chatbot message: $message');
    if (message.isEmpty) {
      print('⚠️ Empty message, ignoring');
      return;
    }
    try {
      final currentState = state is AILoaded ? state as AILoaded : null;
      final messages = List<ChatbotMessage>.from(currentState?.messages ?? [])
        ..add(ChatbotMessage(text: message, isUser: true));
      print('📋 Updated messages (user): ${messages.map((m) => m.text).toList()}');
      emit(AIChatLoading(
        questions: currentState?.questions ?? [],
        response: currentState?.response,
        messages: messages,
      ));

      final response = await AIService.sendMessage(message);
      print('✅ Chatbot response: $response');
      final updatedState = state is AIChatLoading ? state as AIChatLoading : null;
      final updatedMessages = List<ChatbotMessage>.from(updatedState?.messages ?? [])
        ..add(ChatbotMessage(text: response, isUser: false));
      print('📋 Updated messages (bot): ${updatedMessages.map((m) => m.text).toList()}');
      emit(AILoaded(
        questions: updatedState?.questions ?? [],
        response: updatedState?.response,
        messages: updatedMessages,
      ));
    } catch (e) {
      print('❌ Error sending chatbot message: $e');
      final currentState = state is AIChatLoading ? state as AIChatLoading : null;
      final messages = List<ChatbotMessage>.from(currentState?.messages ?? [])
        ..add(ChatbotMessage(text: 'Error: Could not get response - $e', isUser: false));
      print('📋 Updated messages (error): ${messages.map((m) => m.text).toList()}');
      emit(AILoaded(
        questions: currentState?.questions ?? [],
        response: currentState?.response,
        messages: messages,
      ));
      emit(AIError(message: 'Failed to send message: $e'));
    }
  }

  void resetState() {
    print('🔄 Resetting AI state');
    emit(AIInitial());
  }
}