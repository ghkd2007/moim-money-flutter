import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import '../../../constants/design_system.dart';
import '../../../models/models.dart';
import '../../../services/group_service.dart';
import '../../../services/app_state_service.dart';
import '../../../services/category_service.dart';
import 'create_group_screen.dart';
import 'join_group_screen.dart';

/// 모임 관리 화면
/// 모임 멤버, 카테고리, 모임 목록을 관리하는 화면입니다.
class GroupScreen extends StatefulWidget {
  const GroupScreen({super.key});

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  final GroupService _groupService = GroupService();
  final AppStateService _appStateService = AppStateService();
  final CategoryService _categoryService = CategoryService();

  String? _currentUserId;
  Group? _currentGroup;
  List<Group> _myGroups = [];
  List<Category> _categories = [];
  List<UserModel> _members = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  /// 사용자 초기화
  void _initializeUser() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _currentUserId = currentUser.uid;
      await _loadData();
    }
  }

  /// 데이터 로드
  Future<void> _loadData() async {
    if (_currentUserId == null) return;

    try {
      setState(() {
        _isLoading = true;
      });

      // 현재 선택된 모임 정보
      _currentGroup = _appStateService.selectedGroup;

      // 내 모임 목록
      _myGroups = _appStateService.myGroups;

      // 현재 모임의 카테고리와 멤버 정보 로드
      if (_currentGroup != null) {
        await Future.wait([_loadCategories(), _loadMembers()]);
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('❌ 데이터 로드 오류: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 카테고리 로드
  Future<void> _loadCategories() async {
    if (_currentGroup == null) return;

    try {
      final categoriesSnapshot = await firestore.FirebaseFirestore.instance
          .collection('categories')
          .where('groupId', isEqualTo: _currentGroup!.id)
          .get();

      final List<Category> categories = [];
      for (final doc in categoriesSnapshot.docs) {
        final categoryData = doc.data();
        final category = Category.fromFirestore(categoryData, doc.id);
        categories.add(category);
      }

      // 기본 카테고리가 없으면 생성
      if (categories.isEmpty) {
        await _createDefaultCategories();
        await _loadCategories(); // 다시 로드
      } else {
        setState(() {
          _categories = categories;
        });
      }
    } catch (e) {
      print('❌ 카테고리 로드 오류: $e');
    }
  }

  /// 기본 카테고리 생성
  Future<void> _createDefaultCategories() async {
    if (_currentGroup == null) return;

    final defaultCategories = [
      {'name': '식비', 'icon': '🍽️', 'color': Colors.orange},
      {'name': '교통비', 'icon': '🚌', 'color': Colors.blue},
      {'name': '카페', 'icon': '☕', 'color': Colors.brown},
      {'name': '취미', 'icon': '🎨', 'color': Colors.purple},
      {'name': '주거비', 'icon': '🏠', 'color': Colors.green},
    ];

    for (final categoryData in defaultCategories) {
      final category = Category(
        id: '',
        groupId: _currentGroup!.id,
        name: categoryData['name'] as String,
        icon: categoryData['icon'] as String,
        color: categoryData['color'] as Color,
      );

      await _categoryService.addCategory(category);
    }

    print('✅ 기본 카테고리 생성 완료');
  }

  /// 멤버 정보 로드
  Future<void> _loadMembers() async {
    if (_currentGroup == null) return;

    try {
      final List<UserModel> members = [];

      for (final memberId in _currentGroup!.members) {
        final userDoc = await firestore.FirebaseFirestore.instance
            .collection('users')
            .doc(memberId)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          final user = UserModel.fromMap(userData, memberId);
          members.add(user);
        }
      }

      setState(() {
        _members = members;
      });
    } catch (e) {
      print('❌ 멤버 로드 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: DesignSystem.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: DesignSystem.background,
      appBar: AppBar(
        backgroundColor: DesignSystem.surface,
        elevation: 0,
        title: Text(
          '모임 관리',
          style: DesignSystem.headline3.copyWith(
            color: DesignSystem.textPrimary,
          ),
        ),
        actions: [
          if (_currentGroup != null)
            IconButton(
              icon: const Icon(Icons.add, color: DesignSystem.textPrimary),
              onPressed: _showCreateGroupScreen,
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: DesignSystem.getScreenPadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: DesignSystem.spacing24),

              // 모임 멤버 관리
              if (_currentGroup != null) ...[
                _buildSectionTitle('모임 멤버 관리'),
                const SizedBox(height: DesignSystem.spacing16),
                _buildMembersSection(),
                const SizedBox(height: DesignSystem.spacing32),
              ],

              // 카테고리 관리
              if (_currentGroup != null) ...[
                _buildSectionTitle('카테고리 관리'),
                const SizedBox(height: DesignSystem.spacing16),
                _buildCategoriesSection(),
                const SizedBox(height: DesignSystem.spacing32),
              ],

              // 내 모임들
              _buildSectionTitle('내 모임들'),
              const SizedBox(height: DesignSystem.spacing16),
              _buildMyGroupsSection(),

              const SizedBox(height: DesignSystem.spacing24),
            ],
          ),
        ),
      ),
    );
  }

  /// 섹션 제목
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: DesignSystem.headline2.copyWith(
        color: DesignSystem.textPrimary,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  /// 모임 멤버 섹션
  Widget _buildMembersSection() {
    if (_members.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(DesignSystem.spacing32),
          child: Text('모임 멤버가 없습니다', style: DesignSystem.body1),
        ),
      );
    }

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _members.length,
        itemBuilder: (context, index) {
          final member = _members[index];
          final isOwner = member.id == _currentGroup!.ownerId;

          return Container(
            width: 100,
            margin: const EdgeInsets.only(right: DesignSystem.spacing16),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
              ),
              child: Padding(
                padding: const EdgeInsets.all(DesignSystem.spacing16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: isOwner
                          ? DesignSystem.primary
                          : DesignSystem.surface,
                      child: Text(
                        member.name.isNotEmpty ? member.name[0] : '?',
                        style: DesignSystem.headline3.copyWith(
                          color: isOwner
                              ? Colors.white
                              : DesignSystem.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: DesignSystem.spacing8),
                    Text(
                      member.name.isNotEmpty ? member.name : '이름 없음',
                      style: DesignSystem.body2.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (isOwner)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: DesignSystem.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          '모임장',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// 카테고리 섹션
  Widget _buildCategoriesSection() {
    return Column(
      children: [
        // 카테고리 목록
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: DesignSystem.spacing16,
            mainAxisSpacing: DesignSystem.spacing16,
            childAspectRatio: 1.2,
          ),
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final category = _categories[index];
            return _buildCategoryCard(category);
          },
        ),

        const SizedBox(height: DesignSystem.spacing16),

        // 새 카테고리 추가 버튼
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _showAddCategoryDialog,
            icon: const Icon(Icons.add),
            label: const Text('새 카테고리 추가'),
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignSystem.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                vertical: DesignSystem.spacing16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 카테고리 카드
  Widget _buildCategoryCard(Category category) {
    return GestureDetector(
      onTap: () => _showEditCategoryDialog(category),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
        ),
        child: Padding(
          padding: const EdgeInsets.all(DesignSystem.spacing16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(category.icon, style: const TextStyle(fontSize: 32)),
              const SizedBox(height: DesignSystem.spacing8),
              Text(
                category.name,
                style: DesignSystem.body2.copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 새 카테고리 추가 다이얼로그
  void _showAddCategoryDialog() {
    final nameController = TextEditingController();
    String selectedIcon = '🍽️';
    Color selectedColor = Colors.blue;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('새 카테고리 추가'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 카테고리 이름 입력
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: '카테고리 이름',
                    border: OutlineInputBorder(),
                    hintText: '예: 식비, 교통비, 쇼핑',
                  ),
                ),
                const SizedBox(height: 20),

                // 아이콘 선택
                const Text(
                  '아이콘 선택',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 8,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                    itemCount: _categoryService.getAvailableIcons().length,
                    itemBuilder: (context, index) {
                      final icon = _categoryService.getAvailableIcons()[index];
                      final isSelected = selectedIcon == icon;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedIcon = icon;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.blue.withOpacity(0.2)
                                : Colors.transparent,
                            border: Border.all(
                              color: isSelected
                                  ? Colors.blue
                                  : Colors.grey.shade300,
                              width: isSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              icon,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // 색상 선택
                const Text(
                  '색상 선택',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      [
                        Colors.red,
                        Colors.pink,
                        Colors.purple,
                        Colors.deepPurple,
                        Colors.indigo,
                        Colors.blue,
                        Colors.lightBlue,
                        Colors.cyan,
                        Colors.teal,
                        Colors.green,
                        Colors.lightGreen,
                        Colors.lime,
                        Colors.yellow,
                        Colors.amber,
                        Colors.orange,
                        Colors.deepOrange,
                        Colors.brown,
                        Colors.grey,
                        Colors.blueGrey,
                      ].map((color) {
                        final isSelected = selectedColor == color;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedColor = color;
                            });
                          },
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? Colors.black
                                    : Colors.grey.shade400,
                                width: isSelected ? 3 : 2,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  final category = Category(
                    id: '',
                    groupId: _currentGroup!.id,
                    name: nameController.text.trim(),
                    icon: selectedIcon,
                    color: selectedColor,
                  );

                  await _categoryService.addCategory(category);
                  Navigator.pop(context);
                  await _loadCategories();
                }
              },
              child: const Text('추가'),
            ),
          ],
        ),
      ),
    );
  }

  /// 카테고리 수정 다이얼로그
  void _showEditCategoryDialog(Category category) {
    final nameController = TextEditingController(text: category.name);
    final iconController = TextEditingController(text: category.icon);
    Color selectedColor = category.color;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('카테고리 수정'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: '카테고리 이름',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: iconController,
              decoration: const InputDecoration(
                labelText: '아이콘 (이모지)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('색상: '),
                ...Colors.primaries
                    .take(8)
                    .map(
                      (color) => GestureDetector(
                        onTap: () => selectedColor = color,
                        child: Container(
                          width: 24,
                          height: 24,
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selectedColor == color
                                  ? Colors.black
                                  : Colors.grey,
                              width: selectedColor == color ? 2 : 1,
                            ),
                          ),
                        ),
                      ),
                    ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty &&
                  iconController.text.isNotEmpty) {
                final updatedCategory = category.copyWith(
                  name: nameController.text.trim(),
                  icon: iconController.text.trim(),
                  color: selectedColor,
                );

                await _categoryService.updateCategory(updatedCategory.id, {
                  'name': updatedCategory.name,
                  'icon': updatedCategory.icon,
                  'color': updatedCategory.color.value,
                });
                Navigator.pop(context);
                await _loadCategories();
              }
            },
            child: const Text('수정'),
          ),
        ],
      ),
    );
  }

  /// 내 모임들 섹션
  Widget _buildMyGroupsSection() {
    if (_myGroups.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: _myGroups.map((group) => _buildGroupCard(group)).toList(),
    );
  }

  /// 모임 카드
  Widget _buildGroupCard(Group group) {
    final isSelected = _currentGroup?.id == group.id;

    return Card(
      margin: const EdgeInsets.only(bottom: DesignSystem.spacing16),
      elevation: isSelected ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
        side: BorderSide(
          color: isSelected ? DesignSystem.primary : Colors.transparent,
          width: isSelected ? 2 : 0,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(DesignSystem.spacing16),
        leading: CircleAvatar(
          backgroundColor: DesignSystem.primary,
          child: Text(
            group.name.isNotEmpty ? group.name[0] : '?',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        title: Text(
          group.name,
          style: DesignSystem.headline3.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: DesignSystem.spacing8),
            Text(
              '멤버 ${group.members.length}명 • 카테고리 ${group.categories.length}개',
              style: DesignSystem.body2.copyWith(
                color: DesignSystem.textSecondary,
              ),
            ),
            if (group.ownerId == _currentUserId)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: DesignSystem.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '모임장',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        trailing: isSelected
            ? const Icon(
                Icons.check_circle,
                color: DesignSystem.primary,
                size: 28,
              )
            : const Icon(Icons.arrow_forward_ios),
        onTap: () {
          _appStateService.selectGroup(group);
          _loadData();
        },
      ),
    );
  }

  /// 빈 상태 표시
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.spacing48),
        child: Column(
          children: [
            Icon(
              Icons.group_outlined,
              size: 64,
              color: DesignSystem.textSecondary,
            ),
            const SizedBox(height: DesignSystem.spacing16),
            Text(
              '아직 참여한 모임이 없어요',
              style: DesignSystem.headline3.copyWith(
                color: DesignSystem.textSecondary,
              ),
            ),
            const SizedBox(height: DesignSystem.spacing8),
            Text(
              '새로운 모임을 만들거나 기존 모임에 참여해보세요!',
              style: DesignSystem.body1.copyWith(
                color: DesignSystem.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DesignSystem.spacing24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _showCreateGroupScreen,
                  icon: const Icon(Icons.add),
                  label: const Text('모임 만들기'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignSystem.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: _showJoinGroupScreen,
                  icon: const Icon(Icons.group_add),
                  label: const Text('모임 참여'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: DesignSystem.primary,
                    side: const BorderSide(color: DesignSystem.primary),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 모임 생성 화면 표시
  void _showCreateGroupScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateGroupScreen()),
    ).then((_) => _loadData());
  }

  /// 모임 참여 화면 표시
  void _showJoinGroupScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const JoinGroupScreen()),
    ).then((_) => _loadData());
  }
}
