import Foundation

/// 骰子解析器错误枚举
public enum DiceParserError: Error, LocalizedError {
    case emptyExpression
    case invalidOperatorCombination
    case invalidDiceFaces
    case invalidCharacter(String)
    case missingOperator
    case diceCountExceeded
    case invalidExpression
    case unmatchedParentheses
    case mathExpressionError(String)

    public var errorDescription: String? {
        switch self {
        case .emptyExpression:
            return "error.emptyExpression".localized()
        case .invalidOperatorCombination:
            return "error.invalidOperatorCombination".localized()
        case .invalidDiceFaces:
            return "error.invalidDiceFaces".localized()
        case .invalidCharacter(let char):
            return "error.invalidCharacter".localized(with: char)
        case .missingOperator:
            return "error.missingOperator".localized()
        case .diceCountExceeded:
            return "error.diceCountExceeded".localized()
        case .invalidExpression:
            return "error.invalidExpression".localized()
        case .unmatchedParentheses:
            return "error.unmatchedParentheses".localized()
        case .mathExpressionError(let details):
            return "error.mathExpressionError".localized(with: details)
        }
    }
}
