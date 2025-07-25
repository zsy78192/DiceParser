import DiceParser
import Foundation

/// CLI骰子计算器程序入口点
///
/// 使用方法:
/// swift run DiceParserCLI "2d6 + 3"
/// swift run DiceParserCLI "(5 + 3) * 2"
/// swift run DiceParserCLI "Adv(d20) + Dis(d6)"

/// 打印使用帮助
func printUsage() {
    print(
        """
        🎲 骰子计算器 CLI

        使用方法:
            swift run DiceParserCLI <表达式>
            swift run DiceParserCLI --demo-localization

        支持的表达式:
            • 标准骰子: 2d6, d20, d100
            • 优势/劣势: Adv(d20), Dis(d6)
            • 数学运算: +, -, *, /
            • 括号分组: (2d6 + 3) * 2

        示例:
            swift run DiceParserCLI "2d6 + 3"
            swift run DiceParserCLI "(5 + 3) * 2"
            swift run DiceParserCLI "Adv(d20) + Dis(d6) + 5"
            swift run DiceParserCLI --demo-localization
        """)
}

/// 格式化输出结果
func formatResult(_ result: [String: Any]) {
    if let finalResult = result["finalResult"] as? Double {
        // 如果是整数，显示为整数；如果是小数，保留小数部分
        if finalResult == floor(finalResult) {
            print("\n🎯 最终结果: \(Int(finalResult))")
        } else {
            print("\n🎯 最终结果: \(finalResult)")
        }
    }

    if let steps = result["steps"] as? String {
        print("📊 计算步骤: \(steps)")
    }

    if let rolls = result["rolls"] as? [[String: Any]] {
        print("\n🎲 骰子结果:")
        for roll in rolls {
            if let type = roll["type"] as? String {
                print("  \(type): ", terminator: "")

                if type == "d100" {
                    if let tens = roll["tens"] as? Int, let units = roll["units"] as? Int {
                        print("\(tens)0 + \(units) = \(tens * 10 + units)")
                    }
                } else if type.hasPrefix("Adv") || type.hasPrefix("Dis") {
                    if let rollsArray = roll["rolls"] as? [Int] {
                        let rollsStr = rollsArray.map { String($0) }.joined(separator: ", ")
                        let selected = roll["value"] as? Int ?? 0
                        print("\(rollsStr) → \(selected)")
                    }
                } else {
                    if let value = roll["value"] as? Int {
                        print(value)
                    }
                }
            }
        }
    }
}

/// 主程序入口
func main() {
    let arguments = CommandLine.arguments

    // 检查参数
    if arguments.count < 2 {
        printUsage()
        exit(1)
    }

    let expression = arguments[1]

    // 处理特殊命令
    if expression == "--help" || expression == "-h" {
        printUsage()
        exit(0)
    }

    if expression == "--demo-localization" {
        LocalizationDemo.runDemo()
        exit(0)
    }

    let parser = DiceParser()

    do {
        print("🎲 正在计算: \(expression)")
        let result = try parser.evaluateExpression(expression)
        formatResult(result)
    } catch let error as DiceParserError {
        print("❌ 错误: \(error.errorDescription ?? "未知错误")")
        exit(1)
    } catch {
        print("❌ 未知错误: \(error)")
        exit(1)
    }
}

// 运行程序
main()
