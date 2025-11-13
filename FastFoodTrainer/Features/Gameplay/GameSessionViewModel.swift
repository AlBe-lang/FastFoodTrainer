import Foundation
import SwiftUI
import Combine

// MARK: - GameSessionViewModel
/// 게임 세션 전체를 관리하는 ViewModel
/// - 스테이지 진행 관리
/// - 타이머 관리
/// - 점수 계산 및 실수 기록
/// - 게임 종료 처리
class GameSessionViewModel: ObservableObject {

    // MARK: - Published Properties

    /// 현재 스테이지
    @Published var currentStage: Stage?

    /// 현재 스테이지 인덱스
    @Published var currentStageIndex: Int = 0

    /// 현재 주문 인덱스
    @Published var currentOrderIndex: Int = 0

    /// 현재 주문
    @Published var currentOrder: Order?

    /// 남은 시간 (초)
    @Published var remainingTime: Int = 0

    /// 게임이 종료되었는지 여부
    @Published var isGameFinished: Bool = false

    /// 게임 진행 중 여부
    @Published var isGameActive: Bool = false

    /// 현재까지 완료한 주문 수
    @Published var completedOrdersCount: Int = 0

    /// 실수 목록
    @Published var mistakes: [Mistake] = []

    /// 고객 만족도 점수 목록
    @Published var satisfactionScores: [Double] = []

    /// 절차 위반 횟수
    @Published var complianceViolations: Int = 0

    /// 각 주문의 처리 시간 (초)
    @Published var orderCompletionTimes: [TimeInterval] = []

    // MARK: - Private Properties

    private let scenario: DayScenario
    private var timer: Timer?
    private var stageStartTime: Date?
    private var orderStartTime: Date?
    private let scoreCalculator = ScoreCalculator()
    private let progressManager = ProgressManager.shared

    /// 게임 결과 (게임 종료 시 생성)
    var gameResult: GameResult?

    // MARK: - Initialization

    init(scenario: DayScenario) {
        self.scenario = scenario
        setupFirstStage()
    }

    // MARK: - Public Methods

    /// 게임 시작
    func startGame() {
        guard let stage = currentStage else { return }

        isGameActive = true
        remainingTime = stage.timeLimitSeconds
        stageStartTime = Date()
        orderStartTime = Date()

        loadNextOrder()
        startTimer()
    }

    /// 주문 완료 처리
    /// - Parameters:
    ///   - isCorrect: 정답 여부
    ///   - satisfaction: 고객 만족도 (0~100)
    func completeOrder(isCorrect: Bool, satisfaction: Double) {
        guard let order = currentOrder else { return }

        // 처리 시간 기록
        if let startTime = orderStartTime {
            let elapsed = Date().timeIntervalSince(startTime)
            orderCompletionTimes.append(elapsed)
        }

        // 만족도 기록
        satisfactionScores.append(satisfaction)

        // 실수 기록
        if !isCorrect {
            let mistake = Mistake(
                orderNumber: currentOrderIndex + 1,
                description: "\(order.customerName): 주문 처리 오류",
                deductedPoints: 5
            )
            mistakes.append(mistake)
        }

        completedOrdersCount += 1

        // 다음 주문으로
        loadNextOrder()
    }

    /// 실수 기록 추가
    func recordMistake(description: String, points: Int = 5) {
        let mistake = Mistake(
            orderNumber: currentOrderIndex + 1,
            description: description,
            deductedPoints: points
        )
        mistakes.append(mistake)
    }

    /// 절차 위반 기록
    func recordComplianceViolation() {
        complianceViolations += 1
    }

    /// 스테이지 완료 처리
    func completeStage() {
        stopTimer()

        // 다음 스테이지로
        if currentStageIndex < scenario.stages.count - 1 {
            currentStageIndex += 1
            setupCurrentStage()
            startGame()
        } else {
            // 모든 스테이지 완료 → 게임 종료
            finishGame()
        }
    }

    /// 게임 강제 종료
    func quitGame() {
        stopTimer()
        finishGame()
    }

    // MARK: - Private Methods

    /// 첫 번째 스테이지 설정
    private func setupFirstStage() {
        guard !scenario.stages.isEmpty else { return }
        currentStageIndex = 0
        setupCurrentStage()
    }

    /// 현재 스테이지 설정
    private func setupCurrentStage() {
        guard currentStageIndex < scenario.stages.count else { return }

        currentStage = scenario.stages[currentStageIndex]
        currentOrderIndex = 0
        remainingTime = currentStage?.timeLimitSeconds ?? 0
    }

    /// 다음 주문 로드
    private func loadNextOrder() {
        guard let stage = currentStage else { return }

        if currentOrderIndex < stage.orders.count {
            currentOrder = stage.orders[currentOrderIndex]
            orderStartTime = Date()
            currentOrderIndex += 1
        } else {
            // 이 스테이지의 모든 주문 완료
            currentOrder = nil
            completeStage()
        }
    }

    /// 타이머 시작
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            if self.remainingTime > 0 {
                self.remainingTime -= 1
            } else {
                // 시간 초과
                self.handleTimeOut()
            }
        }
    }

    /// 타이머 정지
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    /// 시간 초과 처리
    private func handleTimeOut() {
        stopTimer()

        // 실수 기록: 시간 초과
        let mistake = Mistake(
            orderNumber: currentOrderIndex,
            description: "시간 초과로 주문 처리 실패",
            deductedPoints: 10
        )
        mistakes.append(mistake)

        // 게임 종료
        finishGame()
    }

    /// 게임 종료 및 결과 계산
    private func finishGame() {
        stopTimer()
        isGameActive = false
        isGameFinished = true

        // 평균 처리 시간 계산
        let averageTime: TimeInterval = orderCompletionTimes.isEmpty
            ? 120.0
            : orderCompletionTimes.reduce(0, +) / Double(orderCompletionTimes.count)

        // 점수 계산
        let scoreComponents = scoreCalculator.calculateFinalScore(
            totalOrders: currentStage?.orders.count ?? 0,
            mistakes: mistakes,
            averageTime: averageTime,
            satisfactionScores: satisfactionScores,
            complianceViolations: complianceViolations
        )

        // 게임 결과 생성
        gameResult = GameResult(
            dayId: scenario.id,
            scoreComponents: scoreComponents,
            mistakes: mistakes,
            totalOrders: currentStage?.orders.count ?? 0,
            completedOrders: completedOrdersCount,
            averageTimePerOrder: averageTime,
            customerSatisfactionScores: satisfactionScores
        )

        // 진행 상황 업데이트
        progressManager.updateDayResult(
            dayId: scenario.id,
            score: scoreComponents.totalScore,
            grade: scoreComponents.grade
        )

        // 팁 언락
        if scoreComponents.totalScore >= scenario.requiredScore {
            for tipId in scenario.unlockTips {
                progressManager.unlockTip(tipId)
            }
        }
    }
}

// MARK: - Helper Extensions

extension GameSessionViewModel {

    /// 현재 진행률 (0.0 ~ 1.0)
    var progress: Double {
        guard let stage = currentStage else { return 0.0 }
        let totalOrders = stage.orders.count
        guard totalOrders > 0 else { return 0.0 }
        return Double(currentOrderIndex) / Double(totalOrders)
    }

    /// 남은 시간 포맷팅 (mm:ss)
    var formattedTime: String {
        let minutes = remainingTime / 60
        let seconds = remainingTime % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
