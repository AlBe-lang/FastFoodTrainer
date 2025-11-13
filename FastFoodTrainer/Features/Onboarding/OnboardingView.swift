import SwiftUI

// MARK: - OnboardingView
/// 온보딩 화면: 앱 소개 및 닉네임 입력
struct OnboardingView: View {
    
    // MARK: - Properties
    @State private var currentPage: Int = 0
    @State private var nickname: String = ""
    @State private var isNicknameValid: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject var progressManager: ProgressManager
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // 배경 그라데이션
            LinearGradient(
                colors: [Color.primaryBlue, Color.primaryBlue.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            TabView(selection: $currentPage) {
                // 페이지 1: 앱 소개
                introductionPage
                    .tag(0)
                
                // 페이지 2: 닉네임 입력
                nicknamePage
                    .tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
        }
    }
    
    // MARK: - Introduction Page
    private var introductionPage: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // 상단 일러스트레이션
            Image(systemName: "storefront.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .foregroundColor(.white)
                .padding(.bottom, 20)
            
            // 타이틀
            VStack(spacing: 12) {
                Text("첫 알바, 걱정되시나요?")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                
                Text("킹스 그릴에서 미리 연습해보세요!")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, 40)
            
            Spacer()
            
            // 핵심 기능 3가지
            VStack(alignment: .leading, spacing: 20) {
                FeatureRow(
                    icon: "note.text",
                    title: "실전 같은 주문 연습",
                    description: "진짜 손님처럼 다양한 주문을 경험해요"
                )
                
                FeatureRow(
                    icon: "flame.fill",
                    title: "주방 조리 체험",
                    description: "버거 조립부터 튀김까지 직접 만들어봐요"
                )
                
                FeatureRow(
                    icon: "lightbulb.fill",
                    title: "현직자 꿀팁 제공",
                    description: "실제로 일하는 분들의 노하우를 배워요"
                )
            }
            .padding(.horizontal, 40)
            
            Spacer()
            
            // 다음 버튼
            Button(action: {
                withAnimation {
                    currentPage = 1
                }
            }) {
                Text("시작하기")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primaryBlue)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.white)
                    .cornerRadius(28)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
    }
    
    // MARK: - Nickname Page
    private var nicknamePage: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // 상단 아이콘
            Image(systemName: "person.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .foregroundColor(.white)
            
            // 안내 문구
            VStack(spacing: 12) {
                Text("매장에서 불릴 이름을 정해주세요!")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("친근한 닉네임으로 설정해보세요")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.horizontal, 40)
            
            Spacer()
            
            // 닉네임 입력 필드
            VStack(alignment: .leading, spacing: 8) {
                TextField("예: 민지, 준호, 수연", text: $nickname)
                    .font(.system(size: 20, weight: .medium))
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .onChange(of: nickname) { newValue in
                        validateNickname(newValue)
                    }
                
                if !nickname.isEmpty && !isNicknameValid {
                    Text("⚠️ 2~10자 사이로 입력해주세요")
                        .font(.system(size: 14))
                        .foregroundColor(.yellow)
                }
            }
            .padding(.horizontal, 40)
            
            Spacer()
            
            // 시작하기 버튼
            Button(action: {
                completeOnboarding()
            }) {
                Text("시작하기")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primaryBlue)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(isNicknameValid ? Color.white : Color.white.opacity(0.5))
                    .cornerRadius(28)
            }
            .disabled(!isNicknameValid)
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
    }
    
    // MARK: - Private Methods
    
    /// 닉네임 유효성 검증
    private func validateNickname(_ value: String) {
        let trimmed = value.trimmingCharacters(in: .whitespaces)
        isNicknameValid = trimmed.count >= 2 && trimmed.count <= 10
    }
    
    /// 온보딩 완료 처리
    private func completeOnboarding() {
        progressManager.userNickname = nickname.trimmingCharacters(in: .whitespaces)
        dismiss()
    }
}

// MARK: - FeatureRow (기능 소개 행)
private struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.accentGold)
                .frame(width: 40, height: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
    }
}
