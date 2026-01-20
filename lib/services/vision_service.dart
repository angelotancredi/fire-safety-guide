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
          TextPart("""사진 속 소방 시설물을 식별해줘. 
결과는 '소화기', '스프링클러', '완강기', '감지기', '유도등', '옥내소화전'과 같이 데이터베이스 검색이 가능한 핵심 단어 하나만 답해줘.
설명이나 문장 없이 반드시 '단어'만 출력해.
만약 소방 시설물이 아니라면 '알 수 없음'이라고 답해줘."""),
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
