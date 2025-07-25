import Foundation

/// 表达式解析功能扩展
extension DiceParser {

    /// 解析骰子表达式
    /// - Parameter expression: 骰子表达式字符串
    /// - Returns: 令牌数组
    /// - Throws: 解析错误
    public func parseExpression(_ expression: String) throws -> [String] {
        guard !expression.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw DiceParserError.emptyExpression
        }

        let processedExpr = expression.replacingOccurrences(of: " ", with: "")

        // 检查连续运算符
        let operatorPattern = "[+\\-*/]{2,}"
        if processedExpr.range(of: operatorPattern, options: .regularExpression) != nil {
            throw DiceParserError.invalidOperatorCombination
        }

        // 使用正则表达式分割表达式
        let pattern = "(\\d*d\\d+|Adv\\(d\\d+\\)|Dis\\(d\\d+\\)|[+\\-*/()]|\\d+(?:\\.\\d+)?)"
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            throw DiceParserError.invalidExpression
        }

        let matches = regex.matches(
            in: processedExpr, range: NSRange(processedExpr.startIndex..., in: processedExpr))
        var tokens: [String] = []

        for match in matches {
            if let range = Range(match.range, in: processedExpr) {
                let token = String(processedExpr[range])
                tokens.append(token)
            }
        }

        // 检查是否所有字符都被正确解析
        let totalTokenLength = tokens.reduce(0) { $0 + $1.count }
        if totalTokenLength != processedExpr.count {
            // 找到第一个无效字符
            let invalidPattern = "[^+\\-*/()\\dA-Za-z.]"
            if let range = processedExpr.range(of: invalidPattern, options: .regularExpression) {
                let invalidChar = String(processedExpr[range])
                throw DiceParserError.invalidCharacter(invalidChar)
            }

            // 检查是否有未匹配的字母序列
            let letterPattern = "[A-Za-z]+"
            let letterMatches = processedExpr.matches(for: letterPattern)
            if !letterMatches.isEmpty {
                let firstMatch = letterMatches[0]
                if let range = Range(firstMatch.range, in: processedExpr) {
                    let invalidChar = String(processedExpr[range])
                    throw DiceParserError.invalidCharacter(invalidChar)
                }
            }

            throw DiceParserError.invalidExpression
        }

        // 检查纯字母字符串（如abc）
        for token in tokens {
            if token.range(of: "^[A-Za-z]+$", options: .regularExpression) != nil {
                throw DiceParserError.invalidCharacter(token)
            }
        }

        // 验证所有令牌
        for token in tokens {
            let isValid = token.range(of: "^\\d*d\\d+$", options: .regularExpression) != nil
                || token.range(of: "^\\d+(?:\\.\\d+)?$", options: .regularExpression) != nil
                || token.range(of: "^(Adv|Dis)\\(d\\d+\\)$", options: .regularExpression) != nil
                || token.range(of: "^[+\\-*/()]$", options: .regularExpression) != nil
            
            if !isValid {
                throw DiceParserError.invalidCharacter(token)
            }
        }

        // 检查是否缺少运算符
        for i in 0..<tokens.count - 1 {
            let current = tokens[i]
            let next = tokens[i + 1]

            let isCurrentOperand =
                current.range(of: "^\\d*d\\d+$", options: .regularExpression) != nil
                || current.range(of: "^\\d+(?:\\.\\d+)?$", options: .regularExpression) != nil
                || current.range(of: "^(Adv|Dis)\\(d\\d+\\)$", options: .regularExpression) != nil

            let isNextOperand =
                next.range(of: "^\\d*d\\d+$", options: .regularExpression) != nil
                || next.range(of: "^\\d+(?:\\.\\d+)?$", options: .regularExpression) != nil
                || next.range(of: "^(Adv|Dis)\\(d\\d+\\)$", options: .regularExpression) != nil

            if isCurrentOperand && isNextOperand {
                throw DiceParserError.missingOperator
            }
        }

                // 检查括号匹配
        try validateParentheses(tokens)
        
        // 处理隐含乘法（如 8(4) -> 8*(4)）
        tokens = try insertImplicitMultiplication(tokens)

        return tokens
    }

    /// 验证括号匹配
    /// - Parameter tokens: 令牌数组
    /// - Throws: 如果括号不匹配则抛出错误
    private func validateParentheses(_ tokens: [String]) throws {
        var stack = 0
        for token in tokens {
            if token == "(" {
                stack += 1
            } else if token == ")" {
                stack -= 1
                if stack < 0 {
                    throw DiceParserError.unmatchedParentheses
                }
            }
        }
        if stack != 0 {
            throw DiceParserError.unmatchedParentheses
        }
    }
    
    /// 处理隐含乘法
    /// - Parameter tokens: 原始令牌数组
    /// - Returns: 插入了隐含乘法的令牌数组
    /// - Throws: 如果处理过程中发现错误
    private func insertImplicitMultiplication(_ tokens: [String]) throws -> [String] {
        var result: [String] = []
        
        for i in 0..<tokens.count {
            let current = tokens[i]
            result.append(current)
            
            // 检查是否需要插入隐含乘法
            if i < tokens.count - 1 {
                let next = tokens[i + 1]
                
                // 情况1: 数字后跟左括号 (如 8()
                if isNumber(current) && next == "(" {
                    result.append("*")
                }
                // 情况2: 右括号后跟数字 (如 )8
                else if current == ")" && isNumber(next) {
                    result.append("*")
                }
                // 情况3: 右括号后跟左括号 (如 )(
                else if current == ")" && next == "(" {
                    result.append("*")
                }
                // 情况4: 数字后跟骰子表达式 (如 2d6
                else if isNumber(current) && isDiceExpression(next) {
                    result.append("*")
                }
                // 情况5: 骰子表达式后跟数字 (如 d62)
                else if isDiceExpression(current) && isNumber(next) {
                    result.append("*")
                }
                // 情况6: 骰子表达式后跟左括号 (如 d6()
                else if isDiceExpression(current) && next == "(" {
                    result.append("*")
                }
                // 情况7: 右括号后跟骰子表达式 (如 )d6
                else if current == ")" && isDiceExpression(next) {
                    result.append("*")
                }
                // 情况8: 数字后跟优势/劣势表达式 (如 2Adv(d20))
                else if isNumber(current) && (next.hasPrefix("Adv(") || next.hasPrefix("Dis(")) {
                    result.append("*")
                }
                // 情况9: 优势/劣势表达式后跟数字 (如 Adv(d20)2)
                else if (current.hasPrefix("Adv(") || current.hasPrefix("Dis(")) && isNumber(next) {
                    result.append("*")
                }
            }
        }
        
        return result
    }
    
    /// 检查字符串是否为数字
    private func isNumber(_ token: String) -> Bool {
        return token.range(of: "^\\d+(?:\\.\\d+)?$", options: .regularExpression) != nil
    }
    
    /// 检查字符串是否为骰子表达式
    private func isDiceExpression(_ token: String) -> Bool {
        return token.range(of: "^\\d*d\\d+$", options: .regularExpression) != nil
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
