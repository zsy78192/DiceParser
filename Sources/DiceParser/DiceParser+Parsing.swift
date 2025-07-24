import Foundation

/// 表达式解析功能扩展
public extension DiceParser {
    
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
        let pattern = "(\\d*d\\d+|Adv\\(d\\d+\\)|Dis\\(d\\d+\\)|[+\\-*/()]|\\d+)"
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            throw DiceParserError.invalidExpression
        }
        
        let matches = regex.matches(in: processedExpr, range: NSRange(processedExpr.startIndex..., in: processedExpr))
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
            let invalidPattern = "[^+\\-*/()\\dA-Za-z]"
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
        let validPattern = "^(\\d*d\\d+|Adv\\(d\\d+\\)|Dis\\(d\\d+\\)|[+\\-*/()]|\\d+)$"
        for token in tokens {
            if token.range(of: validPattern, options: .regularExpression) == nil {
                throw DiceParserError.invalidCharacter(token)
            }
        }
        
        // 检查是否缺少运算符
        for i in 0..<tokens.count-1 {
            let current = tokens[i]
            let next = tokens[i+1]
            
            let isCurrentOperand = current.range(of: "^\\d*d\\d+$", options: .regularExpression) != nil || 
                                 current.range(of: "^\\d+$", options: .regularExpression) != nil ||
                                 current.range(of: "^(Adv|Dis)\\(d\\d+\\)$", options: .regularExpression) != nil
            
            let isNextOperand = next.range(of: "^\\d*d\\d+$", options: .regularExpression) != nil || 
                               next.range(of: "^\\d+$", options: .regularExpression) != nil ||
                               next.range(of: "^(Adv|Dis)\\(d\\d+\\)$", options: .regularExpression) != nil
            
            if isCurrentOperand && isNextOperand {
                throw DiceParserError.missingOperator
            }
        }
        
        return tokens
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