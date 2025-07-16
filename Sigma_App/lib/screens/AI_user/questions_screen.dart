import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:segma/cubits/ai_cubit.dart';
import 'package:segma/utils/colors.dart';

class QuestionsScreen extends StatefulWidget {
  final String condition;

  const QuestionsScreen({super.key, required this.condition});

  @override
  _QuestionsScreenState createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {
  Map<String, String> answers = {};

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    print('📋 Initializing QuestionsScreen for condition: ${widget.condition}');
    final cubit = context.read<AiCubit>();
    cubit.loadQuestions(widget.condition);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.condition[0].toUpperCase()}${widget.condition.substring(1)} Questions',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      ),
      body: BlocConsumer<AiCubit, AIState>(
        listener: (context, state) {
          if (state is AIError) {
            print('❌ AIError: ${state.message}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is AILoaded && state.response != null) {
            print('✅ Prediction received: ${state.response}');
            final isPositive = state.response!.toLowerCase().contains('no') ||
                state.response!.toLowerCase().contains('negative');
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                elevation: 8,
                title: Text(
                  'Prediction Result',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                content: Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: isPositive
                        ? (isDark ? AppColors.darkButtonPrimary : AppColors.lightButtonPrimary)
                        : AppColors.statusOverdue,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    isPositive
                        ? 'Good news! Based on your answers, you are unlikely to have ${widget.condition}. Keep maintaining a healthy lifestyle!'
                        : 'Warning: You may have ${widget.condition}. Please consult a doctor immediately for a professional diagnosis.',
                    style: TextStyle(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      context.read<AiCubit>().resetState();
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: Text(
                      'OK',
                      style: TextStyle(
                        color: isDark ? AppColors.darkButtonPrimary : AppColors.lightButtonPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AILoading) {
            print('⏳ AILoading state');
            return const Center(child: CircularProgressIndicator());
          } else if (state is AIError) {
            print('❌ AIError state: ${state.message}');
            return Center(child: Text(state.message));
          } else if (state is AILoaded) {
            print('✅ AILoaded state with ${state.questions.length} questions');
            if (state.questions.isEmpty) {
              print('⚠️ No questions available');
              return const Center(child: Text('No questions available'));
            }
            return Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: state.questions.length,
                      itemBuilder: (context, index) {
                        final question = state.questions[index];
                        final feature = question['feature'] as String;
                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                          margin: EdgeInsets.symmetric(vertical: 8.h),
                          color: isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground,
                          child: Padding(
                            padding: EdgeInsets.all(16.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  question['question'] as String,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                SizedBox(height: 8.h),
                                if (question['inputType'] == 'dropdown')
                                  DropdownButton<String>(
                                    isExpanded: true,
                                    value: answers[feature],
                                    hint: const Text('Select an option'),
                                    items: (question['potentialInputs'] as List<dynamic>)
                                        .map<DropdownMenuItem<String>>((value) {
                                      return DropdownMenuItem<String>(
                                        value: value as String,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        answers[feature] = value!;
                                        print('📝 Answer updated for $feature: $value');
                                      });
                                    },
                                  )
                                else if (question['inputType'] == 'number')
                                  TextField(
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      setState(() {
                                        answers[feature] = value;
                                        print('📝 Answer updated for $feature: $value');
                                      });
                                    },
                                    decoration: InputDecoration(
                                      hintText: question['potentialInputs'] as String,
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                                      filled: true,
                                      fillColor: isDark ? AppColors.darkSearchBackground : AppColors.lightSearchBackground,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 16.h),
                    child: ElevatedButton(
                      onPressed: answers.length == state.questions.length &&
                              answers.values.every((answer) => answer.isNotEmpty)
                          ? () {
                              print('🚀 Submitting answers: $answers');
                              context.read<AiCubit>().submitAnswers(widget.condition, answers);
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? AppColors.darkButtonPrimary : AppColors.lightButtonPrimary,
                      ),
                      child: Text(
                        'Submit Answers',
                        style: TextStyle(
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          print('⏳ Initial state, waiting...');
          return const Center(child: Text('Please wait...'));
        },
      ),
    );
  }
}