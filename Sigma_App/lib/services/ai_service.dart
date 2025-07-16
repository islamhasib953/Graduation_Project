import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class AIService {
  static const String baseUrl = 'http://35.173.178.21:8000';

  static Future<List<Map<String, dynamic>>> getQuestions(String condition) async {
    print('📋 Fetching questions for condition: $condition');
    switch (condition.toLowerCase()) {
      case 'stroke':
        return [
          {
            'feature': 'gender',
            'question': 'What is your gender?',
            'inputType': 'dropdown',
            'potentialInputs': ['Male', 'Female'],
            'modelEncoding': 'Use as is (string)',
            'backendHandling': 'Validate selection is either "Male" or "Female". Send as string.'
          },
          {
            'feature': 'age',
            'question': 'How old are you?',
            'inputType': 'number',
            'potentialInputs': 'Any number between 0 and 100 (e.g., 40, 67.5)',
            'modelEncoding': 'Use as is (float)',
            'backendHandling': 'Validate as a positive number <= 100. Convert to float. Reject negative or unrealistic ages (e.g., > 100).'
          },
          {
            'feature': 'hypertension',
            'question': 'Do you have hypertension?',
            'inputType': 'dropdown',
            'potentialInputs': ['Yes', 'No'],
            'modelEncoding': {'Yes': 1, 'No': 0},
            'backendHandling': 'Validate selection is "Yes" or "No". Encode as 1 or 0.'
          },
          {
            'feature': 'heart_disease',
            'question': 'Do you have heart disease?',
            'inputType': 'dropdown',
            'potentialInputs': ['Yes', 'No'],
            'modelEncoding': {'Yes': 1, 'No': 0},
            'backendHandling': 'Validate selection is "Yes" or "No". Encode as 1 or 0.'
          },
          {
            'feature': 'ever_married',
            'question': 'Have you ever been married?',
            'inputType': 'dropdown',
            'potentialInputs': ['Yes', 'No'],
            'modelEncoding': 'Use as is (string)',
            'backendHandling': 'Validate selection is "Yes" or "No". Send as string.'
          },
          {
            'feature': 'work_type',
            'question': 'What is your work type?',
            'inputType': 'dropdown',
            'potentialInputs': ['Private', 'Self-employed', 'Govt_job', 'Children', 'Never_worked'],
            'modelEncoding': 'Use as is (string)',
            'backendHandling': 'Validate selection is one of the listed options. Send as string.'
          },
          {
            'feature': 'Residence_type',
            'question': 'Where do you live?',
            'inputType': 'dropdown',
            'potentialInputs': ['Urban', 'Rural'],
            'modelEncoding': 'Use as is (string)',
            'backendHandling': 'Validate selection is "Urban" or "Rural". Send as string.'
          },
          {
            'feature': 'avg_glucose_level',
            'question': 'What is your average glucose level (mg/dL)?',
            'inputType': 'number',
            'potentialInputs': 'Any number between 50 and 300 (e.g., 171.23, 228.69)',
            'modelEncoding': 'Use as is (float)',
            'backendHandling': 'Validate as a positive number between 50 and 300. Convert to float. Reject unrealistic values (e.g., < 50 or > 300).'
          },
          {
            'feature': 'bmi',
            'question': 'What is your BMI?',
            'inputType': 'number',
            'potentialInputs': 'Any number between 10 and 60 (e.g., 36.6, 34.4) or leave blank',
            'modelEncoding': 'Use as is (float); if missing, impute with mean (28.893237)',
            'backendHandling': 'Validate as a positive number between 10 and 60 or allow null. Convert to float. If null, impute with mean BMI (28.893237).'
          },
          {
            'feature': 'smoking_status',
            'question': 'What is your smoking status?',
            'inputType': 'dropdown',
            'potentialInputs': ['Never smoked', 'Formerly smoked', 'Smokes', 'Unknown'],
            'modelEncoding': 'Use as is (string)',
            'backendHandling': 'Validate selection is one of the listed options. Send as string.'
          },
        ];
      case 'autism':
        return [
          {
            'feature': 'A1',
            'question': 'Does the individual notice small sounds when others do not?',
            'inputType': 'dropdown',
            'potentialInputs': ['Yes', 'No'],
            'modelEncoding': {'Yes': 1, 'No': 0},
            'backendHandling': 'Validate selection is "Yes" or "No". Encode as 1 or 0.'
          },
          {
            'feature': 'A2',
            'question': 'Can the individual focus on one thing for a long time?',
            'inputType': 'dropdown',
            'potentialInputs': ['Yes', 'No'],
            'modelEncoding': {'Yes': 1, 'No': 0},
            'backendHandling': 'Validate selection is "Yes" or "No". Encode as 1 or 0.'
          },
          {
            'feature': 'A3',
            'question': 'Does the individual find it hard to switch between activities?',
            'inputType': 'dropdown',
            'potentialInputs': ['Yes', 'No'],
            'modelEncoding': {'Yes': 1, 'No': 0},
            'backendHandling': 'Validate selection is "Yes" or "No". Encode as 1 or 0.'
          },
          {
            'feature': 'A4',
            'question': 'Does the individual get upset by minor changes?',
            'inputType': 'dropdown',
            'potentialInputs': ['Yes', 'No'],
            'modelEncoding': {'Yes': 1, 'No': 0},
            'backendHandling': 'Validate selection is "Yes" or "No". Encode as 1 or 0.'
          },
          {
            'feature': 'A5',
            'question': 'Does the individual have highly specific interests?',
            'inputType': 'dropdown',
            'potentialInputs': ['Yes', 'No'],
            'modelEncoding': {'Yes': 1, 'No': 0},
            'backendHandling': 'Validate selection is "Yes" or "No". Encode as 1 or 0.'
          },
          {
            'feature': 'A6',
            'question': 'Does the individual repeat actions over and over?',
            'inputType': 'dropdown',
            'potentialInputs': ['Yes', 'No'],
            'modelEncoding': {'Yes': 1, 'No': 0},
            'backendHandling': 'Validate selection is "Yes" or "No". Encode as 1 or 0.'
          },
          {
            'feature': 'A7',
            'question': 'Does the individual find it hard to understand others’ feelings?',
            'inputType': 'dropdown',
            'potentialInputs': ['Yes', 'No'],
            'modelEncoding': {'Yes': 1, 'No': 0},
            'backendHandling': 'Validate selection is "Yes" or "No". Encode as 1 or 0.'
          },
          {
            'feature': 'A8',
            'question': 'Does the individual struggle with social interactions?',
            'inputType': 'dropdown',
            'potentialInputs': ['Yes', 'No'],
            'modelEncoding': {'Yes': 1, 'No': 0},
            'backendHandling': 'Validate selection is "Yes" or "No". Encode as 1 or 0.'
          },
          {
            'feature': 'A9',
            'question': 'Does the individual prefer routines over spontaneity?',
            'inputType': 'dropdown',
            'potentialInputs': ['Yes', 'No'],
            'modelEncoding': {'Yes': 1, 'No': 0},
            'backendHandling': 'Validate selection is "Yes" or "No". Encode as 1 or 0.'
          },
          {
            'feature': 'A10',
            'question': 'Does the individual have unusual sensory responses?',
            'inputType': 'dropdown',
            'potentialInputs': ['Yes', 'No'],
            'modelEncoding': {'Yes': 1, 'No': 0},
            'backendHandling': 'Validate selection is "Yes" or "No". Encode as 1 or 0.'
          },
          {
            'feature': 'Age_Mons',
            'question': 'What is the individual’s age in months?',
            'inputType': 'number',
            'potentialInputs': 'Any number between 0 and 360 (e.g., 24, 36)',
            'modelEncoding': 'Use as is (integer)',
            'backendHandling': 'Validate as a positive integer <= 360. Convert to integer. Reject negative or unrealistic ages (e.g., > 360).'
          },
          {
            'feature': 'Sex',
            'question': 'What is the individual’s sex?',
            'inputType': 'dropdown',
            'potentialInputs': ['Male', 'Female'],
            'modelEncoding': {'Male': 'm', 'Female': 'f'},
            'backendHandling': 'Validate selection is "Male" or "Female". Encode as "m" or "f".'
          },
          {
            'feature': 'Ethnicity',
            'question': 'What is the individual’s ethnicity?',
            'inputType': 'dropdown',
            'potentialInputs': ['White European', 'Asian', 'Black', 'Hispanic', 'Middle Eastern', 'South Asian', 'Others'],
            'modelEncoding': 'Use as is (string)',
            'backendHandling': 'Validate selection is one of the listed options. Send as string.'
          },
          {
            'feature': 'Jaundice',
            'question': 'Was the individual born with jaundice?',
            'inputType': 'dropdown',
            'potentialInputs': ['Yes', 'No'],
            'modelEncoding': {'Yes': 'yes', 'No': 'no'},
            'backendHandling': 'Validate selection is "Yes" or "No". Encode as "yes" or "no".'
          },
          {
            'feature': 'Family_mem_with_ASD',
            'question': 'Does the individual have a family member with ASD?',
            'inputType': 'dropdown',
            'potentialInputs': ['Yes', 'No'],
            'modelEncoding': {'Yes': 'yes', 'No': 'no'},
            'backendHandling': 'Validate selection is "Yes" or "No". Encode as "yes" or "no".'
          },
          {
            'feature': 'Who_completed_the_test',
            'question': 'Who completed this test?',
            'inputType': 'dropdown',
            'potentialInputs': ['Parent', 'Self', 'Caregiver', 'Professional'],
            'modelEncoding': 'Use as is (string)',
            'backendHandling': 'Validate selection is one of the listed options. Send as string.'
          },
        ];
      case 'asthma':
        return [
          {
            'feature': 'Age',
            'question': 'What is your age?',
            'inputType': 'number',
            'potentialInputs': 'Any number between 0 and 120 (e.g., 5, 40)',
            'modelEncoding': 'Use as is (integer)',
            'backendHandling': 'Validate as a positive integer <= 120. Convert to integer. Reject negative or unrealistic ages (e.g., > 120).'
          },
          {
            'feature': 'Gender',
            'question': 'What is your gender?',
            'inputType': 'dropdown',
            'potentialInputs': ['Male', 'Female', 'Other'],
            'modelEncoding': {'Male': 0, 'Female': 1, 'Other': 2},
            'backendHandling': 'Validate selection is "Male", "Female", or "Other". Encode as 0, 1, or 2.'
          },
          {
            'feature': 'Ethnicity',
            'question': 'What is your ethnicity?',
            'inputType': 'dropdown',
            'potentialInputs': ['Asian', 'Black', 'White', 'Hispanic', 'Other'],
            'modelEncoding': {'Asian': 0, 'Black': 1, 'White': 2, 'Hispanic': 3, 'Other': 4},
            'backendHandling': 'Validate selection is one of the listed options. Encode as 0-4.'
          },
          {
            'feature': 'EducationLevel',
            'question': 'What is your highest level of education?',
            'inputType': 'dropdown',
            'potentialInputs': ['None', 'High School', 'College', 'Graduate'],
            'modelEncoding': {'None': 0, 'High School': 1, 'College': 2, 'Graduate': 3},
            'backendHandling': 'Validate selection is one of the listed options. Encode as 0-3.'
          },
          {
            'feature': 'BMI',
            'question': 'What is your BMI?',
            'inputType': 'number',
            'potentialInputs': 'Any number between 10.0 and 50.0 (e.g., 15.84, 36.6)',
            'modelEncoding': 'Use as is (float)',
            'backendHandling': 'Validate as a positive number between 10 and 50. Convert to float. Reject unrealistic values (e.g., < 10 or > 50).'
          },
          {
            'feature': 'Smoking',
            'question': 'Do you smoke?',
            'inputType': 'dropdown',
            'potentialInputs': ['Yes', 'No'],
            'modelEncoding': {'No': 0, 'Yes': 1},
            'backendHandling': 'Validate selection is "Yes" or "No". Encode as 0 or 1.'
          },
          {
            'feature': 'PhysicalActivity',
            'question': 'How many hours per week do you engage in physical activity?',
            'inputType': 'number',
            'potentialInputs': 'Any number between 0 and 10 (e.g., 0.89, 5)',
            'modelEncoding': 'Use as is (float)',
            'backendHandling': 'Validate as a positive number between 0 and 10. Convert to float. Reject values > 10.'
          },
          {
            'feature': 'DietQuality',
            'question': 'How would you rate the quality of your diet (0-10)?',
            'inputType': 'number',
            'potentialInputs': 'Any number between 0 and 10 (e.g., 5.48, 7)',
            'modelEncoding': 'Use as is (float)',
            'backendHandling': 'Validate as a positive number between 0 and 10. Convert to float. Reject values > 10.'
          },
          {
            'feature': 'SleepQuality',
            'question': 'How would you rate the quality of your sleep (0-10)?',
            'inputType': 'number',
            'potentialInputs': 'Any number between 0 and 10 (e.g., 8.70, 8)',
            'modelEncoding': 'Use as is (float)',
            'backendHandling': 'Validate as a positive number between 0 and 10. Convert to float. Reject values > 10.'
          },
          {
            'feature': 'PollutionExposure',
            'question': 'How would you rate your exposure to air pollution (0-10)?',
            'inputType': 'number',
            'potentialInputs': 'Any number between 0 and 10 (e.g., 7.38, 3)',
            'modelEncoding': 'Use as is (float)',
            'backendHandling': 'Validate as a positive number between 0 and 10. Convert to float. Reject values > 10.'
          },
          {
            'feature': 'PollenExposure',
            'question': 'How would you rate your exposure to pollen (0-10)?',
            'inputType': 'number',
            'potentialInputs': 'Any number between 0 and 10 (e.g., 2.85, 4)',
            'modelEncoding': 'Use as is (float)',
            'backendHandling': 'Validate as a positive number between 0 and 10. Convert to float. Reject values > 10.'
          },
          {
            'feature': 'DustExposure',
            'question': 'How would you rate your exposure to dust (0-10)?',
            'inputType': 'number',
            'potentialInputs': 'Any number between 0 and 10 (e.g., 0.97, 5)',
            'modelEncoding': 'Use as is (float)',
            'backendHandling': 'Validate as a positive number between 0 and 10. Convert to float. Reject values > 10.'
          },
          {
            'feature': 'PetAllergy',
            'question': 'Do you have a pet allergy?',
            'inputType': 'dropdown',
            'potentialInputs': ['Yes', 'No'],
            'modelEncoding': {'No': 0, 'Yes': 1},
            'backendHandling': 'Validate selection is "Yes" or "No". Encode as 0 or 1.'
          },
          {
            'feature': 'FamilyHistoryAsthma',
            'question': 'Do you have a family history of asthma?',
            'inputType': 'dropdown',
            'potentialInputs': ['Yes', 'No'],
            'modelEncoding': {'No': 0, 'Yes': 1},
            'backendHandling': 'Validate selection is "Yes" or "No". Encode as 0 or 1.'
          },
          {
            'feature': 'HistoryOfAllergies',
            'question': 'Do you have a history of allergies?',
            'inputType': 'dropdown',
            'potentialInputs': ['Yes', 'No'],
            'modelEncoding': {'No': 0, 'Yes': 1},
            'backendHandling': 'Validate selection is "Yes" or "No". Encode as 0 or 1.'
          },
          {
            'feature': 'Eczema',
            'question': 'Do you have eczema?',
            'inputType': 'dropdown',
            'potentialInputs': ['Yes', 'No'],
            'modelEncoding': {'No': 0, 'Yes': 1},
            'backendHandling': 'Validate selection is "Yes" or "No". Encode as 0 or 1.'
          },
          {
            'feature': 'HayFever',
            'question': 'Do you have hay fever?',
            'inputType': 'dropdown',
            'potentialInputs': ['Yes', 'No'],
            'modelEncoding': {'No': 0, 'Yes': 1},
            'backendHandling': 'Validate selection is "Yes" or "No". Encode as 0 or 1.'
          },
          {
            'feature': 'GastroesophagealReflux',
            'question': 'Do you have gastroesophageal reflux disease (GERD)?',
            'inputType': 'dropdown',
            'potentialInputs': ['Yes', 'No'],
            'modelEncoding': {'No': 0, 'Yes': 1},
            'backendHandling': 'Validate selection is "Yes" or "No". Encode as 0 or 1.'
          },
          {
            'feature': 'LungFunctionFEV1',
            'question': 'What is your FEV1 lung function value (in liters)?',
            'inputType': 'number',
            'potentialInputs': 'Any number between 0.5 and 6.0 (e.g., 1.36, 3.2)',
            'modelEncoding': 'Use as is (float)',
            'backendHandling': 'Validate as a positive number between 0.5 and 6.0. Convert to float. Reject unrealistic values (e.g., < 0.5 or > 6.0).'
          },
          {
            'feature': 'LungFunctionFVC',
            'question': 'What is your FVC lung function value (in liters)?',
            'inputType': 'number',
            'potentialInputs': 'Any number between 1.0 and 8.0 (e.g., 4.94, 4.1)',
            'modelEncoding': 'Use as is (float)',
            'backendHandling': 'Validate as a positive number between 1.0 and 8.0. Convert to float. Reject unrealistic values (e.g., < 1.0 or > 8.0).'
          },
          {
            'feature': 'Wheezing',
            'question': 'Do you experience wheezing?',
            'inputType': 'dropdown',
            'potentialInputs': ['Yes', 'No'],
            'modelEncoding': {'No': 0, 'Yes': 1},
            'backendHandling': 'Validate selection is "Yes" or "No". Encode as 0 or 1.'
          },
          {
            'feature': 'ShortnessOfBreath',
            'question': 'Do you experience shortness of breath?',
            'inputType': 'dropdown',
            'potentialInputs': ['Yes', 'No'],
            'modelEncoding': {'No': 0, 'Yes': 1},
            'backendHandling': 'Validate selection is "Yes" or "No". Encode as 0 or 1.'
          },
          {
            'feature': 'ChestTightness',
            'question': 'Do you experience chest tightness?',
            'inputType': 'dropdown',
            'potentialInputs': ['Yes', 'No'],
            'modelEncoding': {'No': 0, 'Yes': 1},
            'backendHandling': 'Validate selection is "Yes" or "No". Encode as 0 or 1.'
          },
          {
            'feature': 'Coughing',
            'question': 'Do you experience frequent coughing?',
            'inputType': 'dropdown',
            'potentialInputs': ['Yes', 'No'],
            'modelEncoding': {'No': 0, 'Yes': 1},
            'backendHandling': 'Validate selection is "Yes" or "No". Encode as 0 or 1.'
          },
          {
            'feature': 'NighttimeSymptoms',
            'question': 'Do you experience asthma symptoms at night?',
            'inputType': 'dropdown',
            'potentialInputs': ['Yes', 'No'],
            'modelEncoding': {'No': 0, 'Yes': 1},
            'backendHandling': 'Validate selection is "Yes" or "No". Encode as 0 or 1.'
          },
          {
            'feature': 'ExerciseInduced',
            'question': 'Do you experience asthma symptoms triggered by exercise?',
            'inputType': 'dropdown',
            'potentialInputs': ['Yes', 'No'],
            'modelEncoding': {'No': 0, 'Yes': 1},
            'backendHandling': 'Validate selection is "Yes" or "No". Encode as 0 or 1.'
          },
        ];
      default:
        print('❌ Unsupported condition: $condition');
        throw Exception('Unsupported condition: $condition');
    }
  }

  static Future<String> predict(String condition, Map<String, dynamic> answers) async {
    print('🔍 Starting prediction for condition: $condition');
    print('📥 Raw answers received: $answers');

    final headers = await AuthService.getHeaders();
    print('📋 Headers: $headers');

    final url = Uri.parse('$baseUrl/api/predictions/predict/$condition');
    print('🌐 API URL: $url');

    // Apply model encoding
    final encodedAnswers = await _encodeAnswers(condition, answers);
    print('🔄 Encoded answers: $encodedAnswers');

    final body = jsonEncode(encodedAnswers);
    print('📤 Request body: $body');

    try {
      print('🚀 Sending POST request to $url');
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      print('📥 Response status code: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          print('✅ Parsed response data: $data');
          final diagnosis = data['data']?['diagnosis']?.toString() ?? 'No diagnosis available';
          print('🏁 Final diagnosis: $diagnosis');
          return diagnosis;
        } catch (e) {
          print('❌ Error parsing response JSON: $e');
          throw Exception('Failed to parse response: $e');
        }
      } else {
        print('❌ Failed request with status: ${response.statusCode}');
        throw Exception('Failed to predict: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Network or other error: $e');
      throw Exception('Failed to predict: $e');
    }
  }

  static Future<String> sendMessage(String message) async {
    print('💬 Sending chatbot message: $message');
    final headers = await AuthService.getHeaders();
    print('📋 Chatbot headers: $headers');

    final body = jsonEncode({'msg': message});
    print('📤 Chatbot request body: $body');

    final url = Uri.parse('$baseUrl/api/predictions/predict/chatbot');
    print('🌐 Chatbot API URL: $url');

    try {
      print('🚀 Sending POST request to $url');
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      print('📥 Chatbot response status code: ${response.statusCode}');
      print('📥 Chatbot response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          print('✅ Parsed chatbot response data: $data');
          final textResponse = data['data']?['text_response']?.toString() ?? 'No response';
          print('🏁 Chatbot response: $textResponse');
          return textResponse;
        } catch (e) {
          print('❌ Error parsing chatbot response JSON: $e');
          throw Exception('Failed to parse chatbot response: $e');
        }
      } else {
        print('❌ Failed chatbot request with status: ${response.statusCode}');
        throw Exception('Failed to send message: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Chatbot network or other error: $e');
      throw Exception('Failed to send message: $e');
    }
  }

  static Future<Map<String, dynamic>> _encodeAnswers(String condition, Map<String, dynamic> answers) async {
    print('🔧 Encoding answers for condition: $condition');
    final questions = await getQuestions(condition);
    print('📋 Questions loaded: ${questions.map((q) => q['feature']).toList()}');
    final encoded = <String, dynamic>{};

    for (var question in questions) {
      final feature = question['feature'] as String;
      final answer = answers[feature];
      print('🔍 Processing feature: $feature, Raw answer: $answer');

      if (answer != null && answer.toString().isNotEmpty) {
        final encoding = question['modelEncoding'];
        print('⚙️ Encoding type for $feature: $encoding');

        if (encoding is Map) {
          if (!encoding.containsKey(answer)) {
            print('❌ Invalid answer for $feature: $answer. Valid options: ${encoding.keys.join(', ')}');
            throw Exception('Invalid answer for $feature: $answer. Valid options: ${encoding.keys.join(', ')}');
          }
          encoded[feature] = encoding[answer];
          print('✅ Encoded $feature: ${encoded[feature]}');
        } else if (encoding == 'Use as is (float)') {
          final parsed = double.tryParse(answer.toString());
          if (parsed == null) {
            print('❌ Invalid number format for $feature: $answer');
            throw Exception('Invalid number format for $feature: $answer');
          }
          // Validate range based on potentialInputs
          final potentialInputs = question['potentialInputs'] as String;
          final range = _extractRange(potentialInputs);
          print('📏 Range for $feature: $range');
          if (range != null && (parsed < range['min']! || parsed > range['max']!)) {
            print('❌ $feature out of range: $parsed. Must be between ${range['min']} and ${range['max']}');
            throw Exception('$feature must be between ${range['min']} and ${range['max']}');
          }
          encoded[feature] = parsed;
          print('✅ Encoded $feature: ${encoded[feature]}');
        } else if (encoding == 'Use as is (integer)') {
          final parsed = int.tryParse(answer.toString());
          if (parsed == null) {
            print('❌ Invalid number format for $feature: $answer');
            throw Exception('Invalid number format for $feature: $answer');
          }
          final potentialInputs = question['potentialInputs'] as String;
          final range = _extractRange(potentialInputs);
          print('📏 Range for $feature: $range');
          if (range != null && (parsed < range['min']! || parsed > range['max']!)) {
            print('❌ $feature out of range: $parsed. Must be between ${range['min']} and ${range['max']}');
            throw Exception('$feature must be between ${range['min']} and ${range['max']}');
          }
          encoded[feature] = parsed;
          print('✅ Encoded $feature: ${encoded[feature]}');
        } else if (encoding == 'Use as is (string)') {
          final potentialInputs = question['potentialInputs'] as List<dynamic>;
          if (!potentialInputs.contains(answer)) {
            print('❌ Invalid answer for $feature: $answer. Valid options: ${potentialInputs.join(', ')}');
            throw Exception('Invalid answer for $feature: $answer. Valid options: ${potentialInputs.join(', ')}');
          }
          encoded[feature] = answer;
          print('✅ Encoded $feature: ${encoded[feature]}');
        } else {
          encoded[feature] = answer;
          print('✅ Encoded $feature (default): ${encoded[feature]}');
        }
      } else {
        print('⚠️ No answer provided for $feature');
      }
    }

    // Handle BMI imputation for stroke
    if (condition.toLowerCase() == 'stroke' && !encoded.containsKey('bmi')) {
      encoded['bmi'] = 28.893237;
      print('📊 Imputed BMI for stroke: ${encoded['bmi']}');
    }

    print('🏁 Final encoded answers: $encoded');
    return encoded;
  }

  static Map<String, double>? _extractRange(String potentialInputs) {
    print('🔍 Extracting range from: $potentialInputs');
    final match = RegExp(r'between (\d+\.?\d*) and (\d+\.?\d*)').firstMatch(potentialInputs);
    if (match != null) {
      final range = {
        'min': double.parse(match.group(1)!),
        'max': double.parse(match.group(2)!),
      };
      print('✅ Extracted range: $range');
      return range;
    }
    print('⚠️ No range found');
    return null;
  }
}