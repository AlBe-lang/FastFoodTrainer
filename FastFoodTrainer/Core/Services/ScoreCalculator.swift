import Foundation

// MARK: - ScoreCalculator
/// 게임 결과를 바탕으로 점수를 계산하는 클래스
class ScoreCalculator {
    
    // MARK: - 정확도 계산
    /// 주문 오류 횟수를 기반으로 정확도 점수 산출
    /// - Parameters:
    ///   - totalOrders: 전체 주문 수
    ///   - mistakes: 실수 목록
    /// - Returns: 정확도 점수 (0~40)
    func calculateAccuracy(totalOrders: Int, mistakes: [Mistake]) -> Double {
        guard totalOrders > 0 else { return 0 }
        
        let orderErrors = mistakes.count
        let accuracyRate = Double(totalOrders - orderErrors) / Double(totalOrders)
        return accuracyRate * 40.0
    }
    
    // MARK: - 속도 계산
    /// 평균 주문 처리 시간을 기반으로 속도 점수 산출
    /// - Parameter averageTime: 평균 처리 시간 (초)
    /// - Returns: 속도 점수 (0~30)
    func calculateSpeed(averageTime: TimeInterval) -> Double {
        // 목표: 90초 이내 = 만점 (30점)
        // 90~120초 = 비례 감점
        // 120초 이상 = 15점
        
        let targetTime: TimeInterval = 90.0
        let acceptableTime: TimeInterval = 120.0
        
        if averageTime <= targetTime {
            return 30.0
        } else if averageTime <= acceptableTime {
            // 선형 감점
            let ratio = (acceptableTime - averageTime) / (acceptableTime - targetTime)
            return 15.0 + (ratio * 15.0)
        } else {
            return 15.0
        }
    }
    
    // MARK: - 고객 만족도 계산
    /// 손님별 만족도 평균을 점수화
    /// - Parameter satisfactionScores: 각 손님의 만족도 (0~100)
    /// - Returns: 만족도 점수 (0~20)
    func calculateSatisfaction(satisfactionScores: [Double]) -> Double {
        guard !satisfactionScores.isEmpty else { return 0 }
        
        let averageSatisfaction = satisfactionScores.reduce(0, +) / Double(satisfactionScores.count)
        return (averageSatisfaction / 100.0) * 20.0
    }
    
    // MARK: - 절차 준수 계산
    /// 위생/안전 규칙 준수 여부를 점수화
    /// - Parameter violations: 위반 횟수
    /// - Returns: 절차 준수 점수 (0~10)
    func calculateCompliance(violations: Int) -> Double {
        // 위반 없음 = 만점 (10점)
        // 위반 1회당 -2점
        let deduction = Double(violations) * 2.0
        return max(0, 10.0 - deduction)
    }
    
    // MARK: - 종합 점수 계산
    /// 모든 지표를 종합하여 최종 ScoreComponents 반환
    func calculateFinalScore(
        totalOrders: Int,
        mistakes: [Mistake],
        averageTime: TimeInterval,
        satisfactionScores: [Double],
        complianceViolations: Int
    ) -> ScoreComponents {
        
        let accuracy = calculateAccuracy(totalOrders: totalOrders, mistakes: mistakes)
        let speed = calculateSpeed(averageTime: averageTime)
        let satisfaction = calculateSatisfaction(satisfactionScores: satisfactionScores)
        let compliance = calculateCompliance(violations: complianceViolations)
        
        return ScoreComponents(
            accuracy: accuracy,
            speed: speed,
            satisfaction: satisfaction,
            compliance: compliance
        )
    }
}
