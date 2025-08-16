import 'package:cloud_firestore/cloud_firestore.dart';

/// 거래 내역 모델
/// Firebase Firestore의 transactions 컬렉션과 매핑됩니다.
class Transaction {
  final String id;
  final String groupId;
  final String userId;
  final String type; // 'income' | 'expense'
  final int amount;
  final String categoryId;
  final String? description;
  final DateTime date;
  final String? location;
  final Map<String, dynamic>? smsData;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Transaction({
    required this.id,
    required this.groupId,
    required this.userId,
    required this.type,
    required this.amount,
    required this.categoryId,
    this.description,
    required this.date,
    this.location,
    this.smsData,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Firebase Firestore에서 Transaction 객체 생성
  factory Transaction.fromFirestore(Map<String, dynamic> data, String id) {
    return Transaction(
      id: id,
      groupId: data['groupId'] ?? '',
      userId: data['userId'] ?? '',
      type: data['type'] ?? 'expense',
      amount: data['amount'] ?? 0,
      categoryId: data['categoryId'] ?? '',
      description: data['description'],
      date: (data['date'] as Timestamp).toDate(),
      location: data['location'],
      smsData: data['smsData'] != null
          ? Map<String, dynamic>.from(data['smsData'])
          : null,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// Firebase Firestore로 전송할 Map 생성
  Map<String, dynamic> toFirestore() {
    return {
      'groupId': groupId,
      'userId': userId,
      'type': type,
      'amount': amount,
      'categoryId': categoryId,
      'description': description,
      'date': date,
      'location': location,
      'smsData': smsData,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// 거래 내역 정보 복사본 생성
  Transaction copyWith({
    String? id,
    String? groupId,
    String? userId,
    String? type,
    int? amount,
    String? categoryId,
    String? description,
    DateTime? date,
    String? location,
    Map<String, dynamic>? smsData,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      description: description ?? this.description,
      date: date ?? this.date,
      location: location ?? this.location,
      smsData: smsData ?? this.smsData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 수입 여부 확인
  bool get isIncome => type == 'income';

  /// 지출 여부 확인
  bool get isExpense => type == 'expense';

  @override
  String toString() {
    return 'Transaction(id: $id, type: $type, amount: $amount, categoryId: $categoryId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Transaction && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// 거래 타입 열거형
enum TransactionType {
  income, // 수입
  expense, // 지출
}

/// SMS 데이터 모델 (은행/카드사 문자 자동 인식용)
class SmsDataModel {
  final String bank;
  final String card;
  final double amount;
  final String message;

  SmsDataModel({
    required this.bank,
    required this.card,
    required this.amount,
    required this.message,
  });

  Map<String, dynamic> toMap() {
    return {'bank': bank, 'card': card, 'amount': amount, 'message': message};
  }

  factory SmsDataModel.fromMap(Map<String, dynamic> map) {
    return SmsDataModel(
      bank: map['bank'] ?? '',
      card: map['card'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      message: map['message'] ?? '',
    );
  }
}
