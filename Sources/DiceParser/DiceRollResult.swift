import Foundation

/// 骰子投掷结果结构体
struct DiceRollResult {
    let type: String
    let value: Int
    let tens: Int?
    let units: Int?
    let rolls: [Int]
}