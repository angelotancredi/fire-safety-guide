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
          TextPart("이 사진 속에 있는 소방 시설물이 무엇인지 한 단어로 알려줘 (예: 소화기, 스프링클러, 완강기 등). 만약 소방 시설물이 아니라면 '알 수 없음'이라고 답해줘."),
          DataPart('image/jpeg', imageBytes),
        ])
      ];

      final response = await _model.generateContent(content);
      return response.text?.trim();
    } catch (e) {
      debugPrint('Error identifying equipment: $e');
      return null;
    }
  }
}
