//
//  ShouldChangeCharacterModel.swift
//  StripeTestApp
//
//  Created by Serhii on 28.11.2022.
//

import Foundation

struct ShouldChangeCharacterModel {
    let check: (_ textInTextField: String, _ newText: String, _ range: NSRange) -> Bool
}
