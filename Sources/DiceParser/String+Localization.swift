import Foundation

// MARK: - Bundle Extension for Package Resources
extension Bundle {
    static var diceParser: Bundle {
        // For Swift Package Manager, we need to find the correct bundle
        #if SWIFT_PACKAGE
            return Bundle.module
        #else
            // For traditional projects, find the bundle containing the DiceParserError class
            let candidateBundle = Bundle(for: DiceParserError.self)
            if candidateBundle.path(forResource: "Localizable", ofType: "xcstrings") != nil {
                return candidateBundle
            }
            return Bundle.main
        #endif
    }
}

// MARK: - String Localization Extensions
extension String {
    /// Returns a localized string from the Localizable.xcstrings file
    func localized(comment: String = "") -> String {
        let bundle = Bundle.diceParser
        let localizedString = NSLocalizedString(
            self, tableName: "Localizable", bundle: bundle, comment: comment)

        // If localization failed (key returned as-is), return a fallback
        if localizedString == self {
            // Return English fallback if available
            return getEnglishFallback() ?? self
        }
        return localizedString
    }

    /// Returns a localized string with format arguments
    func localized(with arguments: CVarArg..., comment: String = "") -> String {
        let localizedString = self.localized(comment: comment)
        return String(format: localizedString, arguments: arguments)
    }

    /// Get English fallback from xcstrings
    private func getEnglishFallback() -> String? {
        switch self {
        case "error.emptyExpression":
            return "Please enter an expression"
        case "error.invalidOperatorCombination":
            return "Invalid operator combination"
        case "error.invalidDiceFaces":
            return "Dice faces must be between 1-1000"
        case "error.invalidCharacter":
            return "Invalid character: %@"
        case "error.missingOperator":
            return "Please check expression format (e.g. 2d6 + d8)"
        case "error.diceCountExceeded":
            return "Number of dice cannot exceed 100"
        case "error.invalidExpression":
            return "Invalid expression"
        case "error.unmatchedParentheses":
            return "Unmatched parentheses"
        case "error.mathExpressionError":
            return "Math expression error: %@"
        default:
            return nil
        }
    }
}
