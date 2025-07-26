import Foundation

/// 表达式计算功能扩展
extension DiceParser {

    /// 计算骰子表达式
    /// - Parameter expr: 要计算的表达式字符串
    /// - Returns: 包含投掷结果、步骤和最终值的字典
    /// - Throws: 计算错误
    public func evaluateExpression(_ expr: String) throws -> [String: Any] {
        reset()

        let tokens: [String]
        do {
            tokens = try parseExpression(expr)
        } catch {
            throw error
        }

        guard !tokens.isEmpty else {
            throw DiceParserError.emptyExpression
        }

        var evalExpr = ""
        var steps = ""

        for i in 0..<tokens.count {
            let token = tokens[i]

            // 检查标准骰子表达式
            if token.contains("d") && !token.contains("Adv") && !token.contains("Dis") {
                let (value, rollValues) = try processStandardDice(token)
                evalExpr += value
                steps += "[\(rollValues.map(String.init).joined(separator: "+"))]"

            } else if token.hasPrefix("Adv(") || token.hasPrefix("Dis(") {
                // 优势/劣势骰子
                let (value, rollDetails) = try processAdvDisDice(token)
                evalExpr += String(value)
                steps += rollDetails

            } else if let number = Int(token) {
                // 纯数字
                evalExpr += String(number)
                steps += String(number)
            } else if let number = Double(token) {
                // 浮点数
                evalExpr += String(number)
                steps += token  // 保持原格式显示
            } else {
                // 运算符
                if !["+", "-", "*", "/", "(", ")"].contains(token) {
                    throw DiceParserError.invalidCharacter(token)
                }
                evalExpr += token
                steps += token
            }

            // 添加空格以提高可读性
            if i < tokens.count - 1 {
                let nextToken = tokens[i + 1]
                let isCurrentDiceOrNumber =
                    token.contains("d") || token.contains("Adv") || token.contains("Dis")
                    || Int(token) != nil || Double(token) != nil
                let isNextOperator = ["+", "-", "*", "/", "(", ")"].contains(nextToken)
                let isCurrentOperator = ["+", "-", "*", "/", "(", ")"].contains(token)
                let isNextDiceOrNumber =
                    nextToken.contains("d") || nextToken.contains("Adv")
                    || nextToken.contains("Dis") || Int(nextToken) != nil
                    || Double(nextToken) != nil

                // 总是在运算符前后添加空格，除了括号
                if ["+", "-", "*", "/"].contains(token) || ["+", "-", "*", "/"].contains(nextToken)
                {
                    evalExpr += " "
                    steps += " "
                } else if (isCurrentDiceOrNumber && isNextOperator)
                    || (isCurrentOperator && isNextDiceOrNumber)
                {
                    evalExpr += " "
                    steps += " "
                }
            }
        }

        // 验证构建的表达式是否有效
        guard !evalExpr.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw DiceParserError.emptyExpression
        }

        let cleanExpr = evalExpr.trimmingCharacters(in: .whitespacesAndNewlines)

        // 安全地计算数学表达式
        let finalResult = try calculateExpression(cleanExpr)

        // 转换结果为字典
        let rollDicts = rolls.map { roll in
            var dict: [String: Any] = [
                "type": roll.type,
                "value": roll.value,
            ]
            if let tens = roll.tens {
                dict["tens"] = tens
            }
            if let units = roll.units {
                dict["units"] = units
            }
            if !roll.rolls.isEmpty {
                dict["rolls"] = roll.rolls
            }
            return dict
        }

        return [
            "rolls": rollDicts,
            "steps": steps.trimmingCharacters(in: .whitespacesAndNewlines),
            "finalResult": finalResult,
        ]
    }

    /// 处理标准骰子表达式
    private func processStandardDice(_ token: String) throws -> (value: String, rollValues: [Int]) {
        let parts = token.components(separatedBy: "d")
        let countStr = parts[0].isEmpty ? "1" : parts[0]
        let facesStr = parts[1]

        guard let count = Int(countStr), let faces = Int(facesStr) else {
            throw DiceParserError.invalidExpression
        }

        if count > 100 {
            throw DiceParserError.diceCountExceeded
        }
        if faces < 1 || faces > 1000 {
            throw DiceParserError.invalidDiceFaces
        }

        var rollValues: [Int] = []

        if faces == 100 {
            // d100特殊处理
            for _ in 0..<count {
                let roll = rollD100()
                let result = DiceRollResult(
                    type: "d100", value: roll.value,
                    tens: roll.tens, units: roll.units, rolls: [])
                rolls.append(result)
                rollValues.append(roll.value)
            }
        } else {
            // 标准骰子
            for _ in 0..<count {
                let value = rollDie(faces: faces)
                let result = DiceRollResult(
                    type: "d\(faces)", value: value,
                    tens: nil, units: nil, rolls: [])
                rolls.append(result)
                rollValues.append(value)
            }
        }

        let totalValue = rollValues.reduce(0, +)
        return (String(totalValue), rollValues)
    }

    /// 处理优势/劣势骰子
    private func processAdvDisDice(_ token: String) throws -> (value: String, details: String) {
        let mode = token.hasPrefix("Adv") ? "Adv" : "Dis"
        let startIndex = token.index(token.startIndex, offsetBy: mode.count + 1)
        let endIndex = token.index(token.endIndex, offsetBy: -1)
        let diceStr = String(token[startIndex..<endIndex])

        guard diceStr.hasPrefix("d"), let faces = Int(String(diceStr.dropFirst())) else {
            throw DiceParserError.invalidExpression
        }

        if faces < 1 || faces > 1000 {
            throw DiceParserError.invalidDiceFaces
        }

        let roll = rollAdvDis(mode: mode, faces: faces)
        let result = DiceRollResult(
            type: "\(mode)(\(diceStr))", value: roll.value,
            tens: nil, units: nil, rolls: roll.rolls)
        rolls.append(result)

        let details = "[\(roll.rolls.map(String.init).joined(separator: ","))→\(roll.value)]"
        return (String(roll.value), details)
    }

    /// 安全计算数学表达式
    /// - Parameter expression: 数学表达式字符串
    /// - Returns: 计算结果
    /// - Throws: 计算错误
    private func calculateExpression(_ expression: String) throws -> Double {
        // 清理和验证表达式
        let cleanExpr = expression.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanExpr.isEmpty else {
            throw DiceParserError.emptyExpression
        }

        // 检查表达式是否有效（不能只有运算符）
        let numberPattern = "\\d+"
        let hasNumbers = cleanExpr.range(of: numberPattern, options: .regularExpression) != nil
        guard hasNumbers else {
            throw DiceParserError.invalidExpression
        }

        // 验证表达式格式
        try validateMathExpression(cleanExpr)

        // 预处理表达式以确保浮点数除法
        let processedExpr = preprocessForFloatingPointDivision(cleanExpr)

        // 使用NSExpression计算，添加异常捕获
        do {
            let expression = NSExpression(format: processedExpr)
            let object: Any? = nil
            let context: NSMutableDictionary? = nil
            guard
                let result = expression.expressionValue(with: object, context: context) as? NSNumber
            else {
                throw DiceParserError.mathExpressionError("无法计算表达式结果")
            }

            let doubleValue = result.doubleValue

            // 检查结果是否有效
            guard doubleValue.isFinite else {
                throw DiceParserError.mathExpressionError("计算结果无效（无穷大或NaN）")
            }

            // 检查除零导致的无穷大
            if doubleValue.isInfinite {
                throw DiceParserError.mathExpressionError("除零错误")
            }

            return doubleValue
        } catch let error as DiceParserError {
            throw error
        } catch {
            // 捕获NSExpression抛出的异常
            let errorMessage = error.localizedDescription
            if errorMessage.contains("Unable to parse") {
                throw DiceParserError.mathExpressionError("表达式格式错误")
            } else if errorMessage.contains("division by zero") {
                throw DiceParserError.mathExpressionError("除零错误")
            } else {
                throw DiceParserError.mathExpressionError("计算错误：\(errorMessage)")
            }
        }
    }

    /// 验证数学表达式格式
    /// - Parameter expression: 表达式字符串
    /// - Throws: 如果表达式格式无效则抛出错误
    private func validateMathExpression(_ expression: String) throws {
        // 检查是否包含无效字符
        let validPattern = "^[0-9+\\-*/().\\s]+$"
        guard expression.range(of: validPattern, options: .regularExpression) != nil else {
            throw DiceParserError.invalidExpression
        }

        // 检查除零
        let divisionPattern = "/\\s*0(?![0-9])"
        if expression.range(of: divisionPattern, options: .regularExpression) != nil {
            throw DiceParserError.mathExpressionError("除零错误")
        }

        // 检查运算符使用
        let operators = ["+", "-", "*", "/"]
        for op in operators {
            // 检查连续运算符
            if expression.contains("\(op)\(op)") {
                throw DiceParserError.invalidOperatorCombination
            }

            // 检查表达式开头或结尾是否有运算符（除了负号）
            if expression.hasPrefix(op) && op != "-" {
                throw DiceParserError.invalidExpression
            }
            if expression.hasSuffix(op) {
                throw DiceParserError.invalidExpression
            }
        }

        // 检查括号
        var stack = 0
        for char in expression {
            if char == "(" {
                stack += 1
            } else if char == ")" {
                stack -= 1
                if stack < 0 {
                    throw DiceParserError.unmatchedParentheses
                }
            }
        }
        if stack != 0 {
            throw DiceParserError.unmatchedParentheses
        }

        // 检查空括号
        if expression.contains("()") {
            throw DiceParserError.invalidExpression
        }
    }

    /// 预处理表达式以确保浮点数除法
    /// - Parameter expression: 原始表达式
    /// - Returns: 预处理后的表达式
    private func preprocessForFloatingPointDivision(_ expression: String) -> String {
        // 如果表达式已经包含小数点，则不需要预处理
        if expression.contains(".") {
            return expression
        }

        // 将整数转换为浮点数以确保浮点除法
        // 例如：7/2 -> 7.0/2.0
        var result = expression

        // 使用正则表达式找到所有整数并添加.0
        let integerPattern = "\\b(\\d+)\\b"
        result = result.replacingOccurrences(
            of: integerPattern,
            with: "$1.0",
            options: .regularExpression
        )

        return result
    }
}
