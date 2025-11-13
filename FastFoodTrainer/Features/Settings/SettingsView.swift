import SwiftUI

// MARK: - SettingsView
/// 설정 화면
struct SettingsView: View {

    // MARK: - Properties
    @EnvironmentObject var progressManager: ProgressManager
    @Environment(\.dismiss) private var dismiss

    @State private var showResetAlert: Bool = false
    @State private var soundEnabled: Bool = true
    @State private var hapticEnabled: Bool = true

    // MARK: - Body
    var body: some View {
        NavigationStack {
            List {
                // 프로필 섹션
                profileSection

                // 게임 설정 섹션
                gameSettingsSection

                // 진행 상황 섹션
                progressSection

                // 정보 섹션
                infoSection
            }
            .navigationTitle("설정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("완료") {
                        dismiss()
                    }
                }
            }
            .alert("진행 상황 초기화", isPresented: $showResetAlert) {
                Button("취소", role: .cancel) { }
                Button("초기화", role: .destructive) {
                    progressManager.resetAllProgress()
                    dismiss()
                }
            } message: {
                Text("모든 진행 상황이 삭제됩니다. 이 작업은 되돌릴 수 없습니다.")
            }
        }
    }

    // MARK: - Profile Section
    private var profileSection: some View {
        Section {
            HStack {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.primaryBlue)

                VStack(alignment: .leading, spacing: 4) {
                    Text(progressManager.userNickname)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primaryDark)

                    Text("킹스 그릴 트레이너")
                        .font(.system(size: 14))
                        .foregroundColor(.secondaryGray)
                }

                Spacer()
            }
            .padding(.vertical, 8)
        } header: {
            Text("프로필")
        }
    }

    // MARK: - Game Settings Section
    private var gameSettingsSection: some View {
        Section {
            Toggle(isOn: $soundEnabled) {
                HStack {
                    Image(systemName: "speaker.wave.2.fill")
                        .foregroundColor(.primaryBlue)
                    Text("효과음")
                }
            }

            Toggle(isOn: $hapticEnabled) {
                HStack {
                    Image(systemName: "hand.tap.fill")
                        .foregroundColor(.primaryBlue)
                    Text("진동 피드백")
                }
            }
        } header: {
            Text("게임 설정")
        }
    }

    // MARK: - Progress Section
    private var progressSection: some View {
        Section {
            // 전체 진행률
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(.accentGold)
                Text("전체 진행률")
                Spacer()
                Text("\(Int(progressManager.calculateOverallProgress() * 100))%")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primaryBlue)
            }

            // 언락된 팁
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.accentGold)
                Text("언락된 팁")
                Spacer()
                Text("\(progressManager.unlockedTips.count)개")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primaryBlue)
            }

            // 초기화 버튼
            Button(role: .destructive, action: {
                showResetAlert = true
            }) {
                HStack {
                    Image(systemName: "trash.fill")
                    Text("진행 상황 초기화")
                }
            }
        } header: {
            Text("진행 상황")
        }
    }

    // MARK: - Info Section
    private var infoSection: some View {
        Section {
            NavigationLink(destination: AboutView()) {
                HStack {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.primaryBlue)
                    Text("앱 정보")
                }
            }

            NavigationLink(destination: PrivacyView()) {
                HStack {
                    Image(systemName: "hand.raised.fill")
                        .foregroundColor(.primaryBlue)
                    Text("개인정보 처리방침")
                }
            }

            Link(destination: URL(string: "https://github.com")!) {
                HStack {
                    Image(systemName: "link")
                        .foregroundColor(.primaryBlue)
                    Text("GitHub 저장소")
                }
            }

            HStack {
                Text("버전")
                Spacer()
                Text("1.0.0")
                    .foregroundColor(.secondaryGray)
            }
        } header: {
            Text("정보")
        }
    }
}

// MARK: - AboutView
/// 앱 정보 화면
private struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Image(systemName: "storefront.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.primaryBlue)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 40)

                Text("킹스 그릴 트레이닝")
                    .font(.system(size: 24, weight: .bold))
                    .frame(maxWidth: .infinity)

                Text("버전 1.0.0")
                    .font(.system(size: 14))
                    .foregroundColor(.secondaryGray)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 20)

                Group {
                    Text("소개")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primaryDark)

                    Text("""
                    킹스 그릴 트레이닝은 패스트푸드 매장에서 처음 일하는 알바생을 위한 실전 연습 앱입니다.

                    실제 근무 전에 게임을 통해 업무를 미리 경험하고, 자신감을 갖고 첫 출근할 수 있도록 도와줍니다.

                    카운터 주문 받기, 주방 조리, 클레임 처리 등 다양한 업무를 안전한 환경에서 연습해보세요!
                    """)
                    .font(.system(size: 14))
                    .foregroundColor(.primaryDark)
                    .lineSpacing(4)
                }

                Divider()
                    .padding(.vertical)

                Group {
                    Text("제작")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primaryDark)

                    Text("""
                    이 프로젝트는 실제 패스트푸드 매장에서 일하는 알바생들의 이야기를 바탕으로 만들어졌습니다.

                    Made with ❤️ for part-time workers everywhere
                    """)
                    .font(.system(size: 14))
                    .foregroundColor(.primaryDark)
                    .lineSpacing(4)
                }
            }
            .padding()
        }
        .navigationTitle("앱 정보")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - PrivacyView
/// 개인정보 처리방침 화면
private struct PrivacyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("개인정보 처리방침")
                    .font(.system(size: 20, weight: .bold))
                    .padding(.bottom, 8)

                Text("""
                킹스 그릴 트레이닝은 사용자의 개인정보를 소중히 다룹니다.

                **수집하는 정보**
                - 닉네임 (선택적)
                - 게임 진행 상황 (로컬 저장)

                **정보의 사용**
                - 게임 진행 상황 저장 및 표시
                - 학습 성과 분석 및 피드백 제공

                **정보의 보관**
                - 모든 데이터는 사용자의 기기에만 저장됩니다.
                - 외부 서버로 전송되지 않습니다.

                **사용자의 권리**
                - 언제든지 설정에서 모든 데이터를 삭제할 수 있습니다.

                본 개인정보 처리방침은 2025년 1월 1일부터 시행됩니다.
                """)
                .font(.system(size: 14))
                .foregroundColor(.primaryDark)
                .lineSpacing(6)
            }
            .padding()
        }
        .navigationTitle("개인정보 처리방침")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Preview
#Preview {
    SettingsView()
        .environmentObject(ProgressManager.shared)
}
