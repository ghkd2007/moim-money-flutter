import 'package:flutter/material.dart';
import '../../constants/design_system.dart';
import '../../services/category_service.dart';
import '../../models/category_model.dart';
import 'home/home_screen.dart';
import 'group/group_screen.dart';
import 'settings/settings_screen.dart';

/// 메인 네비게이션 화면
/// 로그인 후 사용자가 보게 되는 메인 화면입니다.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // 거래 추가 모달 상태
  String _selectedTransactionType = 'expense'; // 기본값: 지출
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  // 카테고리 관련 상태
  final CategoryService _categoryService = CategoryService();
  List<Category> _categories = [];
  bool _isLoadingCategories = false;

  // 탭 화면들
  final List<Widget> _screens = [
    const HomeScreen(),
    const GroupScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignSystem.background,
      body: _screens[_currentIndex],
      bottomNavigationBar: _buildCustomTabBar(),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  /// 현대적인 커스텀 탭 바 (토스 스타일)
  Widget _buildCustomTabBar() {
    return Container(
      margin: EdgeInsets.only(
        left: DesignSystem.spacing16,
        right: DesignSystem.spacing16,
        top: DesignSystem.spacing16,
        bottom: DesignSystem.spacing32, // 플로팅 버튼과 겹치지 않도록 하단 마진 증가
      ),
      decoration: BoxDecoration(
        color: DesignSystem.surface,
        borderRadius: BorderRadius.circular(DesignSystem.radiusUltra),
        boxShadow: DesignSystem.shadowModern,
        border: Border.all(
          color: DesignSystem.divider.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: DesignSystem.spacing8,
          vertical: DesignSystem.spacing12,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildTabItem(0, Icons.home_outlined, Icons.home, '홈'),
            _buildTabItem(1, Icons.group_outlined, Icons.group, '모임'),
            _buildTabItem(2, Icons.settings_outlined, Icons.settings, '설정'),
          ],
        ),
      ),
    );
  }

  /// 탭 아이템
  Widget _buildTabItem(
    int index,
    IconData inactiveIcon,
    IconData activeIcon,
    String label,
  ) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: DesignSystem.animationNormal,
        curve: DesignSystem.curveFastOutSlowIn,
        padding: EdgeInsets.symmetric(
          horizontal: DesignSystem.spacing16,
          vertical: DesignSystem.spacing12,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? DesignSystem.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(DesignSystem.radiusCircular),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : inactiveIcon,
              color: isSelected
                  ? DesignSystem.primary
                  : DesignSystem.textSecondary,
              size: 24,
            ),
            const SizedBox(height: DesignSystem.spacing4),
            Text(
              label,
              style:
                  (isSelected ? DesignSystem.labelLarge : DesignSystem.caption)
                      .copyWith(
                        color: isSelected
                            ? DesignSystem.primary
                            : DesignSystem.textSecondary,
                      ),
            ),
          ],
        ),
      ),
    );
  }

  /// 플로팅 액션 버튼 (탭별로 다른 버튼 표시)
  Widget? _buildFloatingActionButton() {
    switch (_currentIndex) {
      case 0: // 홈 탭
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // SMS 자동 등록 버튼
            FloatingActionButton.small(
              heroTag: 'sms',
              onPressed: () {
                // SMS 자동 등록 기능
              },
              backgroundColor: DesignSystem.info,
              child: const Icon(Icons.sms, color: Colors.white),
            ),
            const SizedBox(height: DesignSystem.spacing16),
            // 지출 추가 버튼
            FloatingActionButton(
              heroTag: 'add',
              onPressed: () {
                // 홈 화면에서 거래 추가 모달 표시
                if (_currentIndex == 0) {
                  // 홈 탭일 때만 모달 표시
                  _showAddTransactionModal(context);
                }
              },
              backgroundColor: DesignSystem.primary,
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ],
        );
      case 1: // 모임 탭
        return FloatingActionButton(
          heroTag: 'create_group',
          onPressed: () {
            // 모임 생성 화면으로 이동
          },
          backgroundColor: DesignSystem.primary,
          child: const Icon(Icons.group_add, color: Colors.white),
        );
      case 2: // 설정 탭
        return null; // 설정 탭에서는 플로팅 버튼 없음
      default:
        return null;
    }
  }

  /// 거래 추가 모달 표시
  void _showAddTransactionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: DesignSystem.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(DesignSystem.radiusLarge),
          ),
        ),
        child: Column(
          children: [
            // 드래그 핸들
            Container(
              margin: const EdgeInsets.only(top: DesignSystem.spacing8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: DesignSystem.divider,
                borderRadius: BorderRadius.circular(
                  DesignSystem.radiusCircular,
                ),
              ),
            ),
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
                    '새 거래 추가',
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
            // 거래 추가 폼
            Expanded(child: _buildAddTransactionForm()),
          ],
        ),
      ),
    );
  }

  /// 거래 추가 폼
  Widget _buildAddTransactionForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesignSystem.spacing20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 거래 유형 선택
          Text(
            '거래 유형',
            style: DesignSystem.labelLarge.copyWith(
              color: DesignSystem.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: DesignSystem.spacing12),
          Row(
            children: [
              Expanded(
                child: _buildTransactionTypeButton(
                  type: 'expense',
                  label: '지출',
                  icon: Icons.trending_down,
                  color: DesignSystem.expense,
                ),
              ),
              const SizedBox(width: DesignSystem.spacing12),
              Expanded(
                child: _buildTransactionTypeButton(
                  type: 'income',
                  label: '수입',
                  icon: Icons.trending_up,
                  color: DesignSystem.income,
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignSystem.spacing24),

          // 금액 입력
          Text(
            '금액',
            style: DesignSystem.labelLarge.copyWith(
              color: DesignSystem.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: DesignSystem.spacing12),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: '0',
              suffixText: '원',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
                borderSide: BorderSide(color: DesignSystem.primary, width: 2),
              ),
            ),
          ),
          const SizedBox(height: DesignSystem.spacing24),

          // 카테고리 선택
          Text(
            '카테고리',
            style: DesignSystem.labelLarge.copyWith(
              color: DesignSystem.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: DesignSystem.spacing12),
          _buildCategorySelector(),
          const SizedBox(height: DesignSystem.spacing24),

          // 설명 입력
          Text(
            '설명 (선택사항)',
            style: DesignSystem.labelLarge.copyWith(
              color: DesignSystem.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: DesignSystem.spacing12),
          TextField(
            controller: _descriptionController,
            decoration: InputDecoration(
              hintText: '거래에 대한 설명을 입력하세요',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
                borderSide: BorderSide(color: DesignSystem.primary, width: 2),
              ),
            ),
          ),
          const SizedBox(height: DesignSystem.spacing24),

          // 날짜 선택
          Text(
            '날짜',
            style: DesignSystem.labelLarge.copyWith(
              color: DesignSystem.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: DesignSystem.spacing12),
          _buildDateSelector(),
          const SizedBox(height: DesignSystem.spacing32),

          // 거래 추가 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // 거래 추가 로직
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('거래가 추가되었습니다!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignSystem.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: DesignSystem.spacing16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    DesignSystem.radiusMedium,
                  ),
                ),
              ),
              child: Text(
                '거래 추가',
                style: DesignSystem.labelLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 거래 유형 선택 버튼
  Widget _buildTransactionTypeButton({
    required String type,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTransactionType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(DesignSystem.spacing16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
          border: Border.all(
            color: _selectedTransactionType == type
                ? color
                : color.withOpacity(0.3),
            width: _selectedTransactionType == type ? 3 : 2,
          ),
          color: _selectedTransactionType == type
              ? color.withOpacity(0.15)
              : color.withOpacity(0.05),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: _selectedTransactionType == type
                  ? color
                  : color.withOpacity(0.7),
              size: 32,
            ),
            const SizedBox(height: DesignSystem.spacing8),
            Text(
              label,
              style: DesignSystem.body2.copyWith(
                color: _selectedTransactionType == type
                    ? color
                    : color.withOpacity(0.7),
                fontWeight: _selectedTransactionType == type
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 카테고리 선택기
  Widget _buildCategorySelector() {
    if (_isLoadingCategories) {
      return Container(
        padding: const EdgeInsets.all(DesignSystem.spacing16),
        decoration: BoxDecoration(
          border: Border.all(color: DesignSystem.divider),
          borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: DesignSystem.spacing12),
            Text('카테고리 로딩 중...'),
          ],
        ),
      );
    }

    if (_categories.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(DesignSystem.spacing16),
        decoration: BoxDecoration(
          border: Border.all(color: DesignSystem.divider),
          borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
        ),
        child: Row(
          children: [
            Icon(Icons.category, color: DesignSystem.textSecondary, size: 24),
            const SizedBox(width: DesignSystem.spacing12),
            Text(
              '카테고리가 없습니다',
              style: DesignSystem.body1.copyWith(
                color: DesignSystem.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        _showCategoryPicker();
      },
      child: Container(
        padding: const EdgeInsets.all(DesignSystem.spacing16),
        decoration: BoxDecoration(
          border: Border.all(color: DesignSystem.divider),
          borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
        ),
        child: Row(
          children: [
            Icon(Icons.category, color: DesignSystem.textSecondary, size: 24),
            const SizedBox(width: DesignSystem.spacing12),
            Expanded(
              child: Text(
                '카테고리 선택',
                style: DesignSystem.body1.copyWith(
                  color: DesignSystem.textSecondary,
                ),
              ),
            ),
            Icon(Icons.arrow_drop_down, color: DesignSystem.textSecondary),
          ],
        ),
      ),
    );
  }

  /// 카테고리 선택 모달 표시
  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(DesignSystem.spacing20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '카테고리 선택',
              style: DesignSystem.headline3.copyWith(
                color: DesignSystem.textPrimary,
              ),
            ),
            const SizedBox(height: DesignSystem.spacing20),
            Expanded(
              child: ListView.builder(
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  return ListTile(
                    leading: Text(
                      category.icon,
                      style: const TextStyle(fontSize: 24),
                    ),
                    title: Text(category.name),
                    onTap: () {
                      Navigator.pop(context);
                      // 여기에 선택된 카테고리 처리 로직 추가
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 날짜 선택기
  Widget _buildDateSelector() {
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (date != null) {
          setState(() {
            _selectedDate = date;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(DesignSystem.spacing16),
        decoration: BoxDecoration(
          border: Border.all(color: DesignSystem.divider),
          borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: DesignSystem.textSecondary,
              size: 24,
            ),
            const SizedBox(width: DesignSystem.spacing12),
            Text(
              '${_selectedDate.year}년 ${_selectedDate.month}월 ${_selectedDate.day}일',
              style: DesignSystem.body1.copyWith(
                color: DesignSystem.textPrimary,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_drop_down, color: DesignSystem.textSecondary),
          ],
        ),
      ),
    );
  }

  /// 카테고리 로드 (안전한 방식)
  Future<void> _loadCategories() async {
    try {
      // 기본 카테고리 데이터 설정
      final defaultCategories = [
        Category(
          id: 'default_food',
          groupId: '1',
          name: '식비',
          color: DesignSystem.expense,
          icon: '🍽️',
        ),
        Category(
          id: 'default_transport',
          groupId: '1',
          name: '교통비',
          color: DesignSystem.info,
          icon: '🚌',
        ),
        Category(
          id: 'default_shopping',
          groupId: '1',
          name: '쇼핑',
          color: DesignSystem.warning,
          icon: '🛍️',
        ),
        Category(
          id: 'default_culture',
          groupId: '1',
          name: '문화생활',
          color: DesignSystem.primary,
          icon: '🎬',
        ),
      ];

      setState(() {
        _categories = defaultCategories;
      });
    } catch (e) {
      print('카테고리 로드 오류: $e');
      // 오류 발생 시 빈 리스트로 설정
      setState(() {
        _categories = [];
      });
    }
  }

  /// 기존 하단 네비게이션 바 (참고용)
  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(boxShadow: DesignSystem.shadowMedium),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: DesignSystem.surface,
        selectedItemColor: DesignSystem.primary,
        unselectedItemColor: DesignSystem.textSecondary,
        selectedLabelStyle: DesignSystem.body2.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: DesignSystem.body2,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group_outlined),
            activeIcon: Icon(Icons.group),
            label: '모임',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: '설정',
          ),
        ],
      ),
    );
  }
}
