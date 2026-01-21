import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'screens/detail_screen.dart';
import 'services/vision_service.dart';
import 'models/equipment_code.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:ui';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load(fileName: ".env");
  runApp(const FireSafetyApp());
}

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}

class FireSafetyApp extends StatelessWidget {
  const FireSafetyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '소방 세이프티 가이드',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      scrollBehavior: AppScrollBehavior(),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  final ImagePicker _picker = ImagePicker();
  final VisionService _visionService = VisionService();

  static const List<Widget> _screens = [
    HomeScreen(),
    SearchScreen(),
  ];

  Future<void> _takePhotoAndAnalyze() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (photo == null) return;

    // Show loading dialog
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppTheme.safetyRed),
      ),
    );

    try {
      // 1. Fetch current equipment list from Firestore
      final equipmentSnapshot = await FirebaseFirestore.instance
          .collection('equipment_codes')
          .get();
      
      final List<String> equipmentNames = equipmentSnapshot.docs
          .map((doc) => (doc.data() as Map<String, dynamic>)['item_name'] as String)
          .toList();

      if (kIsWeb) {
        print('--- Firestore Data Debug (v1.0.8) ---');
        print('Total DB Items found: ${equipmentNames.length}');
        print('DB Items: ${equipmentNames.join(", ")}');
      }

      // 2. Identify with AI using the dynamic list
      final String? aiIdentified = await _visionService.identifyEquipment(photo, equipmentNames);
      
      if (kIsWeb) {
        print('--- AI Vision Debug (v1.2.3) ---');
        print('Raw AI Output: "$aiIdentified"');
      }
      
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      if (aiIdentified == null || aiIdentified == '없음' || aiIdentified == '알 수 없음' || aiIdentified.startsWith('에러:')) {
        _showErrorDialog("AI가 어떤 시설물인지 판단할 수 없습니다. (v1.2.3)", aiResult: aiIdentified ?? '응답 없음');
        return;
      }

      // Aggressive Normalization Function
      String normalize(String input) {
        return input.trim().toLowerCase().replaceAll(RegExp(r'[^\wㄱ-ㅎ가-힣]'), '').replaceAll(' ', '');
      }

      final String normalizedAi = normalize(aiIdentified);

      // 3. Flexible Search (Fuzzy Matching)
      DocumentSnapshot? bestMatchDoc;
      
      // Step A: Precise Match first
      for (var doc in equipmentSnapshot.docs) {
        final rawDbName = (doc.data() as Map<String, dynamic>)['item_name'] as String;
        final normalizedDb = normalize(rawDbName);
        if (normalizedDb == normalizedAi) {
          bestMatchDoc = doc;
          break;
        }
      }

      // Step B: Containment Match if no precise match
      if (bestMatchDoc == null) {
        for (var doc in equipmentSnapshot.docs) {
          final rawDbName = (doc.data() as Map<String, dynamic>)['item_name'] as String;
          final normalizedDb = normalize(rawDbName);
          
          if (normalizedDb.contains(normalizedAi) || normalizedAi.contains(normalizedDb)) {
            bestMatchDoc = doc;
            break;
          }
        }
      }

      if (bestMatchDoc == null) {
        _showErrorDialog("AI는 '$aiIdentified'(으)로 인식했으나, DB 목록 중 일치하는 시설물이 없습니다. (v1.2.3)", aiResult: aiIdentified);
        return;
      }

      final equipment = EquipmentCode.fromFirestore(bestMatchDoc);
      debugPrint('Match Success: ${equipment.itemName} (v1.0.8)');
      
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailScreen(equipment: equipment),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      _showErrorDialog("오류가 발생했습니다: $e (System v1.0.7)");
    }
  }

  void _showErrorDialog(String message, {String? aiResult}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.pureWhite,
        surfaceTintColor: AppTheme.pureWhite,
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: AppTheme.safetyRed),
            SizedBox(width: 10),
            Text('인식 결과', style: TextStyle(color: AppTheme.charcoal, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message, style: TextStyle(color: AppTheme.charcoal.withOpacity(0.8))),
            if (aiResult != null && aiResult != '알 수 없음') ...[
              const SizedBox(height: 20),
              const Text(
                'AI가 이렇게 인식했어요:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.charcoal),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.lightGray,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  aiResult,
                  style: const TextStyle(
                    color: AppTheme.safetyRed,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인', style: TextStyle(color: AppTheme.safetyRed, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: _takePhotoAndAnalyze,
        backgroundColor: AppTheme.safetyRed,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        elevation: 4,
        child: const Icon(Icons.camera_alt, size: 28),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: AppTheme.pureWhite,
        selectedItemColor: AppTheme.safetyRed,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_active_outlined),
            activeIcon: Icon(Icons.notifications_active),
            label: '알림판',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: '시설물 검색',
          ),
        ],
      ),
    );
  }
}
