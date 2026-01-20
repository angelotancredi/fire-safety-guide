import 'package:cloud_firestore/cloud_firestore.dart';

class LawUpdate {
  final String id;
  final String title;
  final String category;
  final String summary;
  final DateTime publishDate;
  final String priority;

  LawUpdate({
    required this.id,
    required this.title,
    required this.category,
    required this.summary,
    required this.publishDate,
    required this.priority,
  });

  factory LawUpdate.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    
    DateTime parsedDate;
    var pubDate = data['publish_date'];
    if (pubDate is Timestamp) {
      parsedDate = pubDate.toDate();
    } else if (pubDate is String) {
      parsedDate = DateTime.tryParse(pubDate) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return LawUpdate(
      id: doc.id,
      title: data['title'] ?? '',
      category: data['category'] ?? '',
      summary: data['summary'] ?? '',
      publishDate: parsedDate,
      priority: data['priority'] ?? '보통',
    );
  }
}
