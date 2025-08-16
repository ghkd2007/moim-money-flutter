import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import '../models/models.dart';

/// 거래 내역 서비스
/// Firebase Firestore와 연동하여 거래 내역을 관리합니다.
class TransactionService {
  final firestore.FirebaseFirestore _firestore =
      firestore.FirebaseFirestore.instance;
  final String _collection = 'transactions';

  /// 특정 모임의 거래 내역 조회
  Future<List<Transaction>> getTransactionsByGroup(String groupId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('groupId', isEqualTo: groupId)
          .orderBy('date', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Transaction.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('거래 내역 조회 오류: $e');
      // 인덱스 오류인 경우 단순 쿼리로 재시도
      if (e.toString().contains('failed-precondition') ||
          e.toString().contains('requires an index')) {
        try {
          print('인덱스 오류 감지, 단순 쿼리로 재시도...');
          final simpleQuerySnapshot = await _firestore
              .collection(_collection)
              .where('groupId', isEqualTo: groupId)
              .get();

          final transactions = simpleQuerySnapshot.docs
              .map((doc) => Transaction.fromFirestore(doc.data(), doc.id))
              .toList();

          // 클라이언트에서 정렬
          transactions.sort((a, b) => b.date.compareTo(a.date));
          return transactions;
        } catch (retryError) {
          print('재시도 실패: $retryError');
          return [];
        }
      }
      return [];
    }
  }

  /// 특정 날짜의 거래 내역 조회
  Future<List<Transaction>> getTransactionsByDate(
    String groupId,
    DateTime date,
  ) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final querySnapshot = await _firestore
          .collection(_collection)
          .where('groupId', isEqualTo: groupId)
          .where('date', isGreaterThanOrEqualTo: startOfDay)
          .where('date', isLessThan: endOfDay)
          .orderBy('date', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Transaction.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('날짜별 거래 내역 조회 오류: $e');
      return [];
    }
  }

  /// 특정 사용자의 거래 내역 조회
  Future<List<Transaction>> getTransactionsByUser(
    String groupId,
    String userId,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('groupId', isEqualTo: groupId)
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Transaction.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('사용자별 거래 내역 조회 오류: $e');
      return [];
    }
  }

  /// 거래 내역 추가
  Future<String?> addTransaction(Transaction transaction) async {
    try {
      final docRef = await _firestore
          .collection(_collection)
          .add(transaction.toFirestore());
      return docRef.id;
    } catch (e) {
      print('거래 내역 추가 오류: $e');
      return null;
    }
  }

  /// 거래 내역 수정
  Future<bool> updateTransaction(Transaction transaction) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(transaction.id)
          .update(transaction.toFirestore());
      return true;
    } catch (e) {
      print('거래 내역 수정 오류: $e');
      return false;
    }
  }

  /// 거래 내역 삭제
  Future<bool> deleteTransaction(String transactionId) async {
    try {
      await _firestore.collection(_collection).doc(transactionId).delete();
      return true;
    } catch (e) {
      print('거래 내역 삭제 오류: $e');
      return false;
    }
  }

  /// 모임별 통계 조회
  Future<Map<String, dynamic>> getGroupStatistics(String groupId) async {
    try {
      final transactions = await getTransactionsByGroup(groupId);

      int totalIncome = 0;
      int totalExpense = 0;

      for (final transaction in transactions) {
        if (transaction.isIncome) {
          totalIncome += transaction.amount;
        } else {
          totalExpense += transaction.amount.abs();
        }
      }

      return {
        'totalIncome': totalIncome,
        'totalExpense': totalExpense,
        'remainingBudget': totalIncome - totalExpense,
        'transactionCount': transactions.length,
      };
    } catch (e) {
      print('통계 조회 오류: $e');
      return {
        'totalIncome': 0,
        'totalExpense': 0,
        'remainingBudget': 0,
        'transactionCount': 0,
      };
    }
  }

  /// 카테고리별 통계 조회
  Future<Map<String, Map<String, dynamic>>> getCategoryStatistics(
    String groupId,
  ) async {
    try {
      final transactions = await getTransactionsByGroup(groupId);
      final Map<String, Map<String, dynamic>> categoryStats = {};

      for (final transaction in transactions) {
        final categoryId = transaction.categoryId;

        if (!categoryStats.containsKey(categoryId)) {
          categoryStats[categoryId] = {
            'totalAmount': 0,
            'count': 0,
            'type': transaction.type,
          };
        }

        categoryStats[categoryId]!['totalAmount'] =
            (categoryStats[categoryId]!['totalAmount'] as int) +
            transaction.amount.abs();
        categoryStats[categoryId]!['count'] =
            (categoryStats[categoryId]!['count'] as int) + 1;
      }

      return categoryStats;
    } catch (e) {
      print('카테고리별 통계 조회 오류: $e');
      return {};
    }
  }
}
