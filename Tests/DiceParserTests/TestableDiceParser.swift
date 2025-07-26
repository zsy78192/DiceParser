import Foundation

@testable import DiceParser

/// 用于测试的可控制骰子投掷结果的DiceParser子类
class TestableDiceParser: DiceParser {

    private var fixedRolls: [Int] = []
    private var fixedD100Rolls: [(value: Int, tens: Int, units: Int)] = []
    private var fixedAdvDisRolls: [(value: Int, rolls: [Int])] = []

    private var rollIndex = 0
    private var d100Index = 0
    private var advDisIndex = 0

    /// 设置固定的骰子投掷结果
    func setFixedRolls(_ rolls: [Int]) {
        fixedRolls = rolls
        rollIndex = 0
    }

    /// 设置固定的d100投掷结果
    func setFixedD100Rolls(_ rolls: [(value: Int, tens: Int, units: Int)]) {
        fixedD100Rolls = rolls
        d100Index = 0
    }

    /// 设置固定的优势/劣势投掷结果
    func setFixedAdvDisRolls(_ rolls: [(value: Int, rolls: [Int])]) {
        fixedAdvDisRolls = rolls
        advDisIndex = 0
    }

    /// 重置所有索引
    func resetTestState() {
        rollIndex = 0
        d100Index = 0
        advDisIndex = 0
    }

    // MARK: - 重写的骰子投掷方法

    override func rollDie(faces: Int) -> Int {
        guard rollIndex < fixedRolls.count else {
            // 如果没有更多固定结果，使用默认随机
            return super.rollDie(faces: faces)
        }

        let result = fixedRolls[rollIndex]
        rollIndex += 1
        return result
    }

    override func rollD100() -> (value: Int, tens: Int, units: Int) {
        guard d100Index < fixedD100Rolls.count else {
            // 如果没有更多固定结果，使用默认随机
            return super.rollD100()
        }

        let result = fixedD100Rolls[d100Index]
        d100Index += 1
        return result
    }

    override func rollAdvDis(mode: String, faces: Int) -> (value: Int, rolls: [Int]) {
        guard advDisIndex < fixedAdvDisRolls.count else {
            // 如果没有更多固定结果，使用默认随机
            return super.rollAdvDis(mode: mode, faces: faces)
        }

        let result = fixedAdvDisRolls[advDisIndex]
        advDisIndex += 1
        return result
    }
}
