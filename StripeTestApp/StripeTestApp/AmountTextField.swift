//
//  AmountTextField.swift
//  StripeTestApp
//
//  Created by Serhii on 28.11.2022.
//

import UIKit

final class AmountTextField: UITextField {
    
    // MARK: Variables
    override var delegate: UITextFieldDelegate? {
        get { _delegate }
        set { _delegate = newValue }
    }
    
    var digitsAfterDot = 2
    var isValid: Bool { shouldChangeCharacterModel.check(text ?? .init(), .init(), .init()) }
    
    private var _delegate: UITextFieldDelegate?
    private var shouldChangeCharacterModel: ShouldChangeCharacterModel {
        SCCModelFabric.amount(withCountDigitsAfterDot: digitsAfterDot)
    }
    
    // MARK: Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    // MARK: - Private functions
    private func commonInit() {
        super.delegate = self
    }
}

// MARK: - General UITextFieldDelegate
extension AmountTextField: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        _delegate?.textFieldShouldBeginEditing?(self) ?? true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        _delegate?.textFieldDidBeginEditing?(self)
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        _delegate?.textFieldShouldEndEditing?(self) ?? true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        _delegate?.textFieldDidEndEditing?(self)
    }

    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        _delegate?.textFieldDidEndEditing?(self, reason: reason)
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let shouldChange = shouldChangeCharacterModel.check(textField.text ?? .init(), string, range)
        return delegate?.textField?(self, shouldChangeCharactersIn: range, replacementString: string) ?? shouldChange
    }

    func textFieldDidChangeSelection(_ textField: UITextField) {
        _delegate?.textFieldDidChangeSelection?(self)
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        _delegate?.textFieldShouldClear?(self) ?? true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        _delegate?.textFieldShouldReturn?(self) ?? true
    }
}
