import Foundation

/// 骰子投掷功能扩展
extension DiceParser {

    /// 投掷单个骰子
    /// - Parameter faces: 骰子面数
    /// - Returns: 投掷结果
    public func rollDie(faces: Int) -> Int {
        return Int.random(in: 1...faces)
    }

    /// 投掷d100骰子（百分骰）
    /// - Returns: 包含十位和个位的结果
    public func rollD100() -> (value: Int, tens: Int, units: Int) {
        let tens = rollDie(faces: 10) - 1
        let units = rollDie(faces: 10) - 1
        let value = tens * 10 + units
        return (value, tens, units)
    }

    /// 投掷优势/劣势骰子
    /// - Parameters:
    ///   - mode: "Adv" 或 "Dis"
    ///   - faces: 骰子面数
    /// - Returns: 包含两个骰子结果和最终值
    public func rollAdvDis(mode: String, faces: Int) -> (value: Int, rolls: [Int]) {
        let roll1 = rollDie(faces: faces)
        let roll2 = rollDie(faces: faces)

        if mode == "Adv" {
            return (max(roll1, roll2), [roll1, roll2])
        } else {
            return (min(roll1, roll2), [roll1, roll2])
        }
    }
}
