import Foundation

// MARK: - DayScenario (일일 시나리오)
/// 하루치 학습 시나리오 전체를 정의하는 모델
/// JSON 파일에서 로드되어 게임 진행의 기본 단위가 됨
struct DayScenario: Codable, Identifiable {
    let id: String
    let dayNumber: Int
    let title: String
    let description: String
    let learningGoals: [String]
    let requiredScore: Int // 합격 기준 점수
    let stages: [Stage]
    let unlockTips: [String] // 완료 시 언락되는 팁 ID 목록
}

// MARK: - Stage (스테이지)
/// 하나의 게임 세션을 정의
/// 카운터, 주방, 청소, 클레임 등 다양한 타입 지원
struct Stage: Codable, Identifiable {
    let id: String
    let type: StageType
    let title: String
    let timeLimitSeconds: Int
    let maxSimultaneousOrders: Int // 동시 처리 가능한 주문 수
    let orders: [Order]
}

// MARK: - StageType (스테이지 타입)
/// 게임플레이 타입을 구분하는 열거형
enum StageType: String, Codable {
    case counter = "counter"           // 카운터 주문 받기
    case kitchen = "kitchen"           // 주방 조리
    case cleaning = "cleaning"         // 청소/정리
    case complaint = "complaint"       // 클레임 처리
    case mixed = "mixed"               // 복합 (카운터+주방)
}

// MARK: - Order (주문)
/// 한 명의 고객이 요청한 전체 주문
struct Order: Codable, Identifiable {
    let id: String
    let customerName: String
    let customerMood: CustomerMood
    let requestText: String // 고객 말풍선에 표시될 텍스트
    let items: [OrderItem]
    let correctResponse: String // 모범 응답 예시
    let paymentAmount: Int
}

// MARK: - CustomerMood (고객 감정 상태)
/// 고객의 기분 상태 (UI 표현 및 난이도에 영향)
enum CustomerMood: String, Codable {
    case friendly = "friendly"     // 친절함 (여유 시간 +10초)
    case neutral = "neutral"       // 보통
    case hurried = "hurried"       // 급함 (여유 시간 -10초)
    case careful = "careful"       // 꼼꼼함 (옵션 확인 필수)
    case angry = "angry"           // 화남 (클레임 상황)
}

// MARK: - OrderItem (주문 항목)
/// 주문 내 개별 메뉴 아이템
struct OrderItem: Codable, Identifiable {
    let id = UUID()
    let menuId: String
    let menuName: String
    let isSetMenu: Bool
    let options: [OrderOption]
    let expectedSteps: [String] // 정답 처리를 위한 단계 목록
    
    enum CodingKeys: String, CodingKey {
        case menuId, menuName, isSetMenu, options, expectedSteps
    }
}

// MARK: - OrderOption (주문 옵션)
/// 메뉴 커스터마이징 옵션 (예: 양상추 빼기, 소스 추가)
struct OrderOption: Codable {
    let key: String
    let label: String
    let isRequired: Bool // 반드시 적용해야 하는 옵션인지 여부
}

// MARK: - Tip (꿀팁)
/// 현직자의 실전 팁 카드
struct Tip: Codable, Identifiable {
    let id: String
    let title: String
    let body: String
    let category: String
    let unlockCondition: String
    let author: String // 예: "3년차 알바 김OO"
}

// MARK: - MenuItem (메뉴 아이템 마스터 데이터)
/// 전체 메뉴 목록 (별도 JSON에서 관리)
struct MenuItem: Codable, Identifiable {
    let id: String
    let name: String
    let category: MenuCategory
    let price: Int
    let imageAssetName: String
    let description: String
}

// MARK: - MenuCategory (메뉴 카테고리)
enum MenuCategory: String, Codable {
    case burger = "burger"
    case side = "side"
    case drink = "drink"
    case dessert = "dessert"
}

// MARK: - DayProgress (사용자 진행 상황)
/// 각 Day별 사용자 진행 데이터 (UserDefaults 저장)
struct DayProgress: Codable {
    let dayId: String
    var isCompleted: Bool
    var bestScore: Int
    var bestGrade: Grade
    var attemptCount: Int
    var lastPlayedDate: Date?
}

// MARK: - Grade (등급)
enum Grade: String, Codable {
    case s = "S"
    case a = "A"
    case b = "B"
    case c = "C"
    case d = "D"
    case incomplete = "미완료"
    
    /// 점수를 등급으로 변환
    static func from(score: Int) -> Grade {
        switch score {
        case 95...100: return .s
        case 85..<95: return .a
        case 70..<85: return .b
        case 60..<70: return .c
        default: return .d
        }
    }
}

// MARK: - ScoreComponents (점수 구성 요소)
/// 게임 결과 점수를 4개 지표로 분해한 구조체
struct ScoreComponents {
    let accuracy: Double      // 정확도 (0~40점)
    let speed: Double         // 속도 (0~30점)
    let satisfaction: Double  // 만족도 (0~20점)
    let compliance: Double    // 절차 준수 (0~10점)
    
    /// 총점 계산
    var totalScore: Int {
        return Int((accuracy + speed + satisfaction + compliance).rounded())
    }
    
    /// 등급 산출
    var grade: Grade {
        return Grade.from(score: totalScore)
    }
}

// MARK: - GameResult (게임 결과 데이터)
/// 한 판의 게임 결과를 담는 구조체
struct GameResult {
    let dayId: String
    let scoreComponents: ScoreComponents
    let mistakes: [Mistake]
    let totalOrders: Int
    let completedOrders: Int
    let averageTimePerOrder: TimeInterval
    let customerSatisfactionScores: [Double]
}

// MARK: - Mistake (실수 기록)
/// 플레이어가 범한 실수 하나를 기록
struct Mistake: Identifiable {
    let id = UUID()
    let orderNumber: Int
    let description: String  // 한국어 설명 (예: "3번 손님: 콜라를 사이다로 잘못 선택")
    let deductedPoints: Int
}
