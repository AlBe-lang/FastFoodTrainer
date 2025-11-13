# 🍔 킹스 그릴 트레이닝 (Fast Food Trainer)

> **첫 알바, 걱정되시나요?**  
> 패스트푸드 매장 업무를 미리 체험하고 연습할 수 있는 교육용 시뮬레이션 게임입니다.

## English Summary

**Fast Food Trainer** is a practical training app for first-time part-time workers at fast-food restaurants. It helps users gain confidence by practicing their duties through gameplay before their first shift.

---

## 📱 프로젝트 소개

킹스 그릴 트레이닝은 **패스트푸드 매장에서 처음 일하는 알바생**을 위한 실전 연습 앱입니다.  
실제 근무 전에 게임을 통해 업무를 미리 경험하고, 자신감을 갖고 첫 출근할 수 있도록 도와줍니다.

### 🎯 해결하는 문제
- 첫 알바의 불안감과 긴장감 완화
- 주문 받기, 조리, 클레임 처리 등 핵심 업무 사전 학습
- 실수해도 괜찮은 안전한 연습 환경 제공
- 현직자의 실전 노하우 전달

### 🎮 대상 사용자
- 패스트푸드 매장 신규 알바생
- 서비스업 경험이 없는 구직자
- 알바 면접을 앞둔 학생
- 복직을 준비하는 경력단절자

---

## ✨ 주요 기능

### 1. 📚 Day별 학습 시스템
- **Day 1~7**: 단계별 난이도 상승
- 각 Day마다 명확한 학습 목표 제시
- 이전 Day 완료 시 다음 Day 언락

### 2. 🎯 실전 시뮬레이션
- **카운터 모드**: 주문 받기, 메뉴 선택, 결제 처리
- **주방 모드**: 버거 조립, 튀김 타이밍 관리
- **클레임 처리**: 다양한 상황별 대응 연습

### 3. 📊 상세한 피드백
- 4가지 지표 분석: 정확도, 속도, 만족도, 절차 준수
- 실수 로그 및 개선 포인트 안내
- 등급 시스템 (S/A/B/C/D)

### 4. 💡 현직자 꿀팁
- 실제 알바생의 경험담
- 상황별 맞춤 팁 제공
- Day 완료 시 언락

---

## 🛠 기술 스택

| 분류 | 기술 |
|-----|------|
| **플랫폼** | iOS 17+ (iPhone) |
| **언어** | Swift 5.9+ |
| **UI** | SwiftUI |
| **아키텍처** | MVVM + Clean Architecture |
| **데이터** | JSON (로컬 번들), UserDefaults |
| **테스트** | XCTest |

---

## 📦 프로젝트 구조

```
FastFoodTrainer/
├── FastFoodTrainer/
│   ├── FastFoodTrainerApp.swift
│   ├── Core/                      # 핵심 인프라
│   │   ├── Models/               # 데이터 모델
│   │   ├── Services/             # 비즈니스 로직
│   │   └── Common/               # 공통 유틸리티
│   ├── Features/                 # 기능별 모듈
│   │   ├── Onboarding/
│   │   ├── MainHub/
│   │   ├── Gameplay/
│   │   └── ResultSummary/
│   └── Resources/                # 리소스
│       └── Scenarios/           # JSON 시나리오
├── FastFoodTrainerTests/         # 테스트
├── README.md
└── .gitignore
```

---

## 🚀 빌드 방법

### 요구사항
- **Xcode**: 15.0 이상
- **iOS 타겟**: 17.0 이상
- **macOS**: 13.0 (Ventura) 이상

### 빌드 단계

1. **저장소 클론**
```bash
git clone https://github.com/your-username/FastFoodTrainer.git
cd FastFoodTrainer
```

2. **Xcode 프로젝트 생성**

이 저장소는 소스 코드만 포함하고 있습니다. Xcode 프로젝트를 생성하려면:

- Xcode 실행
- File > New > Project
- iOS > App 선택
- Product Name: FastFoodTrainer
- Interface: SwiftUI
- Language: Swift
- 이 저장소의 파일들을 프로젝트에 추가

3. **빌드 및 실행** (⌘ + R)

---

## 🧪 테스트 방법

### 유닛 테스트 실행
```bash
# Xcode에서
⌘ + U
```

---

## 🎓 실제 교육 활용 방안

### 1. 개인 학습용
- 출근 전날 집에서 연습
- 불안감 해소 및 자신감 향상

### 2. 매장 내 교육
- 신입 교육 과정에 포함
- 태블릿에 설치하여 교육 도구로 활용

### 3. 채용 프로세스
- 면접 전 사전 학습 자료 제공
- 기본 소양 확인용

---

## 📈 교육 효과 측정 지표

- **정확도**: 주문 오류율 감소
- **속도**: 평균 처리 시간 단축
- **재도전 횟수**: 학습 패턴 분석
- **완료율**: Day별 완주율

---

## 🔮 향후 개선 아이디어

### 단기 (v1.1~1.3)
- [ ] 다국어 지원 (영어, 중국어, 일본어)
- [ ] 더 많은 Day 시나리오 (Day 8~14)
- [ ] 음성 인식 주문 받기 모드
- [ ] 친구와 점수 비교 (Game Center 연동)

### 중기 (v2.0)
- [ ] 점장/관리자 모드 (직원 관리, 매출 분석)
- [ ] 커스텀 시나리오 에디터
- [ ] 실제 매장 메뉴 임포트 기능
- [ ] 클라우드 진행 상황 동기화

### 장기 (v3.0+)
- [ ] AR 모드 (실제 매장에서 증강현실 가이드)
- [ ] AI 고객 (GPT 기반 자연어 대화)
- [ ] 다른 업종 확장 (카페, 편의점 등)

---

## 🤝 기여하기

프로젝트에 기여하고 싶으시다면:

1. Fork this repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

**기여 가이드라인**
- 모든 코드 주석은 한국어로 작성
- 커밋 메시지는 한글/영문 모두 가능
- 테스트 코드 포함 필수

---

## 📄 라이선스

이 프로젝트는 **MIT 라이선스** 하에 배포됩니다.  
자유롭게 사용, 수정, 배포할 수 있습니다.

---

## 📧 문의

- **GitHub Issues**: [이슈 트래커](https://github.com/your-username/FastFoodTrainer/issues)

---

## 🙏 감사의 말

이 프로젝트는 실제 패스트푸드 매장에서 일하는 알바생들의 이야기를 바탕으로 만들어졌습니다.  
소중한 인사이트를 제공해주신 모든 분들께 감사드립니다.

---

**Made with ❤️ for part-time workers everywhere**
