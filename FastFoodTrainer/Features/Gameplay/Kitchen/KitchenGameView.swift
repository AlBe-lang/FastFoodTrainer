import SwiftUI

// MARK: - KitchenGameView
/// 주방 게임 화면 (버거 조립 및 튀김 관리)
struct KitchenGameView: View {

    // MARK: - Properties
    @EnvironmentObject var viewModel: GameSessionViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var assemblySteps: [String] = []
    @State private var currentStepIndex: Int = 0

    // 정답 순서 (예시)
    private let correctAssemblySteps = [
        "bottom_bun",
        "patty",
        "cheese",
        "lettuce",
        "tomato",
        "sauce",
        "top_bun"
    ]

    // MARK: - Body
    var body: some View {
        ZStack {
            Color.backgroundGray.ignoresSafeArea()

            VStack(spacing: 0) {
                // 헤더
                headerSection

                // 주문 정보
                orderInfoSection

                Spacer()

                // 조립 영역
                assemblySection

                // 재료 선택 영역
                ingredientSelectionSection

                // 완료 버튼
                completeButton
            }
        }
        .onAppear {
            if !viewModel.isGameActive {
                viewModel.startGame()
            }
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 12) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "clock.fill")
                        .foregroundColor(.accentGold)
                    Text(viewModel.formattedTime)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primaryDark)
                }

                Spacer()

                Text("\(viewModel.completedOrdersCount) / \(viewModel.currentStage?.orders.count ?? 0)")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondaryGray)

                Spacer()

                Button(action: {
                    viewModel.quitGame()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.secondaryGray)
                }
            }
            .padding(.horizontal)
            .padding(.top, 16)

            ProgressView(value: viewModel.progress)
                .tint(.accentGold)
                .padding(.horizontal)
        }
        .padding(.bottom, 12)
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)
    }

    // MARK: - Order Info Section
    private var orderInfoSection: some View {
        Group {
            if let order = viewModel.currentOrder {
                HStack {
                    Image(systemName: "doc.text.fill")
                        .foregroundColor(.accentGold)
                    Text(order.requestText)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primaryDark)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.top, 16)
            }
        }
    }

    // MARK: - Assembly Section
    private var assemblySection: some View {
        VStack(spacing: 16) {
            Text("조립 과정")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primaryDark)

            // 현재까지 조립된 재료들
            VStack(spacing: 8) {
                if assemblySteps.isEmpty {
                    Text("재료를 선택하여 버거를 조립하세요")
                        .font(.system(size: 14))
                        .foregroundColor(.secondaryGray)
                        .padding()
                } else {
                    ForEach(Array(assemblySteps.enumerated().reversed()), id: \.offset) { index, step in
                        HStack {
                            Image(systemName: ingredientIcon(step))
                            Text(ingredientName(step))
                                .font(.system(size: 16, weight: .medium))
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .frame(maxWidth: .infinity)
                        .background(Color.primaryBlue.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
            }
            .padding()
            .frame(minHeight: 200)
            .background(Color.white)
            .cornerRadius(12)
        }
        .padding(.horizontal)
    }

    // MARK: - Ingredient Selection Section
    private var ingredientSelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("재료 선택")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primaryDark)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(ingredientOptions, id: \.id) { ingredient in
                    Button(action: {
                        addIngredient(ingredient.id)
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: ingredient.icon)
                                .font(.system(size: 24))
                                .foregroundColor(.primaryBlue)

                            Text(ingredient.name)
                                .font(.system(size: 12))
                                .foregroundColor(.primaryDark)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.backgroundGray)
                        .cornerRadius(8)
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .padding(.horizontal)
        .padding(.bottom, 16)
    }

    // MARK: - Complete Button
    private var completeButton: some View {
        Button(action: {
            completeBurgerAssembly()
        }) {
            Text("조립 완료")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(assemblySteps.isEmpty ? Color.secondaryGray : Color.primaryBlue)
                .cornerRadius(12)
        }
        .disabled(assemblySteps.isEmpty)
        .padding()
        .background(Color.white)
    }

    // MARK: - Private Methods

    /// 재료 추가
    private func addIngredient(_ ingredientId: String) {
        assemblySteps.append(ingredientId)
    }

    /// 버거 조립 완료
    private func completeBurgerAssembly() {
        let isCorrect = validateAssembly()
        let satisfaction: Double = isCorrect ? 95.0 : 60.0

        viewModel.completeOrder(isCorrect: isCorrect, satisfaction: satisfaction)

        // 초기화
        assemblySteps.removeAll()
    }

    /// 조립 순서 검증
    private func validateAssembly() -> Bool {
        // 간단한 검증: 순서가 정답과 일치하는지
        return assemblySteps == correctAssemblySteps
    }

    /// 재료 아이콘
    private func ingredientIcon(_ id: String) -> String {
        switch id {
        case "bottom_bun": return "circle"
        case "patty": return "circle.fill"
        case "cheese": return "square.fill"
        case "lettuce": return "leaf.fill"
        case "tomato": return "circle.fill"
        case "sauce": return "drop.fill"
        case "top_bun": return "circle"
        default: return "circle"
        }
    }

    /// 재료 이름
    private func ingredientName(_ id: String) -> String {
        switch id {
        case "bottom_bun": return "아래 번"
        case "patty": return "패티"
        case "cheese": return "치즈"
        case "lettuce": return "양상추"
        case "tomato": return "토마토"
        case "sauce": return "소스"
        case "top_bun": return "위 번"
        default: return id
        }
    }

    /// 재료 옵션
    private var ingredientOptions: [(id: String, name: String, icon: String)] {
        [
            (id: "bottom_bun", name: "아래 번", icon: "circle"),
            (id: "patty", name: "패티", icon: "circle.fill"),
            (id: "cheese", name: "치즈", icon: "square.fill"),
            (id: "lettuce", name: "양상추", icon: "leaf.fill"),
            (id: "tomato", name: "토마토", icon: "circle.fill"),
            (id: "sauce", name: "소스", icon: "drop.fill"),
            (id: "top_bun", name: "위 번", icon: "circle")
        ]
    }
}
