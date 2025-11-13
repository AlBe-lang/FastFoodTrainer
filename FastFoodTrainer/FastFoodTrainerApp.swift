import SwiftUI

// MARK: - FastFoodTrainerApp
/// 킹스 그릴 트레이닝 앱의 진입점
@main
struct FastFoodTrainerApp: App {
    
    // MARK: - Properties
    @StateObject private var progressManager = ProgressManager.shared
    @State private var showOnboarding = false
    
    // MARK: - Initialization
    init() {
        // 앱 전역 설정
        configureAppearance()
    }
    
    // MARK: - Body
    var body: some Scene {
        WindowGroup {
            Group {
                if progressManager.userNickname.isEmpty {
                    OnboardingView()
                } else {
                    MainHubView()
                }
            }
            .environmentObject(progressManager)
        }
    }
    
    // MARK: - Private Methods
    
    /// 앱 전역 외관 설정
    private func configureAppearance() {
        // 네비게이션 바 외관
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = UIColor.white
        navBarAppearance.titleTextAttributes = [
            .foregroundColor: UIColor(named: "PrimaryDark") ?? UIColor.black,
            .font: UIFont.systemFont(ofSize: 18, weight: .semibold)
        ]
        navBarAppearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor(named: "PrimaryDark") ?? UIColor.black,
            .font: UIFont.systemFont(ofSize: 28, weight: .bold)
        ]
        
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        UINavigationBar.appearance().compactAppearance = navBarAppearance
    }
}
