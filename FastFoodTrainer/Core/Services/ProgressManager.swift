import Foundation
import Combine

// MARK: - ProgressManager
/// 사용자의 게임 진행 상황을 관리하는 싱글톤 서비스
/// UserDefaults를 사용하여 로컬에 저장
class ProgressManager: ObservableObject {
    
    // MARK: - Singleton
    static let shared = ProgressManager()
    
    // MARK: - Published Properties
    @Published var userNickname: String {
        didSet {
            UserDefaults.standard.set(userNickname, forKey: Keys.nickname)
        }
    }
    
    @Published var dayProgressMap: [String: DayProgress] = [:] {
        didSet {
            saveDayProgress()
        }
    }
    
    @Published var unlockedTips: Set<String> = [] {
        didSet {
            UserDefaults.standard.set(Array(unlockedTips), forKey: Keys.unlockedTips)
        }
    }
    
    // MARK: - Private Keys
    private enum Keys {
        static let nickname = "user_nickname"
        static let dayProgress = "day_progress"
        static let unlockedTips = "unlocked_tips"
    }
    
    // MARK: - Initialization
    private init() {
        // 닉네임 로드
        self.userNickname = UserDefaults.standard.string(forKey: Keys.nickname) ?? ""
        
        // 진행 상황 로드
        loadDayProgress()
        
        // 언락된 팁 로드
        if let tipsArray = UserDefaults.standard.array(forKey: Keys.unlockedTips) as? [String] {
            self.unlockedTips = Set(tipsArray)
        }
    }
    
    // MARK: - Public Methods
    
    /// 특정 Day의 진행 상황 조회
    func getProgress(for dayId: String) -> DayProgress? {
        return dayProgressMap[dayId]
    }
    
    /// Day 완료 후 결과 업데이트
    func updateDayResult(dayId: String, score: Int, grade: Grade) {
        if var progress = dayProgressMap[dayId] {
            // 기존 기록보다 높은 점수일 때만 업데이트
            if score > progress.bestScore {
                progress.bestScore = score
                progress.bestGrade = grade
            }
            progress.isCompleted = (score >= 60) // 60점 이상 합격
            progress.attemptCount += 1
            progress.lastPlayedDate = Date()
            dayProgressMap[dayId] = progress
        } else {
            // 첫 플레이
            let newProgress = DayProgress(
                dayId: dayId,
                isCompleted: (score >= 60),
                bestScore: score,
                bestGrade: grade,
                attemptCount: 1,
                lastPlayedDate: Date()
            )
            dayProgressMap[dayId] = newProgress
        }
    }
    
    /// 팁 언락
    func unlockTip(_ tipId: String) {
        unlockedTips.insert(tipId)
    }
    
    /// 특정 Day가 잠금 해제되었는지 확인
    /// (순차적 언락: 이전 Day 완료해야 다음 Day 플레이 가능)
    func isDayUnlocked(_ dayNumber: Int) -> Bool {
        if dayNumber == 1 {
            return true // 첫 날은 항상 언락
        }
        
        let previousDayId = "day\(dayNumber - 1)"
        return dayProgressMap[previousDayId]?.isCompleted ?? false
    }
    
    /// 전체 진행률 계산 (0.0 ~ 1.0)
    func calculateOverallProgress() -> Double {
        let totalDays = 7
        let completedCount = dayProgressMap.values.filter { $0.isCompleted }.count
        return Double(completedCount) / Double(totalDays)
    }
    
    /// 모든 데이터 초기화 (주의: 복구 불가)
    func resetAllProgress() {
        userNickname = ""
        dayProgressMap.removeAll()
        unlockedTips.removeAll()
        
        UserDefaults.standard.removeObject(forKey: Keys.nickname)
        UserDefaults.standard.removeObject(forKey: Keys.dayProgress)
        UserDefaults.standard.removeObject(forKey: Keys.unlockedTips)
    }
    
    // MARK: - Private Methods
    
    /// Day 진행 상황을 UserDefaults에 저장
    private func saveDayProgress() {
        if let encoded = try? JSONEncoder().encode(dayProgressMap) {
            UserDefaults.standard.set(encoded, forKey: Keys.dayProgress)
        }
    }
    
    /// Day 진행 상황을 UserDefaults에서 로드
    private func loadDayProgress() {
        if let data = UserDefaults.standard.data(forKey: Keys.dayProgress),
           let decoded = try? JSONDecoder().decode([String: DayProgress].self, from: data) {
            self.dayProgressMap = decoded
        }
    }
}
