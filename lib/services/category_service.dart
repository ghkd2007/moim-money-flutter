import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';
import 'package:flutter/material.dart';

/// 카테고리 관련 서비스
/// Firebase Firestore의 categories 컬렉션과 상호작용합니다.
class CategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 기본 카테고리 목록을 반환합니다.
  /// 모임에 카테고리가 없을 때 자동으로 생성됩니다.
  List<Category> getDefaultCategories(String groupId) {
    return [
      // 식비 관련
      Category(
        id: 'default_food',
        groupId: groupId,
        name: '식비',
        color: Colors.orange,
        icon: '🍽️',
      ),
      Category(
        id: 'default_cafe',
        groupId: groupId,
        name: '카페',
        color: Colors.brown,
        icon: '☕',
      ),
      Category(
        id: 'default_snack',
        groupId: groupId,
        name: '간식',
        color: Colors.amber,
        icon: '🍿',
      ),

      // 교통 관련
      Category(
        id: 'default_transport',
        groupId: groupId,
        name: '교통비',
        color: Colors.blue,
        icon: '🚌',
      ),
      Category(
        id: 'default_taxi',
        groupId: groupId,
        name: '택시',
        color: Colors.yellow,
        icon: '🚕',
      ),
      Category(
        id: 'default_parking',
        groupId: groupId,
        name: '주차',
        color: Colors.indigo,
        icon: '🅿️',
      ),

      // 쇼핑 관련
      Category(
        id: 'default_shopping',
        groupId: groupId,
        name: '쇼핑',
        color: Colors.pink,
        icon: '🛍️',
      ),
      Category(
        id: 'default_clothes',
        groupId: groupId,
        name: '의류',
        color: Colors.purple,
        icon: '👕',
      ),
      Category(
        id: 'default_beauty',
        groupId: groupId,
        name: '뷰티',
        color: Colors.pinkAccent,
        icon: '💄',
      ),

      // 여가/문화
      Category(
        id: 'default_entertainment',
        groupId: groupId,
        name: '여가',
        color: Colors.deepPurple,
        icon: '🎬',
      ),
      Category(
        id: 'default_movie',
        groupId: groupId,
        name: '영화',
        color: Colors.red,
        icon: '🎭',
      ),
      Category(
        id: 'default_game',
        groupId: groupId,
        name: '게임',
        color: Colors.green,
        icon: '🎮',
      ),

      // 건강/의료
      Category(
        id: 'default_health',
        groupId: groupId,
        name: '건강',
        color: Colors.teal,
        icon: '💊',
      ),
      Category(
        id: 'default_hospital',
        groupId: groupId,
        name: '병원',
        color: Colors.redAccent,
        icon: '🏥',
      ),

      // 교육
      Category(
        id: 'default_education',
        groupId: groupId,
        name: '교육',
        color: Colors.blueGrey,
        icon: '📚',
      ),

      // 통신
      Category(
        id: 'default_communication',
        groupId: groupId,
        name: '통신',
        color: Colors.cyan,
        icon: '📱',
      ),

      // 주거
      Category(
        id: 'default_housing',
        groupId: groupId,
        name: '주거',
        color: Colors.deepOrange,
        icon: '🏠',
      ),

      // 기타
      Category(
        id: 'default_etc',
        groupId: groupId,
        name: '기타',
        color: Colors.grey,
        icon: '📝',
      ),
    ];
  }

  /// 사용 가능한 아이콘 목록을 반환합니다.
  /// 새 카테고리 생성 시 선택할 수 있는 아이콘들입니다.
  List<String> getAvailableIcons() {
    return [
      // 음식 관련
      '🍽️', '🍕', '🍔', '🍜', '🍱', '🍙', '🍣', '🍖', '🥩', '🥗', '🥪', '🍞',
      '🥐', '🧀', '🥚', '🥛', '🍎', '🍌', '🍇', '🍓', '🍊', '🥭', '🍍', '🥥',

      // 음료
      '☕', '🍵', '🥤', '🧃', '🥛', '🍺', '🍷', '🍸', '🍹', '🥂', '🍾',

      // 교통
      '🚌', '🚕', '🚗', '🚙', '🚎', '🏎️', '🚓', '🚑', '🚒', '🚐', '🚚', '🚛',
      '🚜', '🛵', '🏍️', '🚲', '🚁', '✈️', '🚆', '🚊', '🚉', '🚇', '🚅', '🚄',
      '🚈', '🚂', '🚃', '🚋', '🚌', '🚍', '🚎', '🚏', '🅿️', '🚦', '🚥',

      // 쇼핑/패션
      '🛍️', '👕', '👖', '👗', '👘', '👙', '👚', '👛', '👜', '💼', '🎒', '👝',
      '🛍️', '💄', '💋', '👄', '👅', '👂', '👃', '👁️', '👀', '🧠', '🫀', '🫁',

      // 여가/문화
      '🎬', '🎭', '🎨', '🎪', '🎟️', '🎫', '🎗️', '🎖️', '🏆', '🥇', '🥈', '🥉',
      '🎮', '🎲', '♟️', '🎯', '🎳', '🎣', '🎱', '🎾', '🏐', '🏀', '⚽', '🏈',
      '🎾', '🏉', '🎯', '🎳', '🎮', '🎲', '♟️', '🎭', '🎨', '🎬', '🎤', '🎧',

      // 건강/의료
      '💊', '💉', '🩺', '🩹', '🩻', '🏥', '🏨', '🏩', '🏪', '🏫', '🏬', '🏭',
      '🏯', '🏰', '💒', '🗼', '🗽', '⛪', '🕌', '🛕', '⛩️', '🕍', '⛲', '⛺',

      // 교육
      '📚', '📖', '📕', '📗', '📘', '📙', '📓', '📔', '📒', '📝', '📝', '✏️',
      '✒️', '🖋️', '🖊️', '🖌️', '🖍️', '📐', '📏', '📐', '📏', '📐', '📏',

      // 통신/기술
      '📱',
      '📲',
      '📟',
      '📠',
      '🔋',
      '🔌',
      '💻',
      '🖥️',
      '🖨️',
      '⌨️',
      '🖱️',
      '🖲️',
      '💽', '💾', '💿', '📀', '🎥', '📺', '📷', '📹', '📼', '🔍', '🔎', '🔬',

      // 주거/생활
      '🏠', '🏡', '🏘️', '🏚️', '🏗️', '🏭', '🏢', '🏬', '🏣', '🏤', '🏥', '🏦',
      '🏨', '🏪', '🏫', '🏩', '💒', '⛪', '🕌', '🛕', '⛩️', '🕍', '⛲', '⛺',

      // 기타
      '📝', '📄', '📃', '📋', '📁', '📂', '🗂️', '📅', '📆', '🗓️', '📇', '🗃️',
      '📪', '📫', '📬', '📭', '📮', '🗳️', '✉️', '📧', '💌', '📨', '📩', '📤',
      '📥', '📦', '📫', '📪', '📬', '📭', '📮', '🗳️', '✉️', '📧', '💌', '📨',
    ];
  }

  /// 특정 그룹의 모든 카테고리를 가져옵니다.
  Future<List<Category>> getCategoriesByGroup(String groupId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('categories')
          .where('groupId', isEqualTo: groupId)
          .get();

      final categories = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Category.fromFirestore(data, doc.id);
      }).toList();

      // 카테고리가 없으면 기본 카테고리 반환
      if (categories.isEmpty) {
        print('⚠️ 모임에 카테고리가 없음 - 기본 카테고리 반환');
        return getDefaultCategories(groupId);
      }

      return categories;
    } catch (e) {
      print('❌ 카테고리 조회 실패: $e');
      // 오류 발생 시에도 기본 카테고리 반환
      return getDefaultCategories(groupId);
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
