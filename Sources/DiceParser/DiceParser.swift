import Foundation

/// 骰子解析器主类
class DiceParser {
    
    /// 骰子投掷结果记录
    internal var rolls: [DiceRollResult] = []
    
    /// 重置解析器状态
    internal func reset() {
        rolls.removeAll()
    }
}