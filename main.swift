import Foundation

/// 骰子解析器演示程序
class DiceParserDemo {
    
    static func run() {
        let parser = DiceParser()
        
        print("🎲 骰子表达式解析器演示")
        print("=" * 40)
        
        let testExpressions = [
            "2d6 + 3",
            "Adv(d20)",
            "Dis(d6) + 2",
            "d100",
            "(d6 + d8) * 2",
            "Adv(d20) + Dis(d6) - 5"
        ]
        
        for expression in testExpressions {
            print("\n表达式: \(expression)")
            print("-" * 20)
            
            do {
                let result = try parser.evaluateExpression(expression)
                
                if let rolls = result["rolls"] as? [[String: Any]] {
                    print("投掷结果:")
                    for roll in rolls {
                        let type = roll["type"] as? String ?? "未知"
                        let value = roll["value"] as? Int ?? 0
                        
                        if let tens = roll["tens"] as? Int, let units = roll["units"] as? Int {
                            print("  \(type): \(tens) + \(units) = \(value)")
                        } else if let rollsList = roll["rolls"] as? [Int] {
                            print("  \(type): \(rollsList) → \(value)")
                        } else {
                            print("  \(type): \(value)")
                        }
                    }
                }
                
                if let steps = result["steps"] as? String {
                    print("计算步骤: \(steps)")
                }
                
                if let finalResult = result["finalResult"] as? Double {
                    print("最终结果: \(Int(finalResult))")
                }
                
            } catch let error as DiceParserError {
                print("错误: \(error.localizedDescription)")
            } catch {
                print("未知错误: \(error)")
            }
        }
        
        print("\n" + "=" * 40)
        print("演示完成！")
    }
}

/// 交互式测试程序
class InteractiveDiceParser {
    
    static func run() {
        let parser = DiceParser()
        
        print("🎲 交互式骰子计算器")
        print("输入 'quit' 或 'exit' 退出")
        print("支持的表达式格式:")
        print("  2d6 + 3        - 2个6面骰子加3")
        print("  Adv(d20)       - d20优势投掷")
        print("  Dis(d6) + 2    - d6劣势投掷加2")
        print("  d100           - 百分骰")
        print("  (d6 + d8) * 2  - 括号内的计算")
        print("=" * 50)
        
        while true {
            print("\n请输入表达式: ", terminator: "")
            
            guard let input = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines) else {
                continue
            }
            
            if input.lowercased() == "quit" || input.lowercased() == "exit" {
                print("感谢使用！再见！")
                break
            }
            
            if input.isEmpty {
                continue
            }
            
            do {
                let result = try parser.evaluateExpression(input)
                
                if let steps = result["steps"] as? String,
                   let finalResult = result["finalResult"] as? Double {
                    print("计算步骤: \(steps)")
                    print("最终结果: \(Int(finalResult))")
                }
                
            } catch let error as DiceParserError {
                print("错误: \(error.localizedDescription)")
            } catch {
                print("未知错误: \(error)")
            }
        }
    }
}

/// 单元测试运行器
class UnitTestRunner {
    
    static func run() {
        print("🧪 运行单元测试...")
        print("=" * 30)
        
        let testSuite = DiceParserTests()
        
        // 定义测试方法
        let testMethods: [() throws -> Void] = [
            testSuite.testNumberConstants,
            testSuite.testDivisionOperation,
            testSuite.testEmptyExpression,
            testSuite.testInvalidDiceFaces,
            testSuite.testInvalidCharacters,
            testSuite.testConsecutiveOperators,
            testSuite.testMissingOperator,
            testSuite.testDiceCountLimit,
            testSuite.testExpressionParsing,
            testSuite.testComplexExpression,
            testSuite.testStandardDiceOperation,
            testSuite.testAdvantageDisadvantage,
            testSuite.testD100Dice,
            testSuite.testMixedExpression,
            testSuite.testErrorHandling
        ]
        
        var passed = 0
        var failed = 0
        
        for testMethod in testMethods {
            do {
                try testMethod()
                passed += 1
                print("✅ 测试通过")
            } catch {
                failed += 1
                print("❌ 测试失败: \(error)")
            }
        }
        
        print("\n测试结果:")
        print("通过: \(passed)")
        print("失败: \(failed)")
        print("总计: \(testMethods.count)")
        
        if failed == 0 {
            print("🎉 所有测试通过！")
        }
    }
}

// 程序入口点
print("请选择运行模式:")
print("1. 演示程序")
print("2. 交互式计算器")
print("3. 单元测试")
print("输入选择 (1/2/3): ", terminator: "")

if let choice = readLine() {
    switch choice.trimmingCharacters(in: .whitespacesAndNewlines) {
    case "1":
        DiceParserDemo.run()
    case "2":
        InteractiveDiceParser.run()
    case "3":
        UnitTestRunner.run()
    default:
        print("无效选择，运行演示程序")
        DiceParserDemo.run()
    }
} else {
    print("未输入，运行演示程序")
    DiceParserDemo.run()
}