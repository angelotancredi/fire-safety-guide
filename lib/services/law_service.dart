import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:developer' as dev;

class LawService {
  final String? _ocId = dotenv.env['LAW_API_OC'];
  static const String _baseUrl = 'https://www.law.go.kr/DRF/lawService.do';

  Future<String?> fetchLawDetail(String lawLink) async {
    if (_ocId == null || _ocId!.isEmpty) {
      return '에러: API 키(OC ID)가 .env 파일에 설정되지 않았습니다.';
    }

    try {
      // lawLink format expectation: MST=XXXXXX&JO=YY
      // If it's just MST ID, we can append it.
      String url = '$_baseUrl?OC=$_ocId&target=law&type=XML&$lawLink';
      
      dev.log('Requesting Law API: $url');
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final document = XmlDocument.parse(response.body);
        
        // Extracting meaningful content from XML
        // Typical structure: <Law><Jo><JoTitle>...</JoTitle><JoContent>...</JoContent></Jo></Law>
        final joContentNodes = document.findAllElements('JoContent');
        if (joContentNodes.isNotEmpty) {
          return joContentNodes.map((node) => node.text).join('\n\n');
        } else {
          // If JoContent is missing, maybe return the whole Law title or an error
          final lawTitle = document.findAllElements('법령명_한글').first.text;
          return '요청하신 조문을 찾을 수 없습니다. (법령명: $lawTitle)';
        }
      } else {
        return '에러: 서버 응답 오류 (${response.statusCode})';
      }
    } catch (e) {
      dev.log('Law API Error: $e');
      return '에러: 데이터를 가져오는 중 오류가 발생했습니다. ($e)';
    }
  }
}
