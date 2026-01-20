import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/equipment_code.dart';
import '../theme/app_theme.dart';
import 'detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('시설물 검색'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              style: const TextStyle(color: AppTheme.charcoal),
              decoration: InputDecoration(
                hintText: '시설물 명칭을 입력하세요 (예: 소화기)',
                hintStyle: TextStyle(color: AppTheme.charcoal.withOpacity(0.3)),
                prefixIcon: Icon(Icons.search, color: AppTheme.charcoal.withOpacity(0.4)),
                filled: true,
                fillColor: AppTheme.lightGray,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          Expanded(
            child: _searchQuery.isEmpty
                ? const Center(child: Text('검색어를 입력하여 법적 기준을 찾아보세요.'))
                : StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('equipment_codes')
                        .where('item_name', isGreaterThanOrEqualTo: _searchQuery)
                        .where('item_name', isLessThanOrEqualTo: '$_searchQuery\uf8ff')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Center(child: Text('검색 중 오류가 발생했습니다.'));
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: AppTheme.safetyRed));
                      }

                      final docs = snapshot.data?.docs ?? [];
                      if (docs.isEmpty) {
                        return const Center(child: Text('검색 결과가 없습니다.'));
                      }

                      return ListView.builder(
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final equipment = EquipmentCode.fromFirestore(docs[index]);
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            title: Text(
                              equipment.itemName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.charcoal,
                              ),
                            ),
                            trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailScreen(equipment: equipment),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
