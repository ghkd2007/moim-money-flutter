import 'package:flutter/foundation.dart';
import '../models/models.dart';

/// 앱 전체 상태 관리 서비스
/// 선택된 모임, 사용자 정보 등을 전역적으로 관리합니다.
class AppStateService extends ChangeNotifier {
  static final AppStateService _instance = AppStateService._internal();
  factory AppStateService() => _instance;
  AppStateService._internal();

  // 현재 선택된 모임
  Group? _selectedGroup;

  // 현재 사용자 정보
  String? _currentUserId;

  // 사용자의 모임 목록
  List<Group> _myGroups = [];

  // 로딩 상태
  bool _isLoading = false;

  // Getters
  Group? get selectedGroup => _selectedGroup;
  String? get currentUserId => _currentUserId;
  List<Group> get myGroups => _myGroups;
  bool get isLoading => _isLoading;
  bool get hasSelectedGroup => _selectedGroup != null;

  /// 현재 사용자 설정
  void setCurrentUser(String userId) {
    _currentUserId = userId;
    notifyListeners();
  }

  /// 모임 목록 업데이트
  void updateMyGroups(List<Group> groups) {
    _myGroups = groups;

    // 선택된 모임이 목록에 없으면 첫 번째 모임으로 설정
    if (_selectedGroup == null && groups.isNotEmpty) {
      _selectedGroup = groups.first;
    } else if (_selectedGroup != null) {
      // 선택된 모임이 목록에 있는지 확인
      final exists = groups.any((group) => group.id == _selectedGroup!.id);
      if (!exists) {
        _selectedGroup = groups.isNotEmpty ? groups.first : null;
      }
    }

    notifyListeners();
  }

  /// 모임 선택
  void selectGroup(Group group) {
    _selectedGroup = group;
    notifyListeners();
  }

  /// 모임 ID로 모임 선택
  void selectGroupById(String groupId) {
    final group = _myGroups.firstWhere(
      (g) => g.id == groupId,
      orElse: () => _myGroups.isNotEmpty
          ? _myGroups.first
          : Group(
              id: '',
              name: '',
              ownerId: '',
              members: [],
              categories: [],
              transactions: [],
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
    );

    if (group.id.isNotEmpty) {
      _selectedGroup = group;
      notifyListeners();
    }
  }

  /// 새 모임 추가
  void addGroup(Group group) {
    _myGroups.add(group);

    // 첫 번째 모임이거나 선택된 모임이 없으면 새 모임을 선택
    if (_myGroups.length == 1 || _selectedGroup == null) {
      _selectedGroup = group;
    }

    notifyListeners();
  }

  /// 모임 업데이트
  void updateGroup(Group updatedGroup) {
    final index = _myGroups.indexWhere((g) => g.id == updatedGroup.id);
    if (index != -1) {
      _myGroups[index] = updatedGroup;

      // 현재 선택된 모임이 업데이트된 모임이면 선택된 모임도 업데이트
      if (_selectedGroup?.id == updatedGroup.id) {
        _selectedGroup = updatedGroup;
      }

      notifyListeners();
    }
  }

  /// 모임 삭제
  void removeGroup(String groupId) {
    _myGroups.removeWhere((g) => g.id == groupId);

    // 삭제된 모임이 현재 선택된 모임이면 첫 번째 모임으로 변경
    if (_selectedGroup?.id == groupId) {
      _selectedGroup = _myGroups.isNotEmpty ? _myGroups.first : null;
    }

    notifyListeners();
  }

  /// 로딩 상태 설정
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// 상태 초기화
  void reset() {
    _selectedGroup = null;
    _currentUserId = null;
    _myGroups = [];
    _isLoading = false;
    notifyListeners();
  }

  /// 선택된 모임의 통계 정보 가져오기
  Map<String, dynamic> getSelectedGroupStats() {
    if (_selectedGroup == null) {
      return {
        'totalIncome': 0.0,
        'totalExpense': 0.0,
        'remainingBudget': 0.0,
        'transactionCount': 0,
        'memberCount': 0,
      };
    }

    return {
      'memberCount': _selectedGroup!.members.length,
      'categoryCount': _selectedGroup!.categories.length,
      'transactionCount': _selectedGroup!.transactions.length,
    };
  }
}
