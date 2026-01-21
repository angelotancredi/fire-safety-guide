import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'law_service.dart';

// This is a simple test function you can call to verify connectivity.
// You can call this from a temporary button or a unit test.
Future<void> testLawApiConnectivity() async {
  print('--- Law API Connectivity Test ---');
  
  // Ensure dotenv is loaded (if not already handled in main.dart)
  try {
    if (dotenv.env.isEmpty) {
      await dotenv.load(fileName: ".env");
    }
  } catch (e) {
    print('Error loading .env: $e');
    return;
  }

  final String? ocId = dotenv.env['LAW_API_OC'];
  print('Using OC ID: ${ocId ?? "MISSING"}');

  final lawService = LawService();
  
  // Test case: MST=218621 (Fire Safety Standards for Extinguishers), Article 10
  final String testLink = 'MST=218621&JO=10';
  print('Requesting detail for: $testLink');
  
  final result = await lawService.fetchLawDetail(testLink);
  
  if (result != null && !result.startsWith('에러:')) {
    print('SUCCESS! Received data:');
    print(result.substring(0, result.length > 200 ? 200 : result.length) + '...');
  } else {
    print('FAILURE: $result');
  }
}
