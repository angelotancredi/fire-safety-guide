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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const FireSafetyApp());
}

class FireSafetyApp extends StatelessWidget {
  const FireSafetyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '소방 세이프티 가이드',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
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
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
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

    final String? itemName = await _visionService.identifyEquipment(photo);
    
    if (!mounted) return;
    Navigator.pop(context); // Close loading dialog

    if (itemName == null || itemName == '알 수 없음') {
      _showErrorDialog("인식할 수 없는 시설물입니다. 다시 시도해 주세요.");
      return;
    }

    // Search in Firestore
    final querySnapshot = await FirebaseFirestore.instance
        .collection('equipment_codes')
        .where('item_name', isEqualTo: itemName)
        .get();

    if (querySnapshot.docs.isEmpty) {
      _showErrorDialog("'$itemName'에 대한 법적 기준을 찾을 수 없습니다.");
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

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkGray,
        title: const Text('인식 결과', style: TextStyle(color: Colors.white)),
        content: Text(message, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인', style: TextStyle(color: AppTheme.safetyRed)),
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
        shape: const CircleBorder(),
        elevation: 4,
        child: const Icon(Icons.camera_alt, color: Colors.white, size: 28),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: AppTheme.pureBlack,
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
