import Foundation

// 添加到项目根目录用于调试

// 示例：测试计算结果和步骤不一致问题
let diceParser = DiceParser()

// 设置固定种子以确保可重现的结果
srand48(12345)

do {
    let result = try diceParser.evaluateExpression("2d6")
    print("Result: \(result)")
    print("Final Result: \(result["finalResult"] ?? "N/A")")
    print("Steps: \(result["steps"] ?? "N/A")")
    print("Rolls: \(result["rolls"] ?? "N/A")")
} catch {
    print("Error: \(error)")
}
