import SwiftUI

// MARK: - MainHubView
/// 메인 허브 화면: Day 리스트 및 전체 진행 상황
struct MainHubView: View {
    
    @StateObject private var viewModel = MainHubViewModel()
    @EnvironmentObject var progressManager: ProgressManager
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 헤더
                    Text("안녕하세요, \(progressManager.userNickname)님! 👋")
                        .font(.system(size: 20, weight: .bold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // 진행도
                    ProgressView(value: viewModel.overallProgress())
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                    
                    // Day 리스트
                    ForEach(viewModel.scenarios) { day in
                        DayCardView(day: day)
                    }
                }
                .padding()
            }
            .background(Color.backgroundGray)
            .navigationTitle("킹스 그릴 트레이닝")
            .onAppear {
                if viewModel.scenarios.isEmpty {
                    viewModel.loadScenarios()
                }
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
struct DayCardView: View {
    let day: DayScenario
    
    var body: some View {
        HStack {
            Text("Day \(day.dayNumber)")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primaryBlue)
            
            VStack(alignment: .leading) {
                Text(day.title)
                    .font(.system(size: 16, weight: .semibold))
                Text(day.description)
                    .font(.system(size: 14))
                    .foregroundColor(.secondaryGray)
                    .lineLimit(2)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
}
