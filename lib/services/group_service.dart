import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import '../models/models.dart';
import 'app_state_service.dart';

/// 모임 서비스
/// Firebase Firestore와 연동하여 모임 데이터를 관리합니다.
class GroupService {
  final firestore.FirebaseFirestore _firestore =
      firestore.FirebaseFirestore.instance;
  final String _collection = 'groups';

  /// 현재 사용자가 참여하고 있는 모든 모임 조회
  Future<List<Group>> getMyGroups(String userId) async {
    try {
      print('🔍 모임 조회 시작: 사용자 ID $userId');

      // Firebase에서 실제 데이터 조회
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('members', arrayContains: userId)
          .get();

      List<Group> groups = [];
      if (querySnapshot.docs.isNotEmpty) {
        print('✅ Firebase에서 모임 데이터 조회 성공: ${querySnapshot.docs.length}개');
        groups = querySnapshot.docs
            .map((doc) => Group.fromFirestore(doc.data(), doc.id))
            .toList();
      } else {
        print('⚠️ Firebase에 모임 데이터 없음');
        // 데이터가 없으면 빈 리스트 반환
        groups = [];
      }

      // AppStateService에 모임 목록 업데이트
      AppStateService().updateMyGroups(groups);

      return groups;
    } catch (e) {
      print('❌ Firebase 모임 조회 오류: $e');
      // 오류 발생 시 빈 리스트 반환
      final groups = <Group>[];
      AppStateService().updateMyGroups(groups);
      return groups;
    }
  }

  /// 특정 모임 상세 정보 조회
  Future<Group?> getGroupById(String groupId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(groupId).get();

      if (doc.exists) {
        return Group.fromFirestore(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('모임 상세 조회 오류: $e');
      return null;
    }
  }

  /// 모임 생성
  Future<String?> createGroup(Group group) async {
    try {
      final docRef = await _firestore
          .collection(_collection)
          .add(group.toFirestore());

      print('✅ 모임 생성 성공: ${docRef.id}');

      // 생성된 모임을 AppStateService에 추가
      final createdGroup = group.copyWith(id: docRef.id);
      AppStateService().addGroup(createdGroup);

      return docRef.id;
    } catch (e) {
      print('❌ 모임 생성 오류: $e');
      return null;
    }
  }

  /// 모임에 멤버 추가
  Future<bool> addMemberToGroup(String groupId, String userId) async {
    try {
      await _firestore.collection(_collection).doc(groupId).update({
        'members': firestore.FieldValue.arrayUnion([userId]),
        'updatedAt': firestore.FieldValue.serverTimestamp(),
      });

      print('✅ 멤버 추가 성공: 그룹 $groupId, 사용자 $userId');
      return true;
    } catch (e) {
      print('❌ 멤버 추가 오류: $e');
      return false;
    }
  }

  /// 모임 정보 업데이트
  Future<bool> updateGroup(Group group) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(group.id)
          .update(group.toFirestore());

      print('✅ 모임 업데이트 성공: ${group.id}');
      return true;
    } catch (e) {
      print('❌ 모임 업데이트 오류: $e');
      return false;
    }
  }

  /// 모임 삭제
  Future<bool> deleteGroup(String groupId) async {
    try {
      await _firestore.collection(_collection).doc(groupId).delete();

      print('✅ 모임 삭제 성공: $groupId');
      return true;
    } catch (e) {
      print('❌ 모임 삭제 오류: $e');
      return false;
    }
  }

  /// 모임 통계 정보 조회
  Future<Map<String, dynamic>> getGroupStatistics(String groupId) async {
    try {
      // 거래 내역 통계 계산
      final transactionsQuery = await _firestore
          .collection('transactions')
          .where('groupId', isEqualTo: groupId)
          .get();

      double totalIncome = 0;
      double totalExpense = 0;
      int transactionCount = transactionsQuery.docs.length;

      for (final doc in transactionsQuery.docs) {
        final data = doc.data();
        final amount = (data['amount'] ?? 0).toDouble();

        if (data['type'] == 'income') {
          totalIncome += amount;
        } else {
          totalExpense += amount.abs();
        }
      }

      return {
        'totalIncome': totalIncome,
        'totalExpense': totalExpense,
        'remainingBudget': totalIncome - totalExpense,
        'transactionCount': transactionCount,
        'memberCount': 0, // TODO: 실제 멤버 수 계산
      };
    } catch (e) {
      print('모임 통계 조회 오류: $e');
      // 오류 시 기본값 반환
      return {
        'totalIncome': 0.0,
        'totalExpense': 0.0,
        'remainingBudget': 0.0,
        'transactionCount': 0,
        'memberCount': 0,
      };
    }
  }
}
