//
//  SCCModelFabric.swift
//  StripeTestApp
//
//  Created by Serhii on 28.11.2022.
//

import Foundation

struct SCCModelFabric {
    
    private static let decimalSeparator: String = NumberFormatter().decimalSeparator
    private static let numbers = "0123456789"
    private static var numbersWithDecimalSeparator: String {
        return numbers + decimalSeparator
    }
    
    // MARK: Public functions
    static func amountWithOnlyTwoDigitsAfterDot() -> ShouldChangeCharacterModel {
        let shouldChangeFormatter = ShouldChangeCharacterModel  { (textInTextField, string, range) in
            //handle remove
            if string.isEmpty && range.length > .zero { return true }
            
            //check if user print only number
            let isAllNumbersAndDecimalSeparator = containOnly(text: string,
                                                              stringComponents: numbersWithDecimalSeparator)
            
            //check decimal separator is inputed and it count and if yes check mantissa length
            let isCorrectDecimalPart = containLessOrOneDigitsSeparator(text: textInTextField,
                                                                       newText: string,
                                                                       range: range,
                                                                       mantissaLength: 2)
            
            return isAllNumbersAndDecimalSeparator && isCorrectDecimalPart
        }
        
        return shouldChangeFormatter
    }
    
    // MARK: Private functions
    private static func containOnly(text: String, stringComponents: String) -> Bool {
        let aSet = NSCharacterSet(charactersIn: stringComponents).inverted
        let compSepByCharInSet = text.components(separatedBy: aSet)
        let numberFiltered = compSepByCharInSet.joined(separator: .init())
        return text == numberFiltered
    }
    
    private static func containLessOrOneDigitsSeparator(text: String, newText: String, range: NSRange, mantissaLength: Int? = nil) -> Bool {
        let separator = Character(decimalSeparator)
        var futureString = text
        let insertAtIndex = futureString.index(futureString.startIndex, offsetBy: range.location)
        futureString.insert(contentsOf: newText, at: insertAtIndex)
        let countOfSeparator = futureString.filter { $0 == separator }.count
        guard let mantissaLength = mantissaLength else { return countOfSeparator <= 1 }

        switch countOfSeparator {
        case 0:
            return true
        case 1:
            guard let indexOfSeparator = futureString.firstIndex(of: separator) else { return false }
            var mantissa = futureString.suffix(from: indexOfSeparator)
            mantissa.removeFirst() // NOTE: drop separator
            return mantissa.count <= mantissaLength
        default:
            return false
        }
    }
}
