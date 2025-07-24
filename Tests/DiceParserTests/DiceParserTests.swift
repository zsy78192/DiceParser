import XCTest
@testable import DiceParser

/// 骰子解析器测试类
class DiceParserTests: XCTestCase {
    
    var diceParser: DiceParser!
    
    override func setUp() {
        super.setUp()
        diceParser = DiceParser()
    }
    
    override func tearDown() {
        diceParser = nil
        super.tearDown()
    }
    
    /// 测试数字常量表达式
    func testNumberConstants() throws {
        // 由于Swift没有mock随机数，我们测试解析和计算逻辑
        // 这里测试简单的数字表达式
        let result = try diceParser.evaluateExpression("10 + 5 - 3")
        XCTAssertEqual(result["finalResult"] as? Double, 12.0)
        XCTAssertEqual(result["steps"] as? String, "10 + 5 - 3")
    }
    
    /// 测试除法运算
    func testDivisionOperation() throws {
        let result = try diceParser.evaluateExpression("20 / 4")
        XCTAssertEqual(result["finalResult"] as? Double, 5.0)
        XCTAssertEqual(result["steps"] as? String, "20 / 4")
    }
    
    /// 测试空表达式
    func testEmptyExpression() {
        XCTAssertThrowsError(try diceParser.evaluateExpression("")) { error in
            XCTAssertTrue(error is DiceParserError)
            if case DiceParserError.emptyExpression = error {
                // 正确错误类型
            } else {
                XCTFail("期望emptyExpression错误")
            }
        }
    }
    
    /// 测试无效面数
    func testInvalidDiceFaces() {
        XCTAssertThrowsError(try diceParser.evaluateExpression("2d0")) { error in
            XCTAssertTrue(error is DiceParserError)
            if case DiceParserError.invalidDiceFaces = error {
                // 正确错误类型
            } else {
                XCTFail("期望invalidDiceFaces错误")
            }
        }
        
        XCTAssertThrowsError(try diceParser.evaluateExpression("Adv(d0)")) { error in
            XCTAssertTrue(error is DiceParserError)
            if case DiceParserError.invalidDiceFaces = error {
                // 正确错误类型
            } else {
                XCTFail("期望invalidDiceFaces错误")
            }
        }
    }
    
    /// 测试无效字符
    func testInvalidCharacters() {
        XCTAssertThrowsError(try diceParser.evaluateExpression("2d6 + abc")) { error in
            XCTAssertTrue(error is DiceParserError)
            if case DiceParserError.invalidCharacter = error {
                // 正确错误类型
            } else {
                XCTFail("期望invalidCharacter错误")
            }
        }
    }
    
    /// 测试连续运算符
    func testConsecutiveOperators() {
        XCTAssertThrowsError(try diceParser.evaluateExpression("d6 ++ d10")) { error in
            XCTAssertTrue(error is DiceParserError)
            if case DiceParserError.invalidOperatorCombination = error {
                // 正确错误类型
            } else {
                XCTFail("期望invalidOperatorCombination错误")
            }
        }
    }
    
    /// 测试缺少运算符
    func testMissingOperator() {
        XCTAssertThrowsError(try diceParser.evaluateExpression("d6 d10")) { error in
            XCTAssertTrue(error is DiceParserError)
            if case DiceParserError.missingOperator = error {
                // 正确错误类型
            } else {
                XCTFail("期望missingOperator错误")
            }
        }
    }
    
    /// 测试骰子数量限制
    func testDiceCountLimit() {
        XCTAssertThrowsError(try diceParser.evaluateExpression("101d6")) { error in
            XCTAssertTrue(error is DiceParserError)
            if case DiceParserError.diceCountExceeded = error {
                // 正确错误类型
            } else {
                XCTFail("期望diceCountExceeded错误")
            }
        }
    }
    
    /// 测试表达式解析
    func testExpressionParsing() throws {
        // 测试解析功能
        let tokens1 = try diceParser.parseExpression("2d6 + d8")
        XCTAssertEqual(tokens1, ["2d6", "+", "d8"])
        
        let tokens2 = try diceParser.parseExpression("Adv(d20) + 2")
        XCTAssertEqual(tokens2, ["Adv(d20)", "+", "2"])
        
        let tokens3 = try diceParser.parseExpression("(d6 + 3) * 2")
        XCTAssertEqual(tokens3, ["(", "d6", "+", "3", ")", "*", "2"])
    }
    
    /// 测试复杂表达式
    func testComplexExpression() throws {
        let result = try diceParser.evaluateExpression("(5 + 3) * 2")
        XCTAssertEqual(result["finalResult"] as? Double, 16.0)
        XCTAssertEqual(result["steps"] as? String, "( 5 + 3 ) * 2")
    }
    
    /// 测试标准骰子运算
    func testStandardDiceOperation() throws {
        // 由于涉及随机数，我们测试解析和基本结构
        let result = try diceParser.evaluateExpression("2d6")
        XCTAssertNotNil(result["rolls"])
        XCTAssertNotNil(result["steps"])
        XCTAssertNotNil(result["finalResult"])
        
        let rolls = result["rolls"] as? [[String: Any]]
        XCTAssertEqual(rolls?.count, 2)
    }
    
    /// 测试优势劣势骰子
    func testAdvantageDisadvantage() throws {
        // 测试优势骰子
        let result1 = try diceParser.evaluateExpression("Adv(d20)")
        XCTAssertNotNil(result1["rolls"])
        
        let rolls1 = result1["rolls"] as? [[String: Any]]
        XCTAssertEqual(rolls1?.count, 1)
        XCTAssertEqual(rolls1?.first?["type"] as? String, "Adv(d20)")
        
        // 测试劣势骰子
        let result2 = try diceParser.evaluateExpression("Dis(d6)")
        XCTAssertNotNil(result2["rolls"])
        
        let rolls2 = result2["rolls"] as? [[String: Any]]
        XCTAssertEqual(rolls2?.count, 1)
        XCTAssertEqual(rolls2?.first?["type"] as? String, "Dis(d6)")
    }
    
    /// 测试d100骰子
    func testD100Dice() throws {
        let result = try diceParser.evaluateExpression("d100")
        XCTAssertNotNil(result["rolls"])
        
        let rolls = result["rolls"] as? [[String: Any]]
        XCTAssertEqual(rolls?.count, 1)
        XCTAssertEqual(rolls?.first?["type"] as? String, "d100")
        XCTAssertNotNil(rolls?.first?["tens"])
        XCTAssertNotNil(rolls?.first?["units"])
    }
    
    /// 测试混合表达式
    func testMixedExpression() throws {
        let result = try diceParser.evaluateExpression("Adv(d20) + Dis(d6)")
        XCTAssertNotNil(result["rolls"])
        XCTAssertEqual((result["rolls"] as? [[String: Any]])?.count, 2)
    }
    
    /// 测试错误处理
    func testErrorHandling() {
        // 测试各种错误情况
        let testCases = [
            ("", DiceParserError.emptyExpression),
            ("2d0", DiceParserError.invalidDiceFaces),
            ("abc", DiceParserError.invalidCharacter("a")),
            ("2d6 3d8", DiceParserError.missingOperator),
            ("101d6", DiceParserError.diceCountExceeded),
            ("d6++d8", DiceParserError.invalidOperatorCombination)
        ]
        
        for (expression, expectedError) in testCases {
            XCTAssertThrowsError(try diceParser.evaluateExpression(expression)) { error in
                XCTAssertTrue(error is DiceParserError)
            }
        }
    }
}

/// 扩展String，添加正则表达式匹配功能
extension String {
    func matches(for regex: String) -> [NSTextCheckingResult] {
        guard let regex = try? NSRegularExpression(pattern: regex) else { return [] }
        let matches = regex.matches(in: self, range: NSRange(startIndex..., in: self))
        return matches
    }
}

/// 测试运行器
class TestRunner {
    static func runTests() {
        let testSuite = DiceParserTests()
        
        // 运行所有测试方法
        let testMethods = [
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
        
        print("开始运行骰子解析器测试...")
        
        for testMethod in testMethods {
            do {
                try testMethod()
                print("✅ \(testMethod) 通过")
            } catch {
                print("❌ \(testMethod) 失败: \(error)")
            }
        }
        
        print("测试完成")
    }
}

// 如果需要独立运行测试，取消下面的注释
// TestRunner.runTests()