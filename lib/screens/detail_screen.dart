import 'package:flutter/material.dart';
import '../models/equipment_code.dart';
import '../theme/app_theme.dart';

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
}
