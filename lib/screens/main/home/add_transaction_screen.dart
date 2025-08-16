import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import '../../../constants/design_system.dart';
import '../../../widgets/common/app_button.dart';
import '../../../models/models.dart';
import '../../../services/transaction_service.dart';
import '../../../services/app_state_service.dart';
import '../../../services/category_service.dart';

/// 지출/수입 추가 화면
/// 새로운 거래 내역을 추가하는 화면입니다.
class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  // 거래 타입 (지출/수입)
  String _transactionType = 'expense';

  // 입력 필드 컨트롤러
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // 선택된 값들
  String? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();

  // 서비스 인스턴스
  final TransactionService _transactionService = TransactionService();
  final AppStateService _appStateService = AppStateService();

  // 현재 사용자와 모임 정보
  String? _currentUserId;
  String? _currentGroupId;

  // 실제 카테고리 데이터 (Firebase에서 가져옴)
  List<Category> _categories = [];
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    _initializeUserAndGroup();
  }

  /// 사용자와 모임 정보 초기화
  void _initializeUserAndGroup() async {
    // 현재 사용자 ID 가져오기
    final currentUser = auth.FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _currentUserId = currentUser.uid;
      print('✅ AddTransactionScreen에서 사용자 ID 설정: ${currentUser.uid}');
    }

    // 현재 선택된 모임 ID 가져오기
    final currentGroup = _appStateService.selectedGroup;
    if (currentGroup != null) {
      _currentGroupId = currentGroup.id;
      print('✅ AddTransactionScreen에서 모임 ID 설정: ${currentGroup.id}');

      // 모임의 카테고리 데이터 로드
      await _loadCategories();
    }
  }

  /// 모임의 카테고리 데이터 로드
  Future<void> _loadCategories() async {
    if (_currentGroupId == null) return;

    try {
      setState(() {
        _isLoadingCategories = true;
      });

      print('🔄 모임 카테고리 로딩 시작: $_currentGroupId');

      // Firebase에서 모임의 카테고리 가져오기
      final categoriesSnapshot = await firestore.FirebaseFirestore.instance
          .collection('categories')
          .where('groupId', isEqualTo: _currentGroupId)
          .get();

      final List<Category> categories = [];
      for (final doc in categoriesSnapshot.docs) {
        final categoryData = doc.data();
        final category = Category.fromFirestore(categoryData, doc.id);
        categories.add(category);
        print('✅ 카테고리 로드: ${category.name}');
      }

      // 기본 카테고리가 없으면 기본값 생성
      if (categories.isEmpty) {
        print('⚠️ 모임에 카테고리가 없음 - 기본 카테고리 생성');
        categories.addAll(_getDefaultCategories());
      }

      setState(() {
        _categories = categories;
        _isLoadingCategories = false;
      });

      print('🎉 카테고리 로딩 완료: ${categories.length}개');
    } catch (e) {
      print('❌ 카테고리 로딩 오류: $e');
      setState(() {
        _isLoadingCategories = false;
        _categories = _getDefaultCategories();
      });
    }
  }

  /// 기본 카테고리 목록 반환 (CategoryService 사용)
  List<Category> _getDefaultCategories() {
    // CategoryService의 기본 카테고리 사용
    final categoryService = CategoryService();
    return categoryService.getDefaultCategories(_currentGroupId ?? 'default');
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignSystem.background,
      appBar: AppBar(
        backgroundColor: DesignSystem.surface,
        elevation: 0,
        title: Text(
          '거래 내역 추가',
          style: DesignSystem.headline3.copyWith(
            color: DesignSystem.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: DesignSystem.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: DesignSystem.getScreenPadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: DesignSystem.spacing24),

              // 거래 타입 선택
              _buildTransactionTypeSelector(),

              const SizedBox(height: DesignSystem.spacing32),

              // 금액 입력
              _buildAmountInput(),

              const SizedBox(height: DesignSystem.spacing32),

              // 카테고리 선택
              _buildCategorySelector(),

              const SizedBox(height: DesignSystem.spacing32),

              // 날짜 선택
              _buildDateSelector(),

              const SizedBox(height: DesignSystem.spacing32),

              // 메모 입력
              _buildDescriptionInput(),

              const SizedBox(height: DesignSystem.spacing48),

              // 저장 버튼
              _buildSaveButton(),

              const SizedBox(height: DesignSystem.spacing24),
            ],
          ),
        ),
      ),
    );
  }

  /// 거래 타입 선택 (지출/수입)
  Widget _buildTransactionTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '거래 타입',
          style: DesignSystem.headline3.copyWith(
            color: DesignSystem.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: DesignSystem.spacing16),
        Row(
          children: [
            Expanded(
              child: _buildTypeOption(
                'expense',
                '지출',
                Icons.remove_circle_outline,
                DesignSystem.expense,
              ),
            ),
            const SizedBox(width: DesignSystem.spacing16),
            Expanded(
              child: _buildTypeOption(
                'income',
                '수입',
                Icons.add_circle_outline,
                DesignSystem.income,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 거래 타입 옵션
  Widget _buildTypeOption(
    String type,
    String label,
    IconData icon,
    Color color,
  ) {
    final isSelected = _transactionType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          _transactionType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(DesignSystem.spacing20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
          border: Border.all(
            color: isSelected ? color : DesignSystem.divider,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected ? color.withOpacity(0.1) : DesignSystem.surface,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : DesignSystem.textSecondary,
              size: 32,
            ),
            const SizedBox(height: DesignSystem.spacing12),
            Text(
              label,
              style: DesignSystem.body1.copyWith(
                color: isSelected ? color : DesignSystem.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 금액 입력
  Widget _buildAmountInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '금액',
          style: DesignSystem.headline3.copyWith(
            color: DesignSystem.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: DesignSystem.spacing16),
        TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          style: DesignSystem.displayLarge.copyWith(
            color: _transactionType == 'expense'
                ? DesignSystem.expense
                : DesignSystem.income,
            fontWeight: FontWeight.w800,
          ),
          decoration: InputDecoration(
            hintText: '0',
            hintStyle: DesignSystem.displayLarge.copyWith(
              color: DesignSystem.textSecondary.withOpacity(0.3),
              fontWeight: FontWeight.w800,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
              borderSide: BorderSide(color: DesignSystem.divider, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
              borderSide: BorderSide(color: DesignSystem.divider, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
              borderSide: BorderSide(
                color: _transactionType == 'expense'
                    ? DesignSystem.expense
                    : DesignSystem.income,
                width: 3,
              ),
            ),
            suffixText: '원',
            suffixStyle: DesignSystem.headline3.copyWith(
              color: _transactionType == 'expense'
                  ? DesignSystem.expense
                  : DesignSystem.income,
              fontWeight: FontWeight.w600,
            ),
            filled: true,
            fillColor: DesignSystem.surface,
          ),
        ),
      ],
    );
  }

  /// 카테고리 선택
  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '카테고리',
          style: DesignSystem.headline3.copyWith(
            color: DesignSystem.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: DesignSystem.spacing16),

        // 카테고리 로딩 상태 표시
        if (_isLoadingCategories)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(DesignSystem.spacing32),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_categories.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(DesignSystem.spacing32),
              child: Text(
                '카테고리가 없습니다',
                style: DesignSystem.body1.copyWith(
                  color: DesignSystem.textSecondary,
                ),
              ),
            ),
          )
        else
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
              final isSelected = _selectedCategoryId == category.id;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategoryId = category.id;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      DesignSystem.radiusLarge,
                    ),
                    border: Border.all(
                      color: isSelected ? category.color : DesignSystem.divider,
                      width: isSelected ? 2 : 1,
                    ),
                    color: isSelected
                        ? category.color.withOpacity(0.1)
                        : DesignSystem.surface,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(category.icon, style: const TextStyle(fontSize: 32)),
                      const SizedBox(height: DesignSystem.spacing8),
                      Text(
                        category.name,
                        style: DesignSystem.body2.copyWith(
                          color: isSelected
                              ? category.color
                              : DesignSystem.textSecondary,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  /// 날짜 선택
  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '날짜',
          style: DesignSystem.headline3.copyWith(
            color: DesignSystem.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: DesignSystem.spacing16),
        GestureDetector(
          onTap: () => _selectDate(context),
          child: Container(
            padding: const EdgeInsets.all(DesignSystem.spacing20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
              border: Border.all(color: DesignSystem.divider, width: 2),
              color: DesignSystem.surface,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: DesignSystem.primary,
                  size: 24,
                ),
                const SizedBox(width: DesignSystem.spacing16),
                Text(
                  '${_selectedDate.year}년 ${_selectedDate.month}월 ${_selectedDate.day}일',
                  style: DesignSystem.body1.copyWith(
                    color: DesignSystem.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_drop_down,
                  color: DesignSystem.textSecondary,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 메모 입력
  Widget _buildDescriptionInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '메모 (선택사항)',
          style: DesignSystem.headline3.copyWith(
            color: DesignSystem.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: DesignSystem.spacing16),
        TextField(
          controller: _descriptionController,
          maxLines: 3,
          style: DesignSystem.body1.copyWith(color: DesignSystem.textPrimary),
          decoration: InputDecoration(
            hintText: '거래에 대한 메모를 입력하세요',
            hintStyle: DesignSystem.body1.copyWith(
              color: DesignSystem.textSecondary.withOpacity(0.5),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
              borderSide: BorderSide(color: DesignSystem.divider, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
              borderSide: BorderSide(color: DesignSystem.divider, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
              borderSide: BorderSide(color: DesignSystem.primary, width: 3),
            ),
            filled: true,
            fillColor: DesignSystem.surface,
          ),
        ),
      ],
    );
  }

  /// 저장 버튼
  Widget _buildSaveButton() {
    final isValid =
        _amountController.text.isNotEmpty && _selectedCategoryId != null;

    return AppButton(
      text: '저장하기',
      onPressed: isValid ? _saveTransaction : null,
      isFullWidth: true,
      type: AppButtonType.primary,
    );
  }

  /// 날짜 선택 다이얼로그
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: DesignSystem.primary,
              onPrimary: Colors.white,
              surface: DesignSystem.surface,
              onSurface: DesignSystem.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  /// 거래 내역 저장
  Future<void> _saveTransaction() async {
    // 사용자 ID와 모임 ID 확인
    if (_currentUserId == null) {
      _showErrorSnackBar('사용자 정보를 찾을 수 없습니다. 다시 로그인해주세요.');
      return;
    }

    if (_currentGroupId == null) {
      _showErrorSnackBar('모임 정보를 찾을 수 없습니다. 모임을 선택해주세요.');
      return;
    }

    final amount = int.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      _showErrorSnackBar('올바른 금액을 입력해주세요.');
      return;
    }

    if (_selectedCategoryId == null) {
      _showErrorSnackBar('카테고리를 선택해주세요.');
      return;
    }

    // 실제 금액 (지출은 음수, 수입은 양수)
    final actualAmount = _transactionType == 'expense' ? -amount : amount;

    // Firebase에 거래 내역 저장
    final transaction = Transaction(
      id: '', // Firestore에서 자동 생성
      groupId: _currentGroupId!, // 현재 그룹 ID
      userId: _currentUserId!, // 현재 사용자 ID
      type: _transactionType,
      amount: actualAmount,
      categoryId: _selectedCategoryId!,
      description: _descriptionController.text.trim(),
      date: _selectedDate,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      final transactionId = await _transactionService.addTransaction(
        transaction,
      );

      if (transactionId != null) {
        // 성공 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${_transactionType == 'expense' ? '지출' : '수입'}이 추가되었습니다.',
            ),
            backgroundColor: DesignSystem.success,
          ),
        );

        // AppStateService에 새 거래 내역 추가
        final updatedTransaction = transaction.copyWith(id: transactionId);
        _appStateService.addTransaction(updatedTransaction);

        // 이전 화면으로 돌아가기
        Navigator.pop(context);
      } else {
        _showErrorSnackBar('저장에 실패했습니다. 다시 시도해주세요.');
      }
    } catch (e) {
      _showErrorSnackBar('오류가 발생했습니다: $e');
    }
  }

  /// 에러 메시지 표시
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: DesignSystem.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
