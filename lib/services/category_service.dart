import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';

/// 카테고리 관련 서비스
/// Firebase Firestore의 categories 컬렉션과 상호작용합니다.
class CategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 특정 그룹의 모든 카테고리를 가져옵니다.
  Future<List<Category>> getCategoriesByGroup(String groupId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('categories')
          .where('groupId', isEqualTo: groupId)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Category.fromFirestore(data, doc.id);
      }).toList();
    } catch (e) {
      print('❌ 카테고리 조회 실패: $e');
      return [];
    }
  }

  /// 특정 카테고리를 가져옵니다.
  Future<Category?> getCategoryById(String categoryId) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection('categories')
          .doc(categoryId)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return Category.fromFirestore(data, doc.id);
      }
      return null;
    } catch (e) {
      print('❌ 카테고리 조회 실패: $e');
      return null;
    }
  }

  /// 새 카테고리를 추가합니다.
  Future<bool> addCategory(Category category) async {
    try {
      await _firestore.collection('categories').add(category.toFirestore());
      print('✅ 카테고리 추가 성공: ${category.name}');
      return true;
    } catch (e) {
      print('❌ 카테고리 추가 실패: $e');
      return false;
    }
  }

  /// 카테고리를 업데이트합니다.
  Future<bool> updateCategory(
    String categoryId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore.collection('categories').doc(categoryId).update(data);
      print('✅ 카테고리 업데이트 성공: $categoryId');
      return true;
    } catch (e) {
      print('❌ 카테고리 업데이트 실패: $e');
      return false;
    }
  }

  /// 카테고리를 삭제합니다.
  Future<bool> deleteCategory(String categoryId) async {
    try {
      await _firestore.collection('categories').doc(categoryId).delete();
      print('✅ 카테고리 삭제 성공: $categoryId');
      return true;
    } catch (e) {
      print('❌ 카테고리 삭제 실패: $e');
      return false;
    }
  }
}
