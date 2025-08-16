import 'package:flutter/material.dart';
import '../models/models.dart';

/// 샘플 데이터 서비스
/// 개발 및 테스트를 위한 샘플 데이터를 생성합니다.
class SampleDataService {
  /// 샘플 카테고리 생성
  static List<Category> getSampleCategories() {
    return [
      const Category(
        id: 'cat1',
        groupId: '1',
        name: '스타벅스',
        color: Colors.brown,
        icon: '☕',
      ),
      const Category(
        id: 'cat2',
        groupId: '1',
        name: '맛집',
        color: Colors.orange,
        icon: '🍽️',
      ),
      const Category(
        id: 'cat3',
        groupId: '1',
        name: '회사',
        color: Colors.blue,
        icon: '🏢',
      ),
      const Category(
        id: 'cat4',
        groupId: '1',
        name: 'CGV',
        color: Colors.purple,
        icon: '🎬',
      ),
      const Category(
        id: 'cat5',
        groupId: '1',
        name: '교통비',
        color: Colors.green,
        icon: '🚌',
      ),
      const Category(
        id: 'cat6',
        groupId: '1',
        name: '쇼핑',
        color: Colors.pink,
        icon: '🛍️',
      ),
      const Category(
        id: 'cat7',
        groupId: '1',
        name: '급여',
        color: Colors.green,
        icon: '💰',
      ),
      const Category(
        id: 'cat8',
        groupId: '1',
        name: '용돈',
        color: Colors.green,
        icon: '💵',
      ),
    ];
  }

  /// 샘플 거래 내역 생성
  static List<Transaction> getSampleTransactions() {
    final now = DateTime.now();
    return [
      Transaction(
        id: '1',
        groupId: '1',
        userId: 'user1',
        type: 'expense',
        amount: -15000,
        categoryId: 'cat1',
        description: '아메리카노 2잔',
        date: now.subtract(const Duration(days: 1)),
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      Transaction(
        id: '2',
        groupId: '1',
        userId: 'user2',
        type: 'expense',
        amount: -45000,
        categoryId: 'cat2',
        description: '치킨 배달',
        date: now.subtract(const Duration(days: 2)),
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      Transaction(
        id: '3',
        groupId: '1',
        userId: 'user1',
        type: 'income',
        amount: 3000000,
        categoryId: 'cat7',
        description: '월급',
        date: now.subtract(const Duration(days: 5)),
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 5)),
      ),
      Transaction(
        id: '4',
        groupId: '1',
        userId: 'user3',
        type: 'expense',
        amount: -12000,
        categoryId: 'cat5',
        description: '지하철 교통비',
        date: now.subtract(const Duration(days: 3)),
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(days: 3)),
      ),
      Transaction(
        id: '5',
        groupId: '1',
        userId: 'user2',
        type: 'expense',
        amount: -80000,
        categoryId: 'cat6',
        description: '온라인 쇼핑',
        date: now.subtract(const Duration(days: 4)),
        createdAt: now.subtract(const Duration(days: 4)),
        updatedAt: now.subtract(const Duration(days: 4)),
      ),
    ];
  }

  /// 샘플 사용자 생성
  static List<UserModel> getSampleUsers() {
    final now = DateTime.now();
    return [
      UserModel(
        id: 'user1',
        name: '김철수',
        email: 'kim@example.com',
        phone: '010-1234-5678',
        profileImageUrl: null,
        groupIds: ['1'],
        settings: {'notifications': true, 'theme': 'light'},
        createdAt: now,
        updatedAt: now,
      ),
      UserModel(
        id: 'user2',
        name: '이영희',
        email: 'lee@example.com',
        phone: '010-2345-6789',
        profileImageUrl: null,
        groupIds: ['1'],
        settings: {'notifications': true, 'theme': 'dark'},
        createdAt: now,
        updatedAt: now,
      ),
      UserModel(
        id: 'user3',
        name: '박민수',
        email: 'park@example.com',
        phone: '010-3456-7890',
        profileImageUrl: null,
        groupIds: ['1'],
        settings: {'notifications': false, 'theme': 'light'},
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  /// 샘플 모임 생성
  static List<Group> getSampleGroups() {
    final now = DateTime.now();
    return [
      Group(
        id: '1',
        name: '가족 모임',
        description: '가족과 함께하는 경제 관리',
        members: ['user1', 'user2', 'user3'],
        categories: [
          'cat1',
          'cat2',
          'cat3',
          'cat4',
          'cat5',
          'cat6',
          'cat7',
          'cat8',
        ],
        transactions: ['1', '2', '3', '4', '5'],
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }
}
