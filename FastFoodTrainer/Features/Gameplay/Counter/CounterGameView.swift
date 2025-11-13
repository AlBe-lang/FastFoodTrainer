import SwiftUI

// MARK: - CounterGameView
/// 카운터 주문 받기 게임 화면
struct CounterGameView: View {

    // MARK: - Properties
    @EnvironmentObject var viewModel: GameSessionViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var selectedItems: [String] = []
    @State private var currentStep: Int = 0

    // MARK: - Body
    var body: some View {
        ZStack {
            // 배경
            Color.backgroundGray.ignoresSafeArea()

            VStack(spacing: 0) {
                // 헤더 (타이머, 진행바, 종료 버튼)
                headerSection

                // 고객 영역
                customerSection

                Spacer()

                // 메뉴 선택 영역
                menuSelectionSection

                // 하단 액션 버튼
                actionButtons
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
                // 타이머
                HStack(spacing: 6) {
                    Image(systemName: "clock.fill")
                        .foregroundColor(.accentGold)
                    Text(viewModel.formattedTime)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primaryDark)
                }

                Spacer()

                // 진행 상황
                Text("\(viewModel.completedOrdersCount) / \(viewModel.currentStage?.orders.count ?? 0)")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondaryGray)

                Spacer()

                // 종료 버튼
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

            // 진행바
            ProgressView(value: viewModel.progress)
                .tint(.accentGold)
                .padding(.horizontal)
        }
        .padding(.bottom, 12)
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)
    }

    // MARK: - Customer Section
    private var customerSection: some View {
        Group {
            if let order = viewModel.currentOrder {
                VStack(spacing: 16) {
                    // 고객 아바타
                    ZStack {
                        Circle()
                            .fill(customerMoodColor(order.customerMood))
                            .frame(width: 80, height: 80)

                        Image(systemName: "person.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                    }

                    // 고객 이름
                    Text(order.customerName)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primaryDark)

                    // 주문 말풍선
                    Text(order.requestText)
                        .font(.system(size: 16))
                        .foregroundColor(.primaryDark)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        .overlay(
                            // 말풍선 꼬리
                            Triangle()
                                .fill(Color.white)
                                .frame(width: 20, height: 10)
                                .rotationEffect(.degrees(180))
                                .offset(y: 10),
                            alignment: .bottom
                        )
                        .padding(.horizontal, 24)
                }
                .padding(.top, 24)
            } else {
                Text("주문 대기 중...")
                    .font(.system(size: 16))
                    .foregroundColor(.secondaryGray)
                    .padding()
            }
        }
    }

    // MARK: - Menu Selection Section
    private var menuSelectionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("메뉴 선택")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primaryDark)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(sampleMenuItems, id: \.id) { item in
                    MenuItemButton(
                        item: item,
                        isSelected: selectedItems.contains(item.id),
                        onTap: {
                            toggleSelection(item.id)
                        }
                    )
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .padding(.horizontal)
        .padding(.bottom, 16)
    }

    // MARK: - Action Buttons
    private var actionButtons: some View {
        HStack(spacing: 12) {
            // 취소 버튼
            Button(action: {
                selectedItems.removeAll()
            }) {
                Text("취소")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.secondaryGray)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.backgroundGray)
                    .cornerRadius(12)
            }

            // 주문 완료 버튼
            Button(action: {
                completeOrder()
            }) {
                Text("주문 완료")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(selectedItems.isEmpty ? Color.secondaryGray : Color.primaryBlue)
                    .cornerRadius(12)
            }
            .disabled(selectedItems.isEmpty)
        }
        .padding()
        .background(Color.white)
    }

    // MARK: - Private Methods

    /// 메뉴 아이템 선택/해제
    private func toggleSelection(_ itemId: String) {
        if selectedItems.contains(itemId) {
            selectedItems.removeAll { $0 == itemId }
        } else {
            selectedItems.append(itemId)
        }
    }

    /// 주문 완료 처리
    private func completeOrder() {
        guard let order = viewModel.currentOrder else { return }

        // 간단한 검증 (실제로는 더 복잡한 로직 필요)
        let isCorrect = validateOrder(order: order, selected: selectedItems)

        // 만족도 계산 (정확도 기반 간단 계산)
        let satisfaction: Double = isCorrect ? 90.0 : 50.0

        viewModel.completeOrder(isCorrect: isCorrect, satisfaction: satisfaction)

        // 선택 초기화
        selectedItems.removeAll()
    }

    /// 주문 검증 (간략한 버전)
    private func validateOrder(order: Order, selected: [String]) -> Bool {
        // 실제로는 expectedSteps와 비교하여 정확도 판단
        // 여기서는 간단히 아이템 개수만 확인
        return selected.count == order.items.count
    }

    /// 고객 기분에 따른 색상
    private func customerMoodColor(_ mood: CustomerMood) -> Color {
        switch mood {
        case .friendly: return Color(hex: "10B981")
        case .neutral: return Color(hex: "3B82F6")
        case .hurried: return Color(hex: "F59E0B")
        case .careful: return Color(hex: "8B5CF6")
        case .angry: return Color(hex: "EF4444")
        }
    }

    /// 샘플 메뉴 아이템 (실제로는 JSON에서 로드)
    private var sampleMenuItems: [MenuItem] {
        [
            MenuItem(id: "burger_classic", name: "킹스 클래식", category: .burger, price: 5500, imageAssetName: "burger_classic", description: ""),
            MenuItem(id: "burger_spicy_chicken", name: "스파이시 치킨", category: .burger, price: 6000, imageAssetName: "burger_spicy_chicken", description: ""),
            MenuItem(id: "set_classic", name: "클래식 세트", category: .burger, price: 7500, imageAssetName: "set_classic", description: ""),
            MenuItem(id: "set_spicy_chicken", name: "치킨 세트", category: .burger, price: 8000, imageAssetName: "set_spicy_chicken", description: ""),
            MenuItem(id: "side_fries_m", name: "감자튀김 M", category: .side, price: 2000, imageAssetName: "fries_m", description: ""),
            MenuItem(id: "drink_cola_m", name: "콜라 M", category: .drink, price: 1500, imageAssetName: "cola_m", description: "")
        ]
    }
}

// MARK: - MenuItemButton
/// 메뉴 아이템 버튼
private struct MenuItemButton: View {
    let item: MenuItem
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                // 아이콘 (실제로는 이미지 사용)
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.primaryBlue.opacity(0.1) : Color.backgroundGray)
                        .frame(width: 60, height: 60)

                    Image(systemName: iconForCategory(item.category))
                        .font(.system(size: 28))
                        .foregroundColor(isSelected ? .primaryBlue : .secondaryGray)
                }

                Text(item.name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isSelected ? .primaryBlue : .primaryDark)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)

                Text("\(item.price)원")
                    .font(.system(size: 12))
                    .foregroundColor(.secondaryGray)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isSelected ? Color.primaryBlue.opacity(0.05) : Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.primaryBlue : Color.clear, lineWidth: 2)
            )
            .cornerRadius(12)
        }
    }

    private func iconForCategory(_ category: MenuCategory) -> String {
        switch category {
        case .burger: return "circle.fill"
        case .side: return "circle.fill"
        case .drink: return "drop.fill"
        case .dessert: return "sparkles"
        }
    }
}

// MARK: - Triangle (말풍선 꼬리)
private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// MARK: - ComplaintGameView (Placeholder)
/// 클레임 처리 게임 화면 (간단한 플레이스홀더)
struct ComplaintGameView: View {
    @EnvironmentObject var viewModel: GameSessionViewModel

    var body: some View {
        VStack(spacing: 20) {
            Text("클레임 처리 게임")
                .font(.title)
            Text("(구현 예정)")
                .foregroundColor(.secondaryGray)

            Button("다음으로") {
                viewModel.completeOrder(isCorrect: true, satisfaction: 80)
            }
            .buttonStyle(.borderedProminent)
        }
        .onAppear {
            if !viewModel.isGameActive {
                viewModel.startGame()
            }
        }
    }
}

// MARK: - CleaningGameView (Placeholder)
/// 청소 게임 화면 (간단한 플레이스홀더)
struct CleaningGameView: View {
    @EnvironmentObject var viewModel: GameSessionViewModel

    var body: some View {
        VStack(spacing: 20) {
            Text("청소 게임")
                .font(.title)
            Text("(구현 예정)")
                .foregroundColor(.secondaryGray)

            Button("다음으로") {
                viewModel.completeOrder(isCorrect: true, satisfaction: 80)
            }
            .buttonStyle(.borderedProminent)
        }
        .onAppear {
            if !viewModel.isGameActive {
                viewModel.startGame()
            }
        }
    }
}
