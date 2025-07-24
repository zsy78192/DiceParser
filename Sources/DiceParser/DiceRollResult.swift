import Foundation

/// 骰子投掷结果结构体
public struct DiceRollResult {
    public let type: String
    public let value: Int
    public let tens: Int?
    public let units: Int?
    public let rolls: [Int]
    
    public init(type: String, value: Int, tens: Int? = nil, units: Int? = nil, rolls: [Int] = []) {
        self.type = type
        self.value = value
        self.tens = tens
        self.units = units
        self.rolls = rolls
    }
}