import 'package:flutter/material.dart';

/// 카테고리 모델
/// Firebase Firestore의 categories 컬렉션과 매핑됩니다.
class Category {
  final String id;
  final String groupId;
  final String name;
  final Color color;
  final String icon;

  const Category({
    required this.id,
    required this.groupId,
    required this.name,
    required this.color,
    required this.icon,
  });

  /// Firebase Firestore에서 Category 객체 생성
  factory Category.fromFirestore(Map<String, dynamic> data, String id) {
    return Category(
      id: id,
      groupId: data['groupId'] ?? '',
      name: data['name'] ?? '',
      color: Color(int.parse(data['color'] ?? '0xFF000000')),
      icon: data['icon'] ?? '📁',
    );
  }

  /// Firebase Firestore로 전송할 Map 생성
  Map<String, dynamic> toFirestore() {
    return {
      'groupId': groupId,
      'name': name,
      'color': '#${color.value.toRadixString(16).substring(2)}',
      'icon': icon,
    };
  }

  /// 카테고리 정보 복사본 생성
  Category copyWith({
    String? id,
    String? groupId,
    String? name,
    Color? color,
    String? icon,
  }) {
    return Category(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      name: name ?? this.name,
      color: color ?? this.color,
      icon: icon ?? this.icon,
    );
  }

  @override
  String toString() {
    return 'Category(id: $id, name: $name, groupId: $groupId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
