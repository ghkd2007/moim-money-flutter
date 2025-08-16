import 'package:flutter/material.dart';
import '../../../constants/design_system.dart';
import '../../../widgets/common/app_button.dart';
import '../../../widgets/common/app_text_field.dart';
import '../../../models/models.dart';
import 'create_group_screen.dart';

/// 모임 화면
/// 현재 모임 정보, 멤버들의 수입/지출 정보, 초대 기능, 모임 변경 기능을 제공합니다.
class GroupScreen extends StatefulWidget {
  const GroupScreen({super.key});

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  // 현재 선택된 모임 (HomeScreen과 동일한 모임)
  final Group _currentGroup = Group(
    id: '1',
    name: '가족 모임',
    description: '가족과 함께하는 금융 관리',
    members: ['user1', 'user2', 'user3', 'user4'],
    categories: ['cat1', 'cat2', 'cat3'],
    transactions: ['trans1', 'trans2', 'trans3', 'trans4'],
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  // 임시 사용자 데이터 (추후 Firebase에서 가져올 예정)
  final Map<String, UserModel> _users = {
    'user1': UserModel(
      id: 'user1',
      name: '김철수',
      email: 'kim@example.com',
      phone: '010-1234-5678',
      profileImageUrl: null,
      groupIds: ['1'],
      settings: {},
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    'user2': UserModel(
      id: 'user2',
      name: '이영희',
      email: 'lee@example.com',
      phone: '010-2345-6789',
      profileImageUrl: null,
      groupIds: ['1'],
      settings: {},
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    '3': UserModel(
      id: 'user3',
      name: '박민수',
      email: 'park@example.com',
      phone: '010-3456-7890',
      profileImageUrl: null,
      groupIds: ['1'],
      settings: {},
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    'user4': UserModel(
      id: 'user4',
      name: '최지영',
      email: 'choi@example.com',
      phone: '010-4567-8901',
      profileImageUrl: null,
      groupIds: ['1'],
      settings: {},
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  };

  // 임시 거래 내역 데이터 (추후 Firebase에서 가져올 예정)
  final Map<String, List<Transaction>> _userTransactions = {
    'user1': [
      Transaction(
        id: '1',
        groupId: '1',
        userId: 'user1',
        type: 'expense',
        amount: -4500,
        categoryId: 'cat1',
        description: '아침 커피',
        date: DateTime.now().subtract(const Duration(days: 1)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Transaction(
        id: '2',
        groupId: '1',
        userId: 'user1',
        type: 'income',
        amount: 2500000,
        categoryId: 'cat3',
        description: '월급',
        date: DateTime.now().subtract(const Duration(days: 2)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ],
    'user2': [
      Transaction(
        id: '3',
        groupId: '1',
        userId: 'user2',
        type: 'expense',
        amount: -12000,
        categoryId: 'cat2',
        description: '점심 식사',
        date: DateTime.now().subtract(const Duration(hours: 3)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ],
    'user3': [
      Transaction(
        id: '4',
        groupId: '1',
        userId: 'user3',
        type: 'expense',
        amount: -15000,
        categoryId: 'cat4',
        description: '영화 관람',
        date: DateTime.now().subtract(const Duration(days: 1)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ],
    'user4': [
      Transaction(
        id: '5',
        groupId: '1',
        userId: 'user4',
        type: 'expense',
        amount: -8000,
        categoryId: 'cat2',
        description: '저녁 식사',
        date: DateTime.now().subtract(const Duration(hours: 6)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ],
  };

  // 임시 카테고리 데이터 (추후 Firebase에서 가져올 예정)
  final Map<String, Category> _categories = {
    'cat1': Category(
      id: 'cat1',
      groupId: '1',
      name: '식비',
      color: DesignSystem.expense,
      icon: '🍽️',
    ),
    'cat2': Category(
      id: 'cat2',
      groupId: '1',
      name: '교통비',
      color: DesignSystem.info,
      icon: '🚌',
    ),
    'cat3': Category(
      id: 'cat3',
      groupId: '1',
      name: '수입',
      color: DesignSystem.income,
      icon: '💰',
    ),
    'cat4': Category(
      id: 'cat4',
      groupId: '1',
      name: '문화생활',
      color: DesignSystem.warning,
      icon: '🎬',
    ),
  };

  // 내가 참여하고 있는 모든 모임 (추후 Firebase에서 가져올 예정)
  final List<Group> _myGroups = [
    Group(
      id: '1',
      name: '가족 모임',
      description: '가족과 함께하는 금융 관리',
      members: ['user1', 'user2', 'user3', 'user4'],
      categories: ['cat1', 'cat2', 'cat3'],
      transactions: ['trans1', 'trans2', 'trans3', 'trans4'],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Group(
      id: '2',
      name: '친구 모임',
      description: '친구들과 함께하는 여행 자금 관리',
      members: ['user1', 'user5', 'user6'],
      categories: ['cat5', 'cat6'],
      transactions: ['trans5', 'trans6'],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Group(
      id: '3',
      name: '동호회 모임',
      description: '동호회 활동비 관리',
      members: ['user1', 'user7', 'user8', 'user9'],
      categories: ['cat7', 'cat8'],
      transactions: ['trans7', 'trans8'],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignSystem.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // 메인 콘텐츠
            SliverToBoxAdapter(
              child: Padding(
                padding: DesignSystem.getScreenPadding(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: DesignSystem.spacing24),

                    // 현재 모임 정보
                    _buildCurrentGroupInfo(),

                    const SizedBox(height: DesignSystem.spacing24),

                    // 모임 멤버들
                    _buildMembersSection(),

                    const SizedBox(height: DesignSystem.spacing24),

                    // 카테고리 관리
                    _buildCategoriesSection(),

                    const SizedBox(height: DesignSystem.spacing24),

                    // 내가 참여하고 있는 모든 모임
                    _buildMyGroupsSection(),

                    const SizedBox(height: DesignSystem.spacing32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // 모임 생성 버튼
          FloatingActionButton(
            onPressed: () => _showCreateGroupScreen(),
            backgroundColor: DesignSystem.info,
            child: const Icon(Icons.add, color: Colors.white),
            heroTag: 'create_group',
          ),
          const SizedBox(height: DesignSystem.spacing16),
          // 멤버 초대 버튼
          FloatingActionButton(
            onPressed: () => _showInviteDialog(),
            backgroundColor: DesignSystem.primary,
            child: const Icon(Icons.person_add, color: Colors.white),
            heroTag: 'invite_member',
          ),
        ],
      ),
    );
  }

  /// 현재 모임 정보
  Widget _buildCurrentGroupInfo() {
    return Card(
      elevation: DesignSystem.shadowSmall[0].blurRadius,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.spacing20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.group, color: DesignSystem.primary, size: 24),
                const SizedBox(width: DesignSystem.spacing12),
                Expanded(
                  child: Text(
                    _currentGroup.name,
                    style: DesignSystem.headline2.copyWith(
                      color: DesignSystem.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            if (_currentGroup.description != null) ...[
              const SizedBox(height: DesignSystem.spacing8),
              Text(
                _currentGroup.description!,
                style: DesignSystem.body1.copyWith(
                  color: DesignSystem.textSecondary,
                ),
              ),
            ],

            const SizedBox(height: DesignSystem.spacing16),

            // 모임 통계
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    '멤버',
                    '${_currentGroup.members.length}명',
                    Icons.people,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    '카테고리',
                    '${_currentGroup.categories.length}개',
                    Icons.category,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    '거래내역',
                    '${_currentGroup.transactions.length}건',
                    Icons.receipt_long,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 통계 아이템
  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: DesignSystem.primary, size: 20),
        const SizedBox(height: DesignSystem.spacing4),
        Text(
          value,
          style: DesignSystem.headline3.copyWith(
            fontWeight: FontWeight.bold,
            color: DesignSystem.textPrimary,
          ),
        ),
        Text(
          label,
          style: DesignSystem.caption.copyWith(
            color: DesignSystem.textSecondary,
          ),
        ),
      ],
    );
  }

  /// 카테고리 관리 섹션
  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '카테고리 관리',
              style: DesignSystem.headline3.copyWith(
                color: DesignSystem.textPrimary,
              ),
            ),
            TextButton.icon(
              onPressed: () => _showAddCategoryDialog(),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('추가'),
              style: TextButton.styleFrom(
                foregroundColor: DesignSystem.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: DesignSystem.spacing16),

        // 카테고리 목록
        ..._categories.values
            .map((category) => _buildCategoryCard(category))
            .toList(),
      ],
    );
  }

  /// 카테고리 카드
  Widget _buildCategoryCard(Category category) {
    return Card(
      margin: const EdgeInsets.only(bottom: DesignSystem.spacing12),
      elevation: DesignSystem.shadowSmall[0].blurRadius,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.spacing16),
        child: Row(
          children: [
            // 카테고리 아이콘
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: category.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(
                  DesignSystem.radiusCircular,
                ),
              ),
              child: Center(
                child: Text(
                  category.icon,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(width: DesignSystem.spacing12),

            // 카테고리 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    style: DesignSystem.body1.copyWith(
                      fontWeight: FontWeight.w600,
                      color: DesignSystem.textPrimary,
                    ),
                  ),
                  Text(
                    '그룹: ${_currentGroup.name}',
                    style: DesignSystem.caption.copyWith(
                      color: DesignSystem.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // 액션 버튼들
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, size: 18),
                  onPressed: () => _showEditCategoryDialog(category),
                  color: DesignSystem.info,
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 18),
                  onPressed: () => _showDeleteCategoryDialog(category),
                  color: DesignSystem.error,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 모임 멤버들 섹션
  Widget _buildMembersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '모임 멤버',
              style: DesignSystem.headline3.copyWith(
                color: DesignSystem.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () => _showInviteDialog(),
              child: Text(
                '초대하기',
                style: TextStyle(color: DesignSystem.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: DesignSystem.spacing16),

        // 멤버 카드들
        ..._currentGroup.members.map((userId) {
          final user = _users[userId];
          if (user == null) return const SizedBox.shrink();

          return _buildMemberCard(user);
        }).toList(),
      ],
    );
  }

  /// 멤버 카드
  Widget _buildMemberCard(UserModel user) {
    final userTransactions = _userTransactions[user.id] ?? [];
    final totalIncome = userTransactions
        .where((t) => t.isIncome)
        .fold(0, (sum, t) => sum + t.amount);
    final totalExpense = userTransactions
        .where((t) => t.isExpense)
        .fold(0, (sum, t) => sum + t.amount.abs());

    return Card(
      margin: const EdgeInsets.only(bottom: DesignSystem.spacing12),
      elevation: DesignSystem.shadowSmall[0].blurRadius,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DesignSystem.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 멤버 기본 정보
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: DesignSystem.primary.withOpacity(0.1),
                  child: Text(
                    user.name[0],
                    style: DesignSystem.body1.copyWith(
                      color: DesignSystem.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: DesignSystem.spacing12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: DesignSystem.body1.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (user.phone != null)
                        Text(
                          user.phone!,
                          style: DesignSystem.caption.copyWith(
                            color: DesignSystem.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () => _showMemberOptions(user),
                ),
              ],
            ),

            const SizedBox(height: DesignSystem.spacing16),

            // 수입/지출 요약
            Row(
              children: [
                Expanded(
                  child: _buildTransactionSummary(
                    '수입',
                    totalIncome,
                    DesignSystem.income,
                    Icons.add_circle,
                  ),
                ),
                Expanded(
                  child: _buildTransactionSummary(
                    '지출',
                    totalExpense,
                    DesignSystem.expense,
                    Icons.remove_circle,
                  ),
                ),
              ],
            ),

            const SizedBox(height: DesignSystem.spacing16),
          ],
        ),
      ),
    );
  }

  /// 거래 내역 요약
  Widget _buildTransactionSummary(
    String label,
    int amount,
    Color color,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(height: DesignSystem.spacing4),
        Text(
          '${amount.toStringAsLocaleString()}원',
          style: DesignSystem.body2.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        Text(
          label,
          style: DesignSystem.caption.copyWith(
            color: DesignSystem.textSecondary,
          ),
        ),
      ],
    );
  }

  /// 거래 내역 아이템 (간단 버전)
  Widget _buildTransactionItem(Transaction transaction) {
    final isExpense = transaction.isExpense;
    final color = isExpense ? DesignSystem.expense : DesignSystem.income;
    final icon = isExpense ? Icons.remove_circle : Icons.add_circle;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DesignSystem.spacing4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: DesignSystem.spacing8),
          Expanded(
            child: Text(
              transaction.description ?? '거래 내역',
              style: DesignSystem.caption.copyWith(
                color: DesignSystem.textSecondary,
              ),
            ),
          ),
          Text(
            '${isExpense ? '-' : '+'}${transaction.amount.abs().toStringAsLocaleString()}원',
            style: DesignSystem.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// 내가 참여하고 있는 모든 모임 섹션
  Widget _buildMyGroupsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '내가 참여하고 있는 모임',
          style: DesignSystem.headline3.copyWith(
            color: DesignSystem.textPrimary,
          ),
        ),
        const SizedBox(height: DesignSystem.spacing16),

        // 모임 목록
        ..._myGroups.map((group) => _buildGroupListItem(group)).toList(),
      ],
    );
  }

  /// 모임 목록 아이템
  Widget _buildGroupListItem(Group group) {
    final isCurrentGroup = group.id == _currentGroup.id;

    return Card(
      margin: const EdgeInsets.only(bottom: DesignSystem.spacing12),
      elevation: DesignSystem.shadowSmall[0].blurRadius,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
      ),
      child: InkWell(
        onTap: () => _switchToGroup(group),
        borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
        child: Container(
          padding: const EdgeInsets.all(DesignSystem.spacing16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
            border: isCurrentGroup
                ? Border.all(color: DesignSystem.primary, width: 2)
                : null,
          ),
          child: Row(
            children: [
              Icon(
                Icons.group,
                color: isCurrentGroup
                    ? DesignSystem.primary
                    : DesignSystem.textSecondary,
                size: 20,
              ),
              const SizedBox(width: DesignSystem.spacing12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      style: DesignSystem.body1.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isCurrentGroup
                            ? DesignSystem.primary
                            : DesignSystem.textPrimary,
                      ),
                    ),
                    if (group.description != null)
                      Text(
                        group.description!,
                        style: DesignSystem.caption.copyWith(
                          color: DesignSystem.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              if (isCurrentGroup)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DesignSystem.spacing8,
                    vertical: DesignSystem.spacing4,
                  ),
                  decoration: BoxDecoration(
                    color: DesignSystem.primary,
                    borderRadius: BorderRadius.circular(
                      DesignSystem.radiusCircular,
                    ),
                  ),
                  child: Text(
                    '현재',
                    style: DesignSystem.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// 모임 선택기 표시
  void _showGroupSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: DesignSystem.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(DesignSystem.radiusLarge),
          ),
        ),
        child: Column(
          children: [
            // 헤더
            Container(
              padding: const EdgeInsets.all(DesignSystem.spacing20),
              decoration: BoxDecoration(
                color: DesignSystem.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(DesignSystem.radiusLarge),
                ),
                boxShadow: DesignSystem.shadowSmall,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '모임 선택',
                    style: DesignSystem.headline3.copyWith(
                      color: DesignSystem.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // 모임 목록
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(DesignSystem.spacing20),
                itemCount: _myGroups.length,
                itemBuilder: (context, index) {
                  final group = _myGroups[index];
                  return _buildGroupSelectorItem(group);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 모임 선택기 아이템
  Widget _buildGroupSelectorItem(Group group) {
    final isCurrentGroup = group.id == _currentGroup.id;

    return ListTile(
      leading: Icon(
        Icons.group,
        color: isCurrentGroup
            ? DesignSystem.primary
            : DesignSystem.textSecondary,
      ),
      title: Text(
        group.name,
        style: TextStyle(
          fontWeight: isCurrentGroup ? FontWeight.w600 : FontWeight.normal,
          color: isCurrentGroup
              ? DesignSystem.primary
              : DesignSystem.textPrimary,
        ),
      ),
      subtitle: group.description != null ? Text(group.description!) : null,
      trailing: isCurrentGroup
          ? Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DesignSystem.spacing8,
                vertical: DesignSystem.spacing4,
              ),
              decoration: BoxDecoration(
                color: DesignSystem.primary,
                borderRadius: BorderRadius.circular(
                  DesignSystem.radiusCircular,
                ),
              ),
              child: Text(
                '현재',
                style: DesignSystem.caption.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : null,
      onTap: () {
        Navigator.pop(context);
        _switchToGroup(group);
      },
    );
  }

  /// 모임 초대 다이얼로그
  void _showInviteDialog() {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('모임에 초대하기', style: DesignSystem.headline3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '초대할 사용자의 이메일을 입력하세요.',
              style: DesignSystem.body2.copyWith(
                color: DesignSystem.textSecondary,
              ),
            ),
            const SizedBox(height: DesignSystem.spacing16),
            AppEmailField(controller: emailController, isRequired: true),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소'),
          ),
          AppButton(
            text: '초대하기',
            onPressed: () {
              // 초대 로직 (추후 Firebase 연동)
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${emailController.text}에게 초대 메일을 보냈습니다.'),
                  backgroundColor: DesignSystem.success,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// 멤버 옵션 표시
  void _showMemberOptions(UserModel user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: DesignSystem.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(DesignSystem.radiusLarge),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.message),
              title: const Text('메시지 보내기'),
              onTap: () {
                Navigator.pop(context);
                // 메시지 기능 (향후 구현)
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_remove),
              title: const Text('모임에서 제거'),
              onTap: () {
                Navigator.pop(context);
                _showRemoveMemberDialog(user);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 멤버 제거 다이얼로그
  void _showRemoveMemberDialog(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('멤버 제거'),
        content: Text('${user.name}님을 모임에서 제거하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소'),
          ),
          AppButton(
            text: '제거',
            onPressed: () {
              Navigator.pop(context);
              // 제거 로직 (추후 Firebase 연동)
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${user.name}님이 모임에서 제거되었습니다.'),
                  backgroundColor: DesignSystem.success,
                ),
              );
            },
            type: AppButtonType.secondary,
          ),
        ],
      ),
    );
  }

  /// 모임 생성 화면 표시
  void _showCreateGroupScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateGroupScreen()),
    );
  }

  /// 모임 변경
  void _switchToGroup(Group newGroup) {
    // 실제로는 Provider나 상태 관리자를 통해 현재 모임을 변경
    setState(() {
      // 임시로 현재 모임을 변경 (실제로는 상태 관리 필요)
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${newGroup.name}으로 모임을 변경했습니다.'),
        backgroundColor: DesignSystem.success,
      ),
    );
  }

  /// 카테고리 추가 다이얼로그
  void _showAddCategoryDialog() {
    final nameController = TextEditingController();
    final iconController = TextEditingController(text: '📁');
    Color selectedColor = DesignSystem.primary;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('새 카테고리 추가', style: DesignSystem.headline3),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                label: '카테고리 이름',
                hint: '예: 식비, 교통비',
                controller: nameController,
                isRequired: true,
              ),
              const SizedBox(height: DesignSystem.spacing16),
              AppTextField(
                label: '아이콘 (이모지)',
                hint: '📁',
                controller: iconController,
                isRequired: true,
              ),
              const SizedBox(height: DesignSystem.spacing16),
              Text(
                '색상 선택',
                style: DesignSystem.body2.copyWith(
                  color: DesignSystem.textSecondary,
                ),
              ),
              const SizedBox(height: DesignSystem.spacing8),
              Wrap(
                spacing: DesignSystem.spacing8,
                children: [
                  _buildColorOption(DesignSystem.primary, selectedColor, (
                    color,
                  ) {
                    setState(() => selectedColor = color);
                  }),
                  _buildColorOption(DesignSystem.expense, selectedColor, (
                    color,
                  ) {
                    setState(() => selectedColor = color);
                  }),
                  _buildColorOption(DesignSystem.income, selectedColor, (
                    color,
                  ) {
                    setState(() => selectedColor = color);
                  }),
                  _buildColorOption(DesignSystem.info, selectedColor, (color) {
                    setState(() => selectedColor = color);
                  }),
                  _buildColorOption(DesignSystem.warning, selectedColor, (
                    color,
                  ) {
                    setState(() => selectedColor = color);
                  }),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            AppButton(
              text: '추가',
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  // 카테고리 추가 로직 (추후 Firebase 연동)
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${nameController.text} 카테고리가 추가되었습니다.'),
                      backgroundColor: DesignSystem.success,
                    ),
                  );
                }
              },
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
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('카테고리 수정', style: DesignSystem.headline3),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                label: '카테고리 이름',
                hint: '예: 식비, 교통비',
                controller: nameController,
                isRequired: true,
              ),
              const SizedBox(height: DesignSystem.spacing16),
              AppTextField(
                label: '아이콘 (이모지)',
                hint: '📁',
                controller: iconController,
                isRequired: true,
              ),
              const SizedBox(height: DesignSystem.spacing16),
              Text(
                '색상 선택',
                style: DesignSystem.body2.copyWith(
                  color: DesignSystem.textSecondary,
                ),
              ),
              const SizedBox(height: DesignSystem.spacing8),
              Wrap(
                spacing: DesignSystem.spacing8,
                children: [
                  _buildColorOption(DesignSystem.primary, selectedColor, (
                    color,
                  ) {
                    setState(() => selectedColor = color);
                  }),
                  _buildColorOption(DesignSystem.expense, selectedColor, (
                    color,
                  ) {
                    setState(() => selectedColor = color);
                  }),
                  _buildColorOption(DesignSystem.income, selectedColor, (
                    color,
                  ) {
                    setState(() => selectedColor = color);
                  }),
                  _buildColorOption(DesignSystem.info, selectedColor, (color) {
                    setState(() => selectedColor = color);
                  }),
                  _buildColorOption(DesignSystem.warning, selectedColor, (
                    color,
                  ) {
                    setState(() => selectedColor = color);
                  }),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            AppButton(
              text: '수정',
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  // 카테고리 수정 로직 (추후 Firebase 연동)
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${nameController.text} 카테고리가 수정되었습니다.'),
                      backgroundColor: DesignSystem.success,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 카테고리 삭제 다이얼로그
  void _showDeleteCategoryDialog(Category category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('카테고리 삭제'),
        content: Text(
          '${category.name} 카테고리를 삭제하시겠습니까?\n\n이 카테고리를 사용하는 거래 내역이 있다면 주의가 필요합니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          AppButton(
            text: '삭제',
            onPressed: () {
              // 카테고리 삭제 로직 (추후 Firebase 연동)
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${category.name} 카테고리가 삭제되었습니다.'),
                  backgroundColor: DesignSystem.success,
                ),
              );
            },
            type: AppButtonType.secondary,
          ),
        ],
      ),
    );
  }

  /// 색상 선택 옵션
  Widget _buildColorOption(
    Color color,
    Color selectedColor,
    Function(Color) onTap,
  ) {
    final isSelected = color == selectedColor;
    return GestureDetector(
      onTap: () => onTap(color),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? DesignSystem.textPrimary : Colors.transparent,
            width: 3,
          ),
        ),
      ),
    );
  }
}

/// 숫자 포맷팅 확장
extension NumberFormatting on num {
  String toStringAsLocaleString() {
    return toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}
