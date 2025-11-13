import XCTest
@testable import FastFoodTrainer

// MARK: - ScoreCalculatorTests
/// ScoreCalculator 유닛 테스트
final class ScoreCalculatorTests: XCTestCase {

    var calculator: ScoreCalculator!

    override func setUp() {
        super.setUp()
        calculator = ScoreCalculator()
    }

    override func tearDown() {
        calculator = nil
        super.tearDown()
    }

    // MARK: - 정확도 테스트

    /// 실수가 없을 때 정확도 만점(40점)을 받는지 테스트
    func testAccuracyWithNoMistakes() {
        // Given
        let totalOrders = 5
        let mistakes: [Mistake] = []

        // When
        let accuracy = calculator.calculateAccuracy(totalOrders: totalOrders, mistakes: mistakes)

        // Then
        XCTAssertEqual(accuracy, 40.0, accuracy: 0.01, "실수가 없으면 정확도 40점이어야 합니다")
    }

    /// 절반 실수 시 정확도가 20점인지 테스트
    func testAccuracyWithHalfMistakes() {
        // Given
        let totalOrders = 4
        let mistakes: [Mistake] = [
            Mistake(orderNumber: 1, description: "실수 1", deductedPoints: 5),
            Mistake(orderNumber: 2, description: "실수 2", deductedPoints: 5)
        ]

        // When
        let accuracy = calculator.calculateAccuracy(totalOrders: totalOrders, mistakes: mistakes)

        // Then
        XCTAssertEqual(accuracy, 20.0, accuracy: 0.01, "절반 실수 시 정확도 20점이어야 합니다")
    }

    /// 주문 수가 0일 때 정확도 0점인지 테스트
    func testAccuracyWithZeroOrders() {
        // Given
        let totalOrders = 0
        let mistakes: [Mistake] = []

        // When
        let accuracy = calculator.calculateAccuracy(totalOrders: totalOrders, mistakes: mistakes)

        // Then
        XCTAssertEqual(accuracy, 0.0, "주문 수가 0이면 정확도도 0이어야 합니다")
    }

    // MARK: - 속도 테스트

    /// 목표 시간(90초) 이내 완료 시 만점(30점) 테스트
    func testSpeedWithinTargetTime() {
        // Given
        let averageTime: TimeInterval = 80.0 // 90초 이내

        // When
        let speed = calculator.calculateSpeed(averageTime: averageTime)

        // Then
        XCTAssertEqual(speed, 30.0, "90초 이내 완료 시 속도 30점이어야 합니다")
    }

    /// 수용 가능 시간(120초) 경계값 테스트
    func testSpeedAtAcceptableTime() {
        // Given
        let averageTime: TimeInterval = 120.0

        // When
        let speed = calculator.calculateSpeed(averageTime: averageTime)

        // Then
        XCTAssertEqual(speed, 15.0, accuracy: 0.01, "120초 완료 시 속도 15점이어야 합니다")
    }

    /// 수용 가능 시간(120초) 초과 시 최소 점수(15점) 테스트
    func testSpeedOverAcceptableTime() {
        // Given
        let averageTime: TimeInterval = 150.0

        // When
        let speed = calculator.calculateSpeed(averageTime: averageTime)

        // Then
        XCTAssertEqual(speed, 15.0, "120초 초과 시 속도 15점이어야 합니다")
    }

    // MARK: - 만족도 테스트

    /// 평균 만족도 100%일 때 만점(20점) 테스트
    func testSatisfactionWithPerfectScores() {
        // Given
        let satisfactionScores = [100.0, 100.0, 100.0]

        // When
        let satisfaction = calculator.calculateSatisfaction(satisfactionScores: satisfactionScores)

        // Then
        XCTAssertEqual(satisfaction, 20.0, "만족도 100%일 때 20점이어야 합니다")
    }

    /// 평균 만족도 50%일 때 10점 테스트
    func testSatisfactionWithAverageScores() {
        // Given
        let satisfactionScores = [50.0, 50.0, 50.0]

        // When
        let satisfaction = calculator.calculateSatisfaction(satisfactionScores: satisfactionScores)

        // Then
        XCTAssertEqual(satisfaction, 10.0, "만족도 50%일 때 10점이어야 합니다")
    }

    /// 만족도 점수가 비어있을 때 0점 테스트
    func testSatisfactionWithEmptyScores() {
        // Given
        let satisfactionScores: [Double] = []

        // When
        let satisfaction = calculator.calculateSatisfaction(satisfactionScores: satisfactionScores)

        // Then
        XCTAssertEqual(satisfaction, 0.0, "만족도 점수가 없으면 0점이어야 합니다")
    }

    // MARK: - 절차 준수 테스트

    /// 위반이 없을 때 만점(10점) 테스트
    func testComplianceWithNoViolations() {
        // Given
        let violations = 0

        // When
        let compliance = calculator.calculateCompliance(violations: violations)

        // Then
        XCTAssertEqual(compliance, 10.0, "위반이 없으면 절차 준수 10점이어야 합니다")
    }

    /// 위반 1회 시 8점 테스트
    func testComplianceWithOneViolation() {
        // Given
        let violations = 1

        // When
        let compliance = calculator.calculateCompliance(violations: violations)

        // Then
        XCTAssertEqual(compliance, 8.0, "위반 1회 시 절차 준수 8점이어야 합니다")
    }

    /// 위반 5회 이상 시 최소 점수(0점) 테스트
    func testComplianceWithManyViolations() {
        // Given
        let violations = 10

        // When
        let compliance = calculator.calculateCompliance(violations: violations)

        // Then
        XCTAssertEqual(compliance, 0.0, "위반이 많으면 절차 준수 0점이어야 합니다")
    }

    // MARK: - 종합 점수 테스트

    /// 완벽한 플레이 시 100점 테스트
    func testPerfectGameScore() {
        // Given
        let totalOrders = 3
        let mistakes: [Mistake] = []
        let averageTime: TimeInterval = 80.0
        let satisfactionScores = [100.0, 100.0, 100.0]
        let violations = 0

        // When
        let scoreComponents = calculator.calculateFinalScore(
            totalOrders: totalOrders,
            mistakes: mistakes,
            averageTime: averageTime,
            satisfactionScores: satisfactionScores,
            complianceViolations: violations
        )

        // Then
        XCTAssertEqual(scoreComponents.totalScore, 100, "완벽한 플레이 시 100점이어야 합니다")
        XCTAssertEqual(scoreComponents.grade, .s, "100점이면 S등급이어야 합니다")
    }

    /// 평균 플레이 시 대략 70점대 테스트
    func testAverageGameScore() {
        // Given
        let totalOrders = 5
        let mistakes: [Mistake] = [
            Mistake(orderNumber: 1, description: "실수", deductedPoints: 5)
        ]
        let averageTime: TimeInterval = 100.0
        let satisfactionScores = [80.0, 75.0, 85.0, 80.0, 70.0]
        let violations = 1

        // When
        let scoreComponents = calculator.calculateFinalScore(
            totalOrders: totalOrders,
            mistakes: mistakes,
            averageTime: averageTime,
            satisfactionScores: satisfactionScores,
            complianceViolations: violations
        )

        // Then
        XCTAssertGreaterThanOrEqual(scoreComponents.totalScore, 60, "평균 플레이는 60점 이상이어야 합니다")
        XCTAssertLessThanOrEqual(scoreComponents.totalScore, 85, "평균 플레이는 85점 이하여야 합니다")
    }

    // MARK: - 등급 테스트

    /// 점수 95점 이상 시 S등급 테스트
    func testGradeS() {
        let grade = Grade.from(score: 96)
        XCTAssertEqual(grade, .s, "95점 이상은 S등급이어야 합니다")
    }

    /// 점수 85~94점 시 A등급 테스트
    func testGradeA() {
        let grade = Grade.from(score: 87)
        XCTAssertEqual(grade, .a, "85~94점은 A등급이어야 합니다")
    }

    /// 점수 70~84점 시 B등급 테스트
    func testGradeB() {
        let grade = Grade.from(score: 75)
        XCTAssertEqual(grade, .b, "70~84점은 B등급이어야 합니다")
    }

    /// 점수 60~69점 시 C등급 테스트
    func testGradeC() {
        let grade = Grade.from(score: 65)
        XCTAssertEqual(grade, .c, "60~69점은 C등급이어야 합니다")
    }

    /// 점수 60점 미만 시 D등급 테스트
    func testGradeD() {
        let grade = Grade.from(score: 50)
        XCTAssertEqual(grade, .d, "60점 미만은 D등급이어야 합니다")
    }
}
