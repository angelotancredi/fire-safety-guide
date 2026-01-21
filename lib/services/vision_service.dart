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
          TextPart("""이 사진 속 물건의 이름을 다음 리스트 중에서 하나 골라줘.
리스트: [$listString]

만약 리스트에 정확히 일치하는 것이 없더라도, 가장 유사한 물건의 이름을 리스트에서 골라 대답해줘.
만약 사진 속 물건이 확실히 소방 시설물인데 리스트에 없다면, 사진 속 물건의 일반적인 명칭(예: '스프링클러 헤드', '화재 경보기' 등)을 한국어로 짧게 대답해줘.
전혀 관련 없는 물건이라면 '없음'이라고 대답해.

결과는 반드시 '단어' 하나만 출력하고, 불필요한 설명은 생략해."""),
          DataPart('image/jpeg', imageBytes),
        ])
      ];

      final response = await _model.generateContent(content);
      final identified = response.text?.trim();
      if (identified == null || identified.isEmpty) return '없음';
      debugPrint('AI Identified (Strict): $identified');
      return identified;
    } catch (e) {
      debugPrint('Error identifying equipment: $e');
      return '에러: $e';
    }
  }
}
