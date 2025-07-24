import Foundation

/// 骰子解析器主类
public class DiceParser {
    
    /// 骰子投掷结果记录
    public internal(set) var rolls: [DiceRollResult] = []
    
    /// 初始化解析器
    public init() {}
    
    /// 重置解析器状态
    public func reset() {
        rolls.removeAll()
    }
}