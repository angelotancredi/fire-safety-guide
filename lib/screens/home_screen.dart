import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/law_update.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('최신 법령 알림판'),
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Since we use StreamBuilder, it's already live. 
          // We add a small delay to show the indicator for better UX.
          await Future.delayed(const Duration(milliseconds: 800));
        },
        color: AppTheme.safetyRed,
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('law_updates')
              .orderBy('publish_date', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('데이터를 불러오는데 실패했습니다.'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppTheme.safetyRed));
            }

            final docs = snapshot.data?.docs ?? [];
            if (docs.isEmpty) {
              return const Center(child: Text('게시된 법령이 없습니다.'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(), // Important for RefreshIndicator
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final law = LawUpdate.fromFirestore(docs[index]);
                return _buildLawCard(context, law);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildLawCard(BuildContext context, LawUpdate law) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildPriorityChip(law.priority),
                Text(
                  DateFormat('yyyy.MM.dd').format(law.publishDate),
                  style: TextStyle(color: Colors.grey[500], fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              law.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 19,
                    height: 1.4,
                  ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.lightGray,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                law.category,
                style: const TextStyle(
                  color: AppTheme.charcoal,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              law.summary,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityChip(String priority) {
    final isUrgent = priority == '긴급';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isUrgent ? AppTheme.safetyRed : AppTheme.lightGray,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        priority,
        style: TextStyle(
          color: isUrgent ? Colors.white : AppTheme.charcoal.withOpacity(0.6),
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
