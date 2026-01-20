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

  Future<String?> identifyEquipment(XFile imageFile) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      
      final content = [
        Content.multi([
          TextPart("""사진 속 소방 시설물의 명칭을 다음 리스트 중에서만 골라줘: 
[분말소화기, 완강기, 옥내소화전, 연기감지기, 피난구유도등, 비상조명등]

만약 위 리스트에 정확히 일치하는 것이 없다면, 가장 가깝다고 판단되는 명칭을 위 리스트에서 골라 출력해. 
단, 소방 시설물이 전혀 아니거나 식별이 불가능한 경우에만 예외적으로 사진에서 보이는 특징을 한 단어로 짧게 설명해줘(예: '빨간색 통', '천장 조명').
결과는 반드시 '단어' 하나만 출력하고, 불필요한 문장이나 설명은 생략해."""),
          DataPart('image/jpeg', imageBytes),
        ])
      ];

      final response = await _model.generateContent(content);
      final identified = response.text?.trim() ?? '알 수 없음';
      debugPrint('AI Identified: $identified');
      return identified;
    } catch (e) {
      debugPrint('Error identifying equipment: $e');
      return null;
    }
  }
}
