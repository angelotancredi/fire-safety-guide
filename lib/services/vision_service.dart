import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';

class VisionService {
  // IMPORTANT: The user should provide their own Gemini API Key
  static const String _apiKey = "AIzaSyBCfcuXTMuQ9Scqr0Xyzg426Y1Ju1Q2tfw"; // Using the provide API Key as a candidate

  final GenerativeModel _model;

  VisionService()
      : _model = GenerativeModel(
          model: 'gemini-1.5-flash',
          apiKey: _apiKey,
        );

  Future<String?> identifyEquipment(XFile imageFile, List<String> equipmentList) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      final listString = equipmentList.join(', ');
      
      final content = [
        Content.multi([
          TextPart("""이 사진 속 물건의 가장 적절한 이름을 다음 리스트 중에서 하나만 골라서 대답해줘.
리스트: [$listString]

만약 리스트에 없는 물건이라면 '없음'이라고만 대답해.
결과는 반드시 리스트에 있는 '단어' 하나만 출력하고, 불필요한 문장이나 설명은 모두 생략해."""),
          DataPart('image/jpeg', imageBytes),
        ])
      ];

      final response = await _model.generateContent(content);
      final identified = response.text?.trim() ?? '없음';
      debugPrint('AI Identified (Strict): $identified');
      return identified;
    } catch (e) {
      debugPrint('Error identifying equipment: $e');
      return null;
    }
  }
}
