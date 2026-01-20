import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'screens/detail_screen.dart';
import 'services/vision_service.dart';
import 'models/equipment_code.dart';
import 'dart:ui';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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

    final String? aiIdentified = await _visionService.identifyEquipment(photo);
    
    if (!mounted) return;
    Navigator.pop(context); // Close loading dialog

    if (aiIdentified == null || aiIdentified == '알 수 없음') {
      _showErrorDialog("시설물을 식별할 수 없습니다. 다시 시도해 주세요.", aiResult: aiIdentified);
      return;
    }

    final String itemName = aiIdentified.trim();

    // 1. Exact or Prefix Search in Firestore
    var querySnapshot = await FirebaseFirestore.instance
        .collection('equipment_codes')
        .where('item_name', isGreaterThanOrEqualTo: itemName)
        .where('item_name', isLessThanOrEqualTo: '$itemName\uf8ff')
        .get();

    if (querySnapshot.docs.isEmpty) {
      // 2. Fuzzy Matching: Fetch all and compare
      final allDocs = await FirebaseFirestore.instance
          .collection('equipment_codes')
          .get();
      
      final searchName = itemName.toLowerCase().replaceAll(' ', '');
      
      DocumentSnapshot? bestMatchDoc;

      for (var doc in allDocs.docs) {
        final dbName = (doc.data() as Map<String, dynamic>)['item_name'].toString().toLowerCase().replaceAll(' ', '');
        
        // Exact overlap check
        if (dbName.contains(searchName) || searchName.contains(dbName)) {
          bestMatchDoc = doc;
          break;
        }

        // Partial match for common terms
        if (searchName.length >= 2 && dbName.contains(searchName.substring(0, 2))) {
           bestMatchDoc = doc;
        }
      }

      if (bestMatchDoc == null) {
        _showErrorDialog("'$itemName' (AI 인식)에 대한 상세 정보를 찾을 수 없습니다.", aiResult: aiIdentified);
        return;
      }
      
      final equipment = EquipmentCode.fromFirestore(bestMatchDoc);
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailScreen(equipment: equipment),
        ),
      );
      return;
    }

    final equipment = EquipmentCode.fromFirestore(querySnapshot.docs.first);
    
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailScreen(equipment: equipment),
      ),
    );
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
