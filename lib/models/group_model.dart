import 'package:cloud_firestore/cloud_firestore.dart';

/// 모임 모델
/// Firebase Firestore의 groups 컬렉션과 매핑됩니다.
class Group {
  final String id;
  final String name;
  final String? description;
  final String ownerId; // 모임장 ID 추가
  final List<String> members;
  final List<String> categories;
  final List<String> transactions;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Group({
    required this.id,
    required this.name,
    this.description,
    required this.ownerId, // 모임장 필수
    required this.members,
    required this.categories,
    required this.transactions,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Firebase Firestore에서 Group 객체 생성
  factory Group.fromFirestore(Map<String, dynamic> data, String id) {
    return Group(
      id: id,
      name: data['name'] ?? '',
      description: data['description'],
      ownerId: data['ownerId'] ?? '', // 모임장 ID 로드
      members: List<String>.from(data['members'] ?? []),
      categories: List<String>.from(data['categories'] ?? []),
      transactions: List<String>.from(data['transactions'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// Firebase Firestore로 전송할 Map 생성
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'ownerId': ownerId, // 모임장 ID 저장
      'members': members,
      'categories': categories,
      'transactions': transactions,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// 모임 정보 복사본 생성
  Group copyWith({
    String? id,
    String? name,
    String? description,
    String? ownerId, // 모임장 ID 복사
    List<String>? members,
    List<String>? categories,
    List<String>? transactions,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Group(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      ownerId: ownerId ?? this.ownerId, // 모임장 ID 복사
      members: members ?? this.members,
      categories: categories ?? this.categories,
      transactions: transactions ?? this.transactions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 현재 사용자가 모임장인지 확인
  bool isOwner(String userId) {
    return ownerId == userId;
  }

  /// 현재 사용자가 모임 멤버인지 확인
  bool isMember(String userId) {
    return members.contains(userId);
  }

  @override
  String toString() {
    return 'Group(id: $id, name: $name, ownerId: $ownerId, members: $members)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Group && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
