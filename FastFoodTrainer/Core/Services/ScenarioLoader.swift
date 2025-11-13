import Foundation

// MARK: - LoadState (로딩 상태)
/// 데이터 로딩 상태를 나타내는 열거형
enum LoadState: Equatable {
    case idle
    case loading
    case success
    case failure(String) // 에러 메시지 (한국어)
}

// MARK: - ScenarioLoader (시나리오 로더)
/// 번들에서 JSON 파일을 로드하고 디코딩하는 서비스
class ScenarioLoader {
    
    // MARK: - Singleton
    static let shared = ScenarioLoader()
    private init() {}
    
    // MARK: - Public Methods
    
    /// 모든 Day 시나리오를 로드
    /// - Returns: DayScenario 배열 (실패 시 빈 배열 + 에러 로깅)
    func loadAllScenarios() async throws -> [DayScenario] {
        var scenarios: [DayScenario] = []
        
        // Day 1~7 파일 순회
        for dayNum in 1...7 {
            let filename = "day\(dayNum)"
            do {
                let scenario = try await loadScenario(filename: filename)
                scenarios.append(scenario)
            } catch {
                // 개별 파일 로드 실패 시 로깅만 하고 계속 진행
                print("⚠️ \(filename) 로드 실패: \(error.localizedDescription)")
            }
        }
        
        guard !scenarios.isEmpty else {
            throw ScenarioError.noScenariosFound
        }
        
        return scenarios.sorted { $0.dayNumber < $1.dayNumber }
    }
    
    /// 특정 Day 시나리오를 로드
    /// - Parameter filename: JSON 파일 이름 (확장자 제외)
    /// - Returns: DayScenario 객체
    func loadScenario(filename: String) async throws -> DayScenario {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            throw ScenarioError.fileNotFound(filename)
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let scenario = try decoder.decode(DayScenario.self, from: data)
            return scenario
        } catch let decodingError as DecodingError {
            throw ScenarioError.decodingFailed(filename, decodingError.localizedDescription)
        } catch {
            throw ScenarioError.unknownError(error.localizedDescription)
        }
    }
    
    /// 팁 목록 로드
    func loadTips() async throws -> [Tip] {
        guard let url = Bundle.main.url(forResource: "tips", withExtension: "json") else {
            throw ScenarioError.fileNotFound("tips")
        }
        
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let tipsContainer = try decoder.decode(TipsContainer.self, from: data)
        return tipsContainer.tips
    }
    
    /// 메뉴 마스터 데이터 로드
    func loadMenuItems() async throws -> [MenuItem] {
        guard let url = Bundle.main.url(forResource: "menu_items", withExtension: "json") else {
            throw ScenarioError.fileNotFound("menu_items")
        }
        
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let menuContainer = try decoder.decode(MenuContainer.self, from: data)
        return menuContainer.items
    }
}

// MARK: - Supporting Types

/// 팁 컨테이너 (JSON 최상위 구조)
private struct TipsContainer: Codable {
    let tips: [Tip]
}

/// 메뉴 컨테이너 (JSON 최상위 구조)
private struct MenuContainer: Codable {
    let items: [MenuItem]
}

// MARK: - ScenarioError (에러 타입)
enum ScenarioError: LocalizedError {
    case fileNotFound(String)
    case decodingFailed(String, String)
    case noScenariosFound
    case unknownError(String)
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound(let filename):
            return "파일을 찾을 수 없습니다: \(filename).json\n앱을 재설치하거나 개발자에게 문의하세요."
        case .decodingFailed(let filename, let detail):
            return "\(filename).json 파일 형식이 올바르지 않습니다.\n상세: \(detail)"
        case .noScenariosFound:
            return "사용 가능한 시나리오가 없습니다.\n앱을 재설치해주세요."
        case .unknownError(let detail):
            return "알 수 없는 오류가 발생했습니다.\n상세: \(detail)"
        }
    }
}
