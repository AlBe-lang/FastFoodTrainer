import XCTest
@testable import FastFoodTrainer

// MARK: - ProgressManagerTests
/// ProgressManager 유닛 테스트
final class ProgressManagerTests: XCTestCase {

    var progressManager: ProgressManager!

    override func setUp() {
        super.setUp()
        progressManager = ProgressManager.shared
        // 테스트 전 데이터 초기화
        progressManager.resetAllProgress()
    }

    override func tearDown() {
        progressManager.resetAllProgress()
        progressManager = nil
        super.tearDown()
    }

    // MARK: - Day 잠금 해제 테스트

    /// Day 1은 항상 잠금 해제되어 있어야 함
    func testDay1AlwaysUnlocked() {
        // When
        let isUnlocked = progressManager.isDayUnlocked(1)

        // Then
        XCTAssertTrue(isUnlocked, "Day 1은 항상 잠금 해제되어 있어야 합니다")
    }

    /// Day 1 완료 전에는 Day 2가 잠겨있어야 함
    func testDay2LockedBeforeDay1Completion() {
        // When
        let isUnlocked = progressManager.isDayUnlocked(2)

        // Then
        XCTAssertFalse(isUnlocked, "Day 1 완료 전에는 Day 2가 잠겨있어야 합니다")
    }

    /// Day 1 완료 후에는 Day 2가 잠금 해제되어야 함
    func testDay2UnlockedAfterDay1Completion() {
        // Given
        progressManager.updateDayResult(dayId: "day1", score: 80, grade: .a)

        // When
        let isUnlocked = progressManager.isDayUnlocked(2)

        // Then
        XCTAssertTrue(isUnlocked, "Day 1 완료 후에는 Day 2가 잠금 해제되어야 합니다")
    }

    // MARK: - Day 진행 상황 업데이트 테스트

    /// 처음 플레이한 Day의 진행 상황이 올바르게 저장되는지 테스트
    func testUpdateDayResultFirstPlay() {
        // Given
        let dayId = "day1"
        let score = 75
        let grade = Grade.b

        // When
        progressManager.updateDayResult(dayId: dayId, score: score, grade: grade)

        // Then
        let progress = progressManager.getProgress(for: dayId)
        XCTAssertNotNil(progress, "진행 상황이 저장되어야 합니다")
        XCTAssertEqual(progress?.bestScore, score, "최고 점수가 올바르게 저장되어야 합니다")
        XCTAssertEqual(progress?.bestGrade, grade, "최고 등급이 올바르게 저장되어야 합니다")
        XCTAssertEqual(progress?.attemptCount, 1, "시도 횟수가 1이어야 합니다")
        XCTAssertTrue(progress?.isCompleted ?? false, "60점 이상이므로 완료되어야 합니다")
    }

    /// 더 높은 점수로 재도전 시 최고 점수가 업데이트되는지 테스트
    func testUpdateDayResultWithHigherScore() {
        // Given
        let dayId = "day1"
        progressManager.updateDayResult(dayId: dayId, score: 70, grade: .b)

        // When
        progressManager.updateDayResult(dayId: dayId, score: 85, grade: .a)

        // Then
        let progress = progressManager.getProgress(for: dayId)
        XCTAssertEqual(progress?.bestScore, 85, "더 높은 점수로 최고 점수가 업데이트되어야 합니다")
        XCTAssertEqual(progress?.bestGrade, .a, "등급도 업데이트되어야 합니다")
        XCTAssertEqual(progress?.attemptCount, 2, "시도 횟수가 2로 증가해야 합니다")
    }

    /// 더 낮은 점수로 재도전 시 최고 점수가 유지되는지 테스트
    func testUpdateDayResultWithLowerScore() {
        // Given
        let dayId = "day1"
        progressManager.updateDayResult(dayId: dayId, score: 85, grade: .a)

        // When
        progressManager.updateDayResult(dayId: dayId, score: 70, grade: .b)

        // Then
        let progress = progressManager.getProgress(for: dayId)
        XCTAssertEqual(progress?.bestScore, 85, "최고 점수는 유지되어야 합니다")
        XCTAssertEqual(progress?.bestGrade, .a, "최고 등급은 유지되어야 합니다")
        XCTAssertEqual(progress?.attemptCount, 2, "시도 횟수는 증가해야 합니다")
    }

    /// 60점 미만 시 완료되지 않음 테스트
    func testDayNotCompletedWithLowScore() {
        // Given
        let dayId = "day1"

        // When
        progressManager.updateDayResult(dayId: dayId, score: 55, grade: .d)

        // Then
        let progress = progressManager.getProgress(for: dayId)
        XCTAssertFalse(progress?.isCompleted ?? true, "60점 미만은 완료되지 않아야 합니다")
    }

    // MARK: - 전체 진행률 테스트

    /// 아무것도 완료하지 않았을 때 진행률 0% 테스트
    func testOverallProgressWithNoCompletion() {
        // When
        let progress = progressManager.calculateOverallProgress()

        // Then
        XCTAssertEqual(progress, 0.0, "아무것도 완료하지 않았으면 진행률 0%여야 합니다")
    }

    /// Day 1 완료 시 진행률 약 14% (1/7) 테스트
    func testOverallProgressWithOneCompletion() {
        // Given
        progressManager.updateDayResult(dayId: "day1", score: 80, grade: .a)

        // When
        let progress = progressManager.calculateOverallProgress()

        // Then
        let expected = 1.0 / 7.0
        XCTAssertEqual(progress, expected, accuracy: 0.01, "Day 1 완료 시 진행률 약 14%여야 합니다")
    }

    /// 모든 Day 완료 시 진행률 100% 테스트
    func testOverallProgressWithAllCompletion() {
        // Given
        for dayNum in 1...7 {
            progressManager.updateDayResult(dayId: "day\(dayNum)", score: 80, grade: .a)
        }

        // When
        let progress = progressManager.calculateOverallProgress()

        // Then
        XCTAssertEqual(progress, 1.0, "모든 Day 완료 시 진행률 100%여야 합니다")
    }

    // MARK: - 팁 언락 테스트

    /// 팁 언락이 올바르게 동작하는지 테스트
    func testUnlockTip() {
        // Given
        let tipId = "tip_greeting"

        // When
        progressManager.unlockTip(tipId)

        // Then
        XCTAssertTrue(progressManager.unlockedTips.contains(tipId), "팁이 언락되어야 합니다")
    }

    /// 중복 팁 언락 시 카운트가 증가하지 않는지 테스트
    func testUnlockTipDuplicateDoesNotIncrease() {
        // Given
        let tipId = "tip_greeting"
        progressManager.unlockTip(tipId)

        // When
        progressManager.unlockTip(tipId)

        // Then
        XCTAssertEqual(progressManager.unlockedTips.count, 1, "중복 언락 시 카운트가 증가하지 않아야 합니다")
    }

    // MARK: - 데이터 초기화 테스트

    /// 모든 데이터가 올바르게 초기화되는지 테스트
    func testResetAllProgress() {
        // Given
        progressManager.userNickname = "테스터"
        progressManager.updateDayResult(dayId: "day1", score: 80, grade: .a)
        progressManager.unlockTip("tip_greeting")

        // When
        progressManager.resetAllProgress()

        // Then
        XCTAssertEqual(progressManager.userNickname, "", "닉네임이 초기화되어야 합니다")
        XCTAssertEqual(progressManager.dayProgressMap.count, 0, "진행 상황이 초기화되어야 합니다")
        XCTAssertEqual(progressManager.unlockedTips.count, 0, "팁이 초기화되어야 합니다")
    }
}
