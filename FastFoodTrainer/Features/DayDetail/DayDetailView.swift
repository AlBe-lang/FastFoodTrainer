import SwiftUI

// MARK: - DayDetailView
/// Day 상세 화면: 학습 목표, 시나리오 설명, 시작 버튼
struct DayDetailView: View {

    // MARK: - Properties
    let scenario: DayScenario
    @EnvironmentObject var progressManager: ProgressManager
    @Environment(\.dismiss) private var dismiss
    @State private var showGameView = false

    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                // 헤더 섹션
                headerSection

                // 학습 목표 섹션
                learningGoalsSection

                // 스테이지 정보 섹션
                stagesSection

                // 이전 기록 섹션
                if let progress = progressManager.getProgress(for: scenario.id) {
                    previousRecordSection(progress: progress)
                }

                // 시작 버튼
                startButton
            }
            .padding()
        }
        .background(Color.backgroundGray)
        .navigationTitle("Day \(scenario.dayNumber)")
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $showGameView) {
            GameSessionContainerView(scenario: scenario)
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(scenario.title)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.primaryDark)

            Text(scenario.description)
                .font(.system(size: 16))
                .foregroundColor(.secondaryGray)
                .lineSpacing(4)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(12)
    }

    // MARK: - Learning Goals Section
    private var learningGoalsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("🎯 오늘의 학습 목표")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primaryDark)

            ForEach(Array(scenario.learningGoals.enumerated()), id: \.offset) { index, goal in
                HStack(alignment: .top, spacing: 12) {
                    Text("\(index + 1)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 24, height: 24)
                        .background(Color.accentGold)
                        .clipShape(Circle())

                    Text(goal)
                        .font(.system(size: 16))
                        .foregroundColor(.primaryDark)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(12)
    }

    // MARK: - Stages Section
    private var stagesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("📋 진행 단계")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primaryDark)

            ForEach(Array(scenario.stages.enumerated()), id: \.element.id) { index, stage in
                StageInfoRow(stageNumber: index + 1, stage: stage)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(12)
    }

    // MARK: - Previous Record Section
    private func previousRecordSection(progress: DayProgress) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("📊 이전 기록")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primaryDark)

            HStack(spacing: 20) {
                VStack(spacing: 4) {
                    Text("최고 점수")
                        .font(.system(size: 14))
                        .foregroundColor(.secondaryGray)
                    Text("\(progress.bestScore)점")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primaryBlue)
                }

                Divider()
                    .frame(height: 40)

                VStack(spacing: 4) {
                    Text("최고 등급")
                        .font(.system(size: 14))
                        .foregroundColor(.secondaryGray)
                    Text(progress.bestGrade.rawValue)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(gradeColor(progress.bestGrade))
                }

                Divider()
                    .frame(height: 40)

                VStack(spacing: 4) {
                    Text("도전 횟수")
                        .font(.system(size: 14))
                        .foregroundColor(.secondaryGray)
                    Text("\(progress.attemptCount)회")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.accentGold)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }

    // MARK: - Start Button
    private var startButton: some View {
        Button(action: {
            showGameView = true
        }) {
            HStack {
                Image(systemName: "play.fill")
                    .font(.system(size: 18))
                Text("시작하기")
                    .font(.system(size: 18, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color.primaryBlue)
            .cornerRadius(12)
        }
        .padding(.vertical, 8)
    }

    // MARK: - Helper Methods

    /// 등급에 따른 색상 반환
    private func gradeColor(_ grade: Grade) -> Color {
        switch grade {
        case .s: return Color(hex: "10B981") // 초록색
        case .a: return Color(hex: "3B82F6") // 파란색
        case .b: return Color(hex: "F59E0B") // 주황색
        case .c: return Color(hex: "EF4444") // 빨간색
        case .d: return Color(hex: "6B7280") // 회색
        case .incomplete: return Color.secondaryGray
        }
    }
}

// MARK: - StageInfoRow
/// 스테이지 정보 행
private struct StageInfoRow: View {
    let stageNumber: Int
    let stage: Stage

    var body: some View {
        HStack(spacing: 12) {
            // 스테이지 번호
            Text("Stage \(stageNumber)")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primaryBlue)
                .frame(width: 70, alignment: .leading)

            VStack(alignment: .leading, spacing: 4) {
                Text(stage.title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.primaryDark)

                HStack(spacing: 12) {
                    Label("\(stage.timeLimitSeconds)초", systemImage: "clock.fill")
                    Label("\(stage.orders.count)개 주문", systemImage: "doc.text.fill")
                }
                .font(.system(size: 13))
                .foregroundColor(.secondaryGray)
            }

            Spacer()

            // 타입 아이콘
            Image(systemName: stageTypeIcon(stage.type))
                .font(.system(size: 20))
                .foregroundColor(.accentGold)
        }
        .padding()
        .background(Color.backgroundGray)
        .cornerRadius(8)
    }

    /// 스테이지 타입에 따른 아이콘
    private func stageTypeIcon(_ type: StageType) -> String {
        switch type {
        case .counter: return "person.fill"
        case .kitchen: return "flame.fill"
        case .cleaning: return "sparkles"
        case .complaint: return "exclamationmark.bubble.fill"
        case .mixed: return "star.fill"
        }
    }
}

// MARK: - GameSessionContainerView
/// 게임 세션을 관리하는 컨테이너 뷰
struct GameSessionContainerView: View {
    let scenario: DayScenario
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: GameSessionViewModel

    init(scenario: DayScenario) {
        self.scenario = scenario
        _viewModel = StateObject(wrappedValue: GameSessionViewModel(scenario: scenario))
    }

    var body: some View {
        Group {
            if viewModel.isGameFinished {
                // 게임 종료 → 결과 화면
                ResultSummaryView(
                    dayScenario: scenario,
                    gameResult: viewModel.gameResult!,
                    onDismiss: {
                        dismiss()
                    }
                )
            } else {
                // 게임 진행 중
                if let currentStage = viewModel.currentStage {
                    gameViewForStage(currentStage)
                        .environmentObject(viewModel)
                }
            }
        }
    }

    /// 스테이지 타입에 맞는 게임 뷰 반환
    @ViewBuilder
    private func gameViewForStage(_ stage: Stage) -> some View {
        switch stage.type {
        case .counter, .mixed:
            CounterGameView()
        case .kitchen:
            KitchenGameView()
        case .complaint:
            ComplaintGameView()
        case .cleaning:
            CleaningGameView()
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        DayDetailView(
            scenario: DayScenario(
                id: "day1",
                dayNumber: 1,
                title: "첫 출근, 기본기 익히기",
                description: "오늘은 첫 출근날이에요! 긴장하지 말고 기본적인 주문 받는 법부터 차근차근 배워봐요.",
                learningGoals: [
                    "기본 인사와 주문 듣기",
                    "POS 시스템 이해하기",
                    "단품 메뉴 정확히 입력하기"
                ],
                requiredScore: 60,
                stages: [],
                unlockTips: ["tip_greeting"]
            )
        )
        .environmentObject(ProgressManager.shared)
    }
}
