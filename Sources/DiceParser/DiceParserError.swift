import Foundation

/// 骰子解析器错误枚举
enum DiceParserError: Error, LocalizedError {
    case emptyExpression
    case invalidOperatorCombination
    case invalidDiceFaces
    case invalidCharacter(String)
    case missingOperator
    case diceCountExceeded
    case invalidExpression
    
    var errorDescription: String? {
        switch self {
        case .emptyExpression:
            return "请输入表达式"
        case .invalidOperatorCombination:
            return "无效运算符组合"
        case .invalidDiceFaces:
            return "骰子面数需为1-1000"
        case .invalidCharacter(let char):
            return "无效字符：\(char)"
        case .missingOperator:
            return "请检查表达式格式（如 2d6 + d8）"
        case .diceCountExceeded:
            return "骰子数量不能超过100"
        case .invalidExpression:
            return "无效表达式"
        }
    }
}