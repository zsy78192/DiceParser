import Foundation

/// 表达式计算功能扩展
public extension DiceParser {
    
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
                evalExpr += try processStandardDice(token)
                steps += "[\(getRollValues(for: token).map(String.init).joined(separator: "+"))]"
                
            } else if token.hasPrefix("Adv(") || token.hasPrefix("Dis(") {
                // 优势/劣势骰子
                let (value, rollDetails) = try processAdvDisDice(token)
                evalExpr += String(value)
                steps += rollDetails
                
            } else if let number = Int(token) {
                // 纯数字
                evalExpr += String(number)
                steps += String(number)
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
                let isCurrentDiceOrNumber = token.contains("d") || token.contains("Adv") || token.contains("Dis") || Int(token) != nil
                let isNextOperator = ["+", "-", "*", "/", "(", ")"].contains(nextToken)
                let isCurrentOperator = ["+", "-", "*", "/", "(", ")"].contains(token)
                let isNextDiceOrNumber = nextToken.contains("d") || nextToken.contains("Adv") || nextToken.contains("Dis") || Int(nextToken) != nil
                
                // 总是在运算符前后添加空格，除了括号
                if ["+", "-", "*", "/"].contains(token) || ["+", "-", "*", "/"].contains(nextToken) {
                    evalExpr += " "
                    steps += " "
                } else if (isCurrentDiceOrNumber && isNextOperator) ||
                          (isCurrentOperator && isNextDiceOrNumber) {
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
                "value": roll.value
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
            "finalResult": finalResult
        ]
    }
    
    /// 处理标准骰子表达式
    private func processStandardDice(_ token: String) throws -> String {
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
                let result = DiceRollResult(type: "d100", value: roll.value,
                                           tens: roll.tens, units: roll.units, rolls: [])
                rolls.append(result)
                rollValues.append(roll.value)
            }
        } else {
            // 标准骰子
            for _ in 0..<count {
                let value = rollDie(faces: faces)
                let result = DiceRollResult(type: "d\(faces)", value: value,
                                           tens: nil, units: nil, rolls: [])
                rolls.append(result)
                rollValues.append(value)
            }
        }
        
        return String(rollValues.reduce(0, +))
    }
    
    /// 获取骰子投掷值（用于步骤显示）
    private func getRollValues(for token: String) -> [Int] {
        let parts = token.components(separatedBy: "d")
        let countStr = parts[0].isEmpty ? "1" : parts[0]
        let facesStr = parts[1]
        
        guard let count = Int(countStr), let faces = Int(facesStr) else {
            return []
        }
        
        var rollValues: [Int] = []
        if faces == 100 {
            for _ in 0..<count {
                let roll = rollD100()
                rollValues.append(roll.value)
            }
        } else {
            for _ in 0..<count {
                rollValues.append(rollDie(faces: faces))
            }
        }
        
        return rollValues
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
        let result = DiceRollResult(type: "\(mode)(\(diceStr))", value: roll.value,
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
        
        // 使用NSExpression计算
        let expression = NSExpression(format: cleanExpr)
        guard let result = expression.expressionValue(with: nil, context: nil) as? NSNumber else {
            throw DiceParserError.invalidExpression
        }
        return result.doubleValue
    }
}