import SwiftUI

// MARK: - ResultSummaryView
/// 게임 결과 요약 화면
struct ResultSummaryView: View {

    // MARK: - Properties
    let dayScenario: DayScenario
    let gameResult: GameResult
    let onDismiss: () -> Void

    @EnvironmentObject var progressManager: ProgressManager

    @State private var showConfetti: Bool = false

    // MARK: - Body
    var body: some View {
        ZStack {
            Color.backgroundGray.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // 헤더: 등급 및 총점
                    gradeHeaderSection

                    // 점수 상세
                    scoreBreakdownSection

                    // 실수 목록
                    if !gameResult.mistakes.isEmpty {
                        mistakesSection
                    }

                    // 현직자 팁 카드
                    tipsSection

                    // 버튼 영역
                    actionButtons
                }
                .padding()
            }
        }
        .onAppear {
            // 합격 시 축하 효과
            if gameResult.scoreComponents.totalScore >= dayScenario.requiredScore {
                showConfetti = true
            }
        }
    }

    // MARK: - Grade Header Section
    private var gradeHeaderSection: some View {
        VStack(spacing: 16) {
            // 등급 뱃지
            ZStack {
                Circle()
                    .fill(gradeColor(gameResult.scoreComponents.grade))
                    .frame(width: 120, height: 120)

                Text(gameResult.scoreComponents.grade.rawValue)
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.white)
            }

            // 총점
            Text("\(gameResult.scoreComponents.totalScore)점")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.primaryDark)

            // 합격/불합격 메시지
            Text(passMessage)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(gameResult.scoreComponents.totalScore >= dayScenario.requiredScore ? .green : .red)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(16)
    }

    // MARK: - Score Breakdown Section
    private var scoreBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("📊 점수 상세")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primaryDark)

            ScoreRow(title: "정확도", score: gameResult.scoreComponents.accuracy, maxScore: 40)
            ScoreRow(title: "속도", score: gameResult.scoreComponents.speed, maxScore: 30)
            ScoreRow(title: "고객 만족도", score: gameResult.scoreComponents.satisfaction, maxScore: 20)
            ScoreRow(title: "절차 준수", score: gameResult.scoreComponents.compliance, maxScore: 10)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }

    // MARK: - Mistakes Section
    private var mistakesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("⚠️ 실수 내역")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primaryDark)

            ForEach(gameResult.mistakes) { mistake in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(.red)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(mistake.description)
                            .font(.system(size: 14))
                            .foregroundColor(.primaryDark)

                        Text("-\(mistake.deductedPoints)점")
                            .font(.system(size: 12))
                            .foregroundColor(.secondaryGray)
                    }

                    Spacer()
                }
                .padding()
                .background(Color.backgroundGray)
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }

    // MARK: - Tips Section
    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("💡 다음엔 이렇게 해보세요!")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primaryDark)

            VStack(alignment: .leading, spacing: 8) {
                if gameResult.scoreComponents.accuracy < 30 {
                    TipCard(text: "주문을 받을 때 꼭 복창하세요. 실수를 미리 잡을 수 있어요!")
                }
                if gameResult.scoreComponents.speed < 20 {
                    TipCard(text: "연습하면 속도는 자연스럽게 빨라져요. 정확도를 먼저 챙기세요!")
                }
                if gameResult.scoreComponents.satisfaction < 15 {
                    TipCard(text: "밝은 표정과 친절한 말투가 만족도를 높여요.")
                }

                // 기본 격려 메시지
                TipCard(text: "수고하셨어요! 실전에서도 이 정도면 충분히 잘 하실 거예요 👍", isPositive: true)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }

    // MARK: - Action Buttons
    private var actionButtons: some View {
        VStack(spacing: 12) {
            // 다시 도전
            Button(action: {
                // 다시 시작 로직 (현재는 닫기만)
                onDismiss()
            }) {
                Text("다시 도전")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primaryBlue)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.primaryBlue, lineWidth: 2)
                    )
                    .cornerRadius(12)
            }

            // 메인으로
            Button(action: {
                onDismiss()
            }) {
                Text("메인으로")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.primaryBlue)
                    .cornerRadius(12)
            }
        }
    }

    // MARK: - Helper Properties

    /// 합격/불합격 메시지
    private var passMessage: String {
        if gameResult.scoreComponents.totalScore >= dayScenario.requiredScore {
            return "🎉 합격! 다음 Day가 열렸어요!"
        } else {
            return "조금 더 연습이 필요해요. 다시 도전해보세요!"
        }
    }

    /// 등급에 따른 색상
    private func gradeColor(_ grade: Grade) -> Color {
        switch grade {
        case .s: return Color(hex: "10B981")
        case .a: return Color(hex: "3B82F6")
        case .b: return Color(hex: "F59E0B")
        case .c: return Color(hex: "EF4444")
        case .d: return Color(hex: "6B7280")
        case .incomplete: return Color.secondaryGray
        }
    }
}

// MARK: - ScoreRow
/// 점수 항목 행
private struct ScoreRow: View {
    let title: String
    let score: Double
    let maxScore: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primaryDark)

                Spacer()

                Text("\(Int(score.rounded())) / \(maxScore)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primaryBlue)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.backgroundGray)
                        .frame(height: 8)
                        .cornerRadius(4)

                    Rectangle()
                        .fill(Color.primaryBlue)
                        .frame(width: geometry.size.width * (score / Double(maxScore)), height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
        }
    }
}

// MARK: - TipCard
/// 팁 카드
private struct TipCard: View {
    let text: String
    var isPositive: Bool = false

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: isPositive ? "checkmark.circle.fill" : "lightbulb.fill")
                .foregroundColor(isPositive ? .green : .accentGold)

            Text(text)
                .font(.system(size: 14))
                .foregroundColor(.primaryDark)
                .lineSpacing(4)
        }
        .padding()
        .background(isPositive ? Color.green.opacity(0.05) : Color.accentGold.opacity(0.05))
        .cornerRadius(8)
    }
}
