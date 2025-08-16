# 💰 머니투게더 (Money Together)

> **함께하는 투명한 금융 관리**

## 📱 프로젝트 소개

머니투게더는 특정 사람들로 구성된 모임 멤버들이 서로간의 지출, 예산, 수입 등 경제활동과 관련된 것을 서로 확인하고 조회하는 모바일 앱입니다.

### 🎯 핵심 가치
- **투명성**: 모든 구성원이 지출 현황을 실시간으로 확인
- **협력**: 함께하는 예산 관리와 지출 계획
- **편의성**: SMS 자동 데이터 추출로 간편한 입력

### 👥 주요 사용자
- 가족 구성원
- 모임/동호회 멤버
- 공동체 구성원
- 친구 그룹

## 🚀 주요 기능

### 1순위 (MVP)
- ✅ 수입/지출 CRUD
- ✅ 모임별 카테고리 관리
- ✅ 기본 사용자 인증

### 2순위
- 🔄 모임 초대/수락 시스템
- 🔄 캘린더 뷰
- 🔄 기본 통계

### 3순위
- 📱 SMS 자동 데이터 추출
- 📊 고급 통계 및 차트
- 🔔 푸시 알림

## 🛠️ 기술 스택

- **프론트엔드**: Flutter (Dart)
- **백엔드**: Firebase
  - Authentication: 사용자 인증
  - Firestore: 실시간 데이터베이스
  - Storage: 이미지 저장
- **상태 관리**: Provider
- **플랫폼**: Android (우선), iOS (향후)

## 📁 프로젝트 구조

```
lib/
├── constants/          # 앱 상수 및 설정
├── models/            # 데이터 모델
├── screens/           # 화면 컴포넌트
├── services/          # 비즈니스 로직 서비스
├── utils/             # 유틸리티 함수
├── widgets/           # 재사용 가능한 위젯
└── main.dart          # 앱 진입점
```

## 🚀 시작하기

### 필수 요구사항
- Flutter SDK (3.9.0 이상)
- Dart SDK
- Android Studio / VS Code
- Firebase 프로젝트

### 설치 및 실행

1. **저장소 클론**
```bash
git clone [repository-url]
cd moim_money_flutter
```

2. **의존성 설치**
```bash
flutter pub get
```

3. **Firebase 설정**
   - Firebase 콘솔에서 새 프로젝트 생성
   - Android 앱 등록
   - `google-services.json` 파일을 `android/app/` 폴더에 추가

4. **앱 실행**
```bash
flutter run
```

## 🔧 개발 환경 설정

### 1. Flutter 설치
```bash
# Flutter SDK 다운로드 및 설치
flutter doctor
```

### 2. Firebase 설정
```bash
# Firebase CLI 설치
npm install -g firebase-tools

# Firebase 로그인
firebase login

# 프로젝트 초기화
firebase init
```

### 3. Android 설정
- Android SDK 설치
- 에뮬레이터 또는 실제 기기 연결
- `flutter doctor`로 환경 점검

## 📱 앱 구조

### 주요 화면
1. **스플래시 화면**: 앱 로딩 및 브랜딩
2. **로그인/회원가입**: 사용자 인증
3. **메인 대시보드**: 요약 정보 및 빠른 액션
4. **거래내역**: 수입/지출 목록 및 상세
5. **캘린더**: 날짜별 거래 현황
6. **모임 관리**: 그룹 생성 및 멤버 관리
7. **설정**: 사용자 프로필 및 앱 설정

### 네비게이션
- 하단 탭바: 홈, 거래내역, 캘린더, 모임, 설정
- 플로팅 액션: 거래 추가 (핵심 기능)

## 🎨 디자인 가이드라인

### 색상 시스템
- **메인**: 파란색 계열 (#2196F3)
- **수입**: 초록색 계열 (#4CAF50)
- **지출**: 빨간색 계열 (#F44336)
- **배경**: 밝은 회색 (#FAFAFA)

### UI 원칙
- 모바일 터치 친화적 인터페이스
- 직관적이고 일관된 디자인
- 접근성을 고려한 색상 및 크기
- 부드러운 애니메이션과 전환

## 🧪 테스트

### 테스트 실행
```bash
# 단위 테스트
flutter test

# 위젯 테스트
flutter test test/widget_test.dart

# 통합 테스트
flutter drive --target=test_driver/app.dart
```

### 테스트 커버리지
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## 📊 데이터베이스 구조

### Firestore 컬렉션
- `users`: 사용자 정보
- `groups`: 모임/그룹 정보
- `categories`: 카테고리 정보
- `transactions`: 거래내역

### 보안 규칙
- 사용자는 자신의 데이터만 접근 가능
- 모임 멤버는 해당 모임의 데이터만 접근 가능
- 관리자는 모임 설정 변경 가능

## 🚀 배포

### Android APK 빌드
```bash
flutter build apk --release
```

### Android App Bundle
```bash
flutter build appbundle --release
```

### iOS (향후)
```bash
flutter build ios --release
```

## 🤝 기여하기

### 개발 가이드라인
- [코딩 표준](RULES/CODING_STANDARDS.md) 준수
- [Git 워크플로우](RULES/GIT_WORKFLOW.md) 따르기
- [테스트 가이드라인](RULES/TESTING_QUALITY.md) 준수

### Pull Request 프로세스
1. 기능 브랜치 생성 (`feature/기능명`)
2. 코드 작성 및 테스트
3. Pull Request 생성
4. 코드 리뷰 진행
5. 승인 후 머지

## 📝 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다.

## 📞 연락처

- **프로젝트 매니저**: [이름]
- **개발팀**: [팀 정보]
- **이메일**: [이메일 주소]

## 🙏 감사의 말

이 프로젝트는 다음과 같은 오픈소스 프로젝트들의 도움을 받았습니다:
- Flutter Framework
- Firebase Platform
- Provider Package
- 기타 의존성 패키지들

---

**버전**: 1.0.0  
**최종 업데이트**: 2024년 1월  
**개발 상태**: 개발 중
