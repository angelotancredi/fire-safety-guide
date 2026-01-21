import 'package:flutter/material.dart';
import '../models/equipment_code.dart';
import '../theme/app_theme.dart';
import '../services/law_service.dart';

class DetailScreen extends StatelessWidget {
  final EquipmentCode equipment;

  const DetailScreen({super.key, required this.equipment});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설치 기준 상세'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              equipment.itemName,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppTheme.charcoal,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              '법적 설치 기준',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppTheme.charcoal,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.lightGray,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                equipment.standard,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppTheme.charcoal,
                  height: 1.7,
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _viewLatestLaw(context),
                icon: const Icon(Icons.gavel_rounded),
                label: const Text('최신 법령 보기'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.charcoal,
                  foregroundColor: AppTheme.pureWhite,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              '법적 근거',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppTheme.charcoal,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.pureWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.lightGray),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.charcoal.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                equipment.lawBasis,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.charcoal.withOpacity(0.7),
                  height: 1.7,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _viewLatestLaw(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final lawService = LawService();
      String? targetMst = equipment.lawMst;
      String? targetJo = equipment.lawClause;

      // Fallback 1: If MST is missing, search by itemName
      if (targetMst.isEmpty) {
        dev.log('Law MST missing for ${equipment.itemName}. Searching by keyword...');
        targetMst = await lawService.searchMstId(equipment.itemName) ?? '';
        targetJo = ''; // Clear clause when searching from scratch
      }

      // Fallback 2: If MST still missing, try legacy lawLink if available
      String? result;
      if (targetMst.isNotEmpty) {
        result = await lawService.fetchLawDetail(
          mstId: targetMst,
          joId: targetJo.isNotEmpty ? targetJo : null,
        );
      } else if (equipment.lawLink.isNotEmpty) {
        result = await lawService.fetchLawDetailLegacy(equipment.lawLink);
      } else {
        // Fallback 3: Use a general Fire Safety Act MST as last resort
        const String defaultMst = '236977'; // 소방시설법
        result = await lawService.fetchLawDetail(mstId: defaultMst);
      }
      
      if (!context.mounted) return;
      Navigator.pop(context); // Close loading

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: AppTheme.pureWhite,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '실시간 법령 정보',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.charcoal,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(height: 32),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    result ?? '정보를 가져올 수 없습니다.',
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppTheme.charcoal,
                      height: 1.6,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // Close loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('법령을 가져오는 중 오류가 발생했습니다: $e')),
      );
    }
  }
}
