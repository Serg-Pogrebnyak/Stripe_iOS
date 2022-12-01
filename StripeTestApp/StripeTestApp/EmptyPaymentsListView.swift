//
//  EmptyPaymentsListView.swift
//  StripeTestApp
//
//  Created by Serhii on 01.12.2022.
//

import UIKit

final class EmptyPaymentsListView: UIView {
    
    // MARK: Outlets
    @IBOutlet private var contentView: UIView!
    @IBOutlet private weak var emptyListImageView: UIImageView!
    @IBOutlet private weak var emptyListLabel: UILabel!
    
    // MARK: Initializer
    // MARK: Initializer
    convenience init() {
        self.init(frame: .zero)
    }
    
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
        Bundle.main.loadNibNamed(Self.className, owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        emptyListImageView.image = R.image.noPaymentsIcon()
        emptyListLabel.text = R.string.localizable.noPaymentsViewDescription()
    }
}

