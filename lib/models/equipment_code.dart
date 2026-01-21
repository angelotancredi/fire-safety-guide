import 'package:cloud_firestore/cloud_firestore.dart';

class EquipmentCode {
  final String id;
  final String itemName;
  final String standard;
  final String lawBasis;
  final String lawLink;
  final String lawMst;
  final String lawClause;

  EquipmentCode({
    required this.id,
    required this.itemName,
    required this.standard,
    required this.lawBasis,
    required this.lawLink,
    required this.lawMst,
    required this.lawClause,
  });

  factory EquipmentCode.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return EquipmentCode(
      id: doc.id,
      itemName: data['item_name'] ?? '',
      standard: data['standard'] ?? '',
      lawBasis: data['law_basis'] ?? '해당 법적 근거 정보가 없습니다.',
      lawLink: data['law_link'] ?? '',
      lawMst: data['law_mst'] ?? '',
      lawClause: data['law_clause'] ?? '',
    );
  }
}
