import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:segma/cubits/ai_cubit.dart';
import 'package:segma/utils/colors.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<int> _typingAnimation;

  @override
  void initState() {
    super.initState();
    if (context.read<AiCubit>().state is! AILoaded) {
      context.read<AiCubit>().emit(const AILoaded());
    }
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
    _typingAnimation = IntTween(begin: 0, end: 3).animate(_animationController);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chatbot with Sigma',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      ),
      body: BlocConsumer<AiCubit, AIState>(
        listener: (context, state) {
          if (state is AIError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is AILoaded && state.messages != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_scrollController.hasClients) {
                _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              }
            });
          } else if (state is AIChatLoading && state.messages != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_scrollController.hasClients) {
                _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              }
            });
          }
        },
        builder: (context, state) {
          if (state is AILoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AIError) {
            return Center(child: Text(state.message));
          } else if (state is AILoaded || state is AIChatLoading) {
            final messages = (state is AILoaded ? state.messages : (state as AIChatLoading).messages) ?? [];
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
                    itemCount: messages.length + (state is AIChatLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index < messages.length) {
                        final message = messages[index];
                        return ListTile(
                          title: Align(
                            alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
                            child: Card(
                              color: message.isUser
                                  ? (isDark ? AppColors.darkButtonPrimary : AppColors.lightButtonPrimary)
                                  : (isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground),
                              child: Padding(
                                padding: EdgeInsets.all(8.w),
                                child: Text(
                                  message.text,
                                  style: TextStyle(
                                    color: message.isUser
                                        ? AppColors.lightBackground
                                        : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      } else {
                        return ListTile(
                          title: Align(
                            alignment: Alignment.centerLeft,
                            child: Card(
                              color: isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground,
                              child: Padding(
                                padding: EdgeInsets.all(8.w),
                                child: AnimatedBuilder(
                                  animation: _typingAnimation,
                                  builder: (context, child) {
                                    String dots = '.' * (_typingAnimation.value + 1);
                                    return Text(
                                      'Typing$dots',
                                      style: TextStyle(
                                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.w),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                            filled: true,
                            fillColor: isDark ? AppColors.darkSearchBackground : AppColors.lightSearchBackground,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.send, color: isDark ? AppColors.darkIcon : AppColors.lightIcon),
                        onPressed: () {
                          if (_controller.text.isNotEmpty) {
                            context.read<AiCubit>().sendMessage(_controller.text);
                            _controller.clear();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
          return const Center(child: Text('Start chatting with Sigma!'));
        },
      ),
    );
  }
}