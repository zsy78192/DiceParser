import XCTest

@testable import DiceParser

final class LocalizationTests: XCTestCase {

    func testErrorLocalization() {
        // Test that error messages can be localized
        let error = DiceParserError.emptyExpression
        let description = error.errorDescription

        XCTAssertNotNil(description)
        XCTAssertFalse(description!.isEmpty)

        // Test parameterized error
        let charError = DiceParserError.invalidCharacter("@")
        let charDescription = charError.errorDescription

        XCTAssertNotNil(charDescription)
        XCTAssertTrue(
            charDescription!.contains("@"),
            "Description should contain the invalid character: \(charDescription!)")
    }

    func testAllErrorCases() {
        // Ensure all error cases have descriptions
        let errors: [DiceParserError] = [
            .emptyExpression,
            .invalidOperatorCombination,
            .invalidDiceFaces,
            .invalidCharacter("x"),
            .missingOperator,
            .diceCountExceeded,
            .invalidExpression,
            .unmatchedParentheses,
            .mathExpressionError("test"),
        ]

        for error in errors {
            XCTAssertNotNil(
                error.errorDescription, "Error description should not be nil for \(error)")
            XCTAssertFalse(
                error.errorDescription!.isEmpty,
                "Error description should not be empty for \(error)")
        }
    }
}
