import DiceParser
import Foundation

/// 演示多语言本地化功能的示例程序
class LocalizationDemo {

    /// 演示所有错误类型的本地化消息
    static func demonstrateErrorLocalization() {
        print("=== DiceParser 多语言本地化演示 ===\n")

        let errors: [(DiceParserError, String)] = [
            (.emptyExpression, "空表达式错误"),
            (.invalidOperatorCombination, "无效运算符组合"),
            (.invalidDiceFaces, "无效骰子面数"),
            (.invalidCharacter("@"), "无效字符"),
            (.missingOperator, "缺少运算符"),
            (.diceCountExceeded, "骰子数量超限"),
            (.invalidExpression, "无效表达式"),
            (.unmatchedParentheses, "括号不匹配"),
            (.mathExpressionError("除零错误"), "数学表达式错误"),
        ]

        for (error, description) in errors {
            print("错误类型: \(description)")
            print("本地化消息: \(error.errorDescription ?? "无描述")")
            print("---")
        }
    }

    /// 演示实际的解析错误场景
    static func demonstrateRealErrors() {
        print("\n=== 实际错误场景演示 ===\n")

        let testCases = [
            "",  // 空表达式
            "2d@",  // 无效字符
            "2d0",  // 无效面数
            "2d6)",  // 括号不匹配
            "101d6",  // 超过骰子数量限制
        ]

        let parser = DiceParser()

        for testCase in testCases {
            print("输入: '\(testCase)'")
            do {
                let result = try parser.evaluateExpression(testCase)
                print("结果: \(result)")
            } catch {
                if let diceError = error as? DiceParserError {
                    print("错误: \(diceError.errorDescription ?? "未知错误")")
                } else {
                    print("其他错误: \(error)")
                }
            }
            print("---")
        }
    }

    static func runDemo() {
        demonstrateErrorLocalization()
        demonstrateRealErrors()

        print("\n=== 支持的语言 ===")
        print("• 中文 (zh-Hans)")
        print("• 英文 (en)")
        print("• 法文 (fr)")
        print("• 德文 (de)")
        print("• 日文 (ja)")
        print("• 韩文 (ko)")
        print("• 俄文 (ru)")

        print("\n注意：当前演示使用系统默认语言设置。")
        print("要测试不同语言，请在 iOS/macOS 设备上更改系统语言设置。")
    }
}
