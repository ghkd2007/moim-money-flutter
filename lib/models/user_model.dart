import 'package:cloud_firestore/cloud_firestore.dart';

/// 사용자 모델 클래스
/// Firebase Firestore와 연동하여 사용자 정보를 관리합니다.
class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> groupIds;
  final Map<String, dynamic> settings;

  /// 사용자 모델 생성자
  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.profileImageUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.groupIds,
    required this.settings,
  });

  /// Firebase Firestore에서 데이터를 가져와 UserModel 객체로 변환
  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    return UserModel(
      id: documentId,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'],
      profileImageUrl: map['profileImageUrl'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      groupIds: List<String>.from(map['groupIds'] ?? []),
      settings: Map<String, dynamic>.from(map['settings'] ?? {}),
    );
  }

  /// UserModel 객체를 Firebase Firestore에 저장할 수 있는 Map으로 변환
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'groupIds': groupIds,
      'settings': settings,
    };
  }

  /// 사용자 정보 복사본 생성 (일부 필드만 수정)
  UserModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? profileImageUrl,
    List<String>? groupIds,
    Map<String, dynamic>? settings,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      groupIds: groupIds ?? this.groupIds,
      settings: settings ?? this.settings,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, phone: $phone, groupIds: $groupIds)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
