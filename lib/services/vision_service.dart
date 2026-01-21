import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';

class VisionService {
  // IMPORTANT: The user should provide their own Gemini API Key
  static const String _apiKey = "AIzaSyDTVOCjJ3tmTC-t9W_HzPImmxan2k4x0i8";

  // List of models to try in order of preference
  final List<String> _modelsToTry = [
    'gemini-1.5-flash',
    'gemini-1.5-flash-001',
    'gemini-1.5-pro',
    'gemini-pro-vision', // Legacy fallback
  ];

  Future<String?> identifyEquipment(XFile imageFile, List<String> equipmentList) async {
    final imageBytes = await imageFile.readAsBytes();
    final listString = equipmentList.join(', ');
    
    String? lastError;

    for (String modelName in _modelsToTry) {
      try {
        debugPrint('Attempting identification with model: $modelName');
        final model = GenerativeModel(
          model: modelName,
          apiKey: _apiKey,
        );

        final content = [
          Content.multi([
            TextPart("""이 사진 속 물건의 이름을 다음 리스트 중에서 하나 골라줘.
리스트: [$listString]

만약 리스트에 정확히 일치하는 것이 없더라도, 가장 유사한 물건의 이름을 리스트에서 골라 대답해줘.
만약 사진 속 물건이 확실히 소방 시설물인데 리스트에 없다면, 사진 속 물건의 일반적인 명칭(예: '스프링클러 헤드', '화재 경보기' 등)을 한국어로 짧게 대답해줘.
전혀 관련 없는 물건이라면 '없음'이라고 대답해.

결과는 반드시 '단어' 하나만 출력하고, 불필요한 설명은 생략해."""),
            DataPart('image/jpeg', imageBytes),
          ])
        ];

        final response = await model.generateContent(content);
        final identified = response.text?.trim();
        
        if (identified != null && identified.isNotEmpty) {
          debugPrint('Success with $modelName: $identified');
          return identified;
        }
      } catch (e, stack) {
        lastError = e.toString();
        debugPrint('Failed with $modelName: $e');
        // If it's a specific "model not found" or "not supported", we continue to the next model
        if (!lastError.contains('not found') && !lastError.contains('not supported')) {
           // For other errors (like auth), we might want to stop early, but for now let's try all
        }
        if (modelName == _modelsToTry.last) {
          return '에러: $e\n\n상세: ${stack.toString().split('\n').take(3).join('\n')}';
        }
      }
    }
    return '에러: $lastError (모든 시도 실패)';
  }
}
