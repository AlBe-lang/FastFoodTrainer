import SwiftUI

// MARK: - MainHubView
/// 메인 허브 화면: Day 리스트, 전체 진행 상황, 팁/설정 접근
struct MainHubView: View {

    // MARK: - Properties
    @StateObject private var viewModel = MainHubViewModel()
    @EnvironmentObject var progressManager: ProgressManager

    @State private var showTips = false
    @State private var showSettings = false

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                Color.backgroundGray.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // 헤더: 인사 및 진행도
                        headerSection

                        // Day 리스트
                        daysList
                    }
                    .padding()
                }
            }
            .navigationTitle("킹스 그릴 트레이닝")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        // 팁 버튼
                        Button(action: {
                            showTips = true
                        }) {
                            Image(systemName: "lightbulb.fill")
                                .foregroundColor(.accentGold)
                        }

                        // 설정 버튼
                        Button(action: {
                            showSettings = true
                        }) {
                            Image(systemName: "gearshape.fill")
                                .foregroundColor(.primaryBlue)
                        }
                    }
                }
            }
            .sheet(isPresented: $showTips) {
                TipsView()
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .onAppear {
                if viewModel.scenarios.isEmpty {
                    viewModel.loadScenarios()
                }
            }
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 인사
            Text("안녕하세요, \(progressManager.userNickname)님!")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primaryDark)

            // 전체 진행도
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("전체 진행률")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondaryGray)

                    Spacer()

                    Text("\(Int(viewModel.overallProgress() * 100))%")
                        .font(.system(size: 14, weight: .bold))
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
                            .frame(width: geometry.size.width * viewModel.overallProgress(), height: 8)
                            .cornerRadius(4)
                    }
                }
                .frame(height: 8)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }

    // MARK: - Days List
    private var daysList: some View {
        Group {
            if viewModel.loadState == .loading {
                ProgressView("시나리오 로딩 중...")
                    .padding()
            } else if viewModel.loadState == .success {
                ForEach(viewModel.scenarios) { day in
                    NavigationLink(destination: DayDetailView(scenario: day)) {
                        DayCardView(
                            day: day,
                            progress: progressManager.getProgress(for: day.id),
                            isUnlocked: progressManager.isDayUnlocked(day.dayNumber)
                        )
                    }
                    .disabled(!progressManager.isDayUnlocked(day.dayNumber))
                }
            } else if case .failure(let message) = viewModel.loadState {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.red)

                    Text("시나리오를 불러올 수 없습니다")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primaryDark)

                    Text(message)
                        .font(.system(size: 14))
                        .foregroundColor(.secondaryGray)
                        .multilineTextAlignment(.center)

                    Button("다시 시도") {
                        viewModel.loadScenarios()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }
        }
    }
}

// MARK: - MainHubViewModel
class MainHubViewModel: ObservableObject {
    @Published var scenarios: [DayScenario] = []
    @Published var loadState: LoadState = .idle

    private let scenarioLoader = ScenarioLoader.shared
    private let progressManager = ProgressManager.shared

    func loadScenarios() {
        loadState = .loading

        Task {
            do {
                let loadedScenarios = try await scenarioLoader.loadAllScenarios()
                await MainActor.run {
                    self.scenarios = loadedScenarios
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

    func overallProgress() -> Double {
        return progressManager.calculateOverallProgress()
    }
}

// MARK: - DayCardView
/// Day 카드 뷰 (개선 버전)
struct DayCardView: View {
    let day: DayScenario
    let progress: DayProgress?
    let isUnlocked: Bool

    var body: some View {
        HStack(spacing: 16) {
            // Day 번호 및 상태 아이콘
            ZStack {
                Circle()
                    .fill(isUnlocked ? Color.primaryBlue : Color.secondaryGray)
                    .frame(width: 60, height: 60)

                if let progress = progress, progress.isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                } else if !isUnlocked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                } else {
                    Text("\(day.dayNumber)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                }
            }

            // Day 정보
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Day \(day.dayNumber)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primaryBlue)

                    if let progress = progress {
                        Spacer()
                        Text(progress.bestGrade.rawValue)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(gradeColor(progress.bestGrade))
                    }
                }

                Text(day.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isUnlocked ? .primaryDark : .secondaryGray)

                Text(day.description)
                    .font(.system(size: 13))
                    .foregroundColor(.secondaryGray)
                    .lineLimit(2)

                // 최고 점수 표시
                if let progress = progress, progress.bestScore > 0 {
                    HStack(spacing: 6) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.accentGold)
                        Text("최고 점수: \(progress.bestScore)점")
                            .font(.system(size: 12))
                            .foregroundColor(.secondaryGray)
                    }
                    .padding(.top, 4)
                }
            }

            Spacer()

            // 화살표 (잠김이 아닌 경우만)
            if isUnlocked {
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondaryGray)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .opacity(isUnlocked ? 1.0 : 0.6)
        .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)
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

// MARK: - Preview
#Preview {
    MainHubView()
        .environmentObject(ProgressManager.shared)
}
