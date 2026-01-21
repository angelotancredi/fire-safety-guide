import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:developer' as dev;

class LawService {
  final String? _ocId = dotenv.env['LAW_API_OC'];
  static const String _baseUrl = 'https://www.law.go.kr/DRF/lawService.do';

  static const String _searchUrl = 'https://www.law.go.kr/DRF/lawSearch.do';

  /// Searches for a Law MST ID using a keyword (e.g., item name).
  /// Returns the first MST ID found, or null if not found.
  Future<String?> searchMstId(String keyword) async {
    if (_ocId == null || _ocId!.isEmpty) return null;

    try {
      final url = '$_searchUrl?OC=$_ocId&target=law&type=XML&query=${Uri.encodeComponent(keyword)}';
      dev.log('Searching Law MST: $url');
      
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final document = XmlDocument.parse(response.body);
        final lawNodes = document.findAllElements('law');
        if (lawNodes.isNotEmpty) {
          // Pick the first one (most relevant)
          final mstNode = lawNodes.first.findElements('법령일련번호').first;
          return mstNode.text;
        }
      }
    } catch (e) {
      dev.log('Law Search Error: $e');
    }
    return null;
  }

  /// Fetches law detail using MST ID and optional JO (Clause) ID.
  /// If [JO] is provided, it extracts specific article content.
  Future<String?> fetchLawDetail({required String mstId, String? joId}) async {
    if (_ocId == null || _ocId!.isEmpty) {
      return '에러: API 키(OC ID)가 .env 파일에 설정되지 않았습니다.';
    }

    try {
      String query = 'MST=$mstId';
      if (joId != null && joId.isNotEmpty) {
        query += '&JO=$joId';
      }

      String url = '$_baseUrl?OC=$_ocId&target=law&type=XML&$query';
      
      dev.log('Requesting Law API: $url');
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final document = XmlDocument.parse(response.body);
        final joContentNodes = document.findAllElements('JoContent');
        if (joContentNodes.isNotEmpty) {
          return joContentNodes.map((node) => node.text).join('\n\n');
        } else {
          final titleNode = document.findAllElements('법령명_한글').firstOrNull;
          final lawTitle = titleNode?.text ?? '알 수 없는 법령';
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

  /// Original method for backward compatibility
  Future<String?> fetchLawDetailLegacy(String lawLink) async {
    if (_ocId == null || _ocId!.isEmpty) return null;
    try {
      String url = '$_baseUrl?OC=$_ocId&target=law&type=XML&$lawLink';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final document = XmlDocument.parse(response.body);
        final joContentNodes = document.findAllElements('JoContent');
        if (joContentNodes.isNotEmpty) {
          return joContentNodes.map((node) => node.text).join('\n\n');
        }
      }
    } catch (_) {}
    return null;
  }
}
