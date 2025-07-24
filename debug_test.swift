import Foundation

// 调试测试
let parser = DiceParser()

// 测试复杂表达式
do {
    let tokens = try parser.parseExpression("(5 + 3) * 2")
    print("解析tokens: \(tokens)")
    
    let result = try parser.evaluateExpression("(5 + 3) * 2")
    print("计算结果: \(result)")
} catch {
    print("复杂表达式错误: \(error)")
}

// 测试除法表达式
do {
    let tokens = try parser.parseExpression("20 / 4")
    print("解析tokens: \(tokens)")
    
    let result = try parser.evaluateExpression("20 / 4")
    print("计算结果: \(result)")
} catch {
    print("除法表达式错误: \(error)")
}