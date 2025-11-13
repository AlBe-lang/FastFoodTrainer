import SwiftUI

// MARK: - TipsView
/// 알바 꿀팁 목록 화면
struct TipsView: View {

    // MARK: - Properties
    @StateObject private var viewModel = TipsViewModel()
    @EnvironmentObject var progressManager: ProgressManager
    @Environment(\.dismiss) private var dismiss

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                Color.backgroundGray.ignoresSafeArea()

                if viewModel.loadState == .loading {
                    ProgressView("팁 로딩 중...")
                } else if viewModel.loadState == .success {
                    tipsList
                } else if case .failure(let message) = viewModel.loadState {
                    errorView(message: message)
                }
            }
            .navigationTitle("알바 꿀팁")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("닫기") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                viewModel.loadTips()
            }
        }
    }

    // MARK: - Tips List
    private var tipsList: some View {
        ScrollView {
            VStack(spacing: 16) {
                // 헤더
                headerSection

                // 팁 카드들
                ForEach(viewModel.tips) { tip in
                    TipCardView(
                        tip: tip,
                        isUnlocked: progressManager.unlockedTips.contains(tip.id)
                    )
                }
            }
            .padding()
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("💡 현직자의 꿀팁")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primaryDark)

            Text("실제로 일하는 선배들의 노하우를 배워보세요!")
                .font(.system(size: 14))
                .foregroundColor(.secondaryGray)

            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Text("언락된 팁: \(progressManager.unlockedTips.count)개")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primaryDark)
            }
            .padding(.top, 4)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(12)
    }

    // MARK: - Error View
    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(.red)

            Text("오류가 발생했습니다")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primaryDark)

            Text(message)
                .font(.system(size: 14))
                .foregroundColor(.secondaryGray)
                .multilineTextAlignment(.center)

            Button("다시 시도") {
                viewModel.loadTips()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

// MARK: - TipCardView
/// 개별 팁 카드
private struct TipCardView: View {
    let tip: Tip
    let isUnlocked: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 잠금 상태 배지
            if !isUnlocked {
                HStack {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.secondaryGray)
                    Text("잠금됨")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondaryGray)
                    Spacer()
                }
            }

            // 제목
            HStack {
                Text(tip.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isUnlocked ? .primaryDark : .secondaryGray)

                Spacer()

                // 카테고리 뱃지
                Text(categoryName(tip.category))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(categoryColor(tip.category))
                    .cornerRadius(4)
            }

            // 본문
            if isUnlocked {
                Text(tip.body)
                    .font(.system(size: 14))
                    .foregroundColor(.primaryDark)
                    .lineSpacing(4)
            } else {
                Text("이 팁을 보려면 \(tip.unlockCondition)를 완료하세요.")
                    .font(.system(size: 14))
                    .foregroundColor(.secondaryGray)
                    .italic()
            }

            // 작성자
            if isUnlocked {
                HStack {
                    Image(systemName: "person.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.accentGold)
                    Text(tip.author)
                        .font(.system(size: 12))
                        .foregroundColor(.secondaryGray)
                }
                .padding(.top, 4)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .opacity(isUnlocked ? 1.0 : 0.6)
    }

    /// 카테고리 이름 변환
    private func categoryName(_ category: String) -> String {
        switch category {
        case "greeting": return "인사"
        case "order_taking": return "주문"
        case "upselling": return "추천"
        case "time_management": return "시간관리"
        case "kitchen": return "주방"
        case "complaint": return "클레임"
        case "operations": return "운영"
        case "mindset": return "마인드"
        default: return "일반"
        }
    }

    /// 카테고리 색상
    private func categoryColor(_ category: String) -> Color {
        switch category {
        case "greeting": return Color(hex: "10B981")
        case "order_taking": return Color(hex: "3B82F6")
        case "upselling": return Color(hex: "F59E0B")
        case "time_management": return Color(hex: "8B5CF6")
        case "kitchen": return Color(hex: "EF4444")
        case "complaint": return Color(hex: "EC4899")
        case "operations": return Color(hex: "6366F1")
        case "mindset": return Color(hex: "14B8A6")
        default: return Color.secondaryGray
        }
    }
}

// MARK: - TipsViewModel
/// 팁 목록 관리 ViewModel
class TipsViewModel: ObservableObject {

    @Published var tips: [Tip] = []
    @Published var loadState: LoadState = .idle

    private let scenarioLoader = ScenarioLoader.shared

    /// 팁 로드
    func loadTips() {
        loadState = .loading

        Task {
            do {
                let loadedTips = try await scenarioLoader.loadTips()
                await MainActor.run {
                    self.tips = loadedTips
                    self.loadState = .success
                }
            } catch {
                await MainActor.run {
                    let errorMessage = (error as? ScenarioError)?.errorDescription ?? error.localizedDescription
                    self.loadState = .failure(errorMessage)
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    TipsView()
        .environmentObject(ProgressManager.shared)
}
