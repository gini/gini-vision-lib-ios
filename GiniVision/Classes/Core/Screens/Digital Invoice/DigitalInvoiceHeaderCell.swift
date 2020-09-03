//
//  DigitalInvoiceHeaderView.swift
//  GiniVision
//
//  Created by Maciej Trybilo on 20.11.19.
//

import UIKit

class DigitalInvoiceHeaderCell: UITableViewCell {
    
    private var secondaryMessageLabel: UILabel?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setup()
    }
    
    var giniConfiguration: GiniConfiguration? {
        didSet {
            secondaryMessageLabel?.textColor = GiniConfiguration.shared.digitalInvoiceSecondaryMessageTextColor
        }
    }
    
    private func setup() {
        
        selectionStyle = .none
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        
        let messageLabel = UILabel()
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        let messageAttributedString = NSMutableAttributedString(string: .localized(resource: DigitalInvoiceStrings.headerMessagePrimary))
        
        messageAttributedString.addAttribute(NSAttributedString.Key.paragraphStyle,
                                             value: paragraphStyle,
                                             range: NSRange(location: 0, length: messageAttributedString.length))
        
        messageLabel.attributedText = messageAttributedString
        
        messageLabel.numberOfLines = 0
        messageLabel.font = giniConfiguration?.customFont.regular ?? GiniConfiguration.shared.customFont.regular
        messageLabel.textAlignment = .center
        
        let secondaryMessageAttributedString =
            NSMutableAttributedString(string: .localized(resource: DigitalInvoiceStrings.headerMessageSecondary))

        secondaryMessageAttributedString.addAttribute(NSAttributedString.Key.paragraphStyle,
                                      value: paragraphStyle,
                                      range: NSRange(location: 0, length: secondaryMessageAttributedString.length))
        
        let secondaryMessageLabel = UILabel()
        secondaryMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        secondaryMessageLabel.attributedText = secondaryMessageAttributedString
        secondaryMessageLabel.numberOfLines = 0
        secondaryMessageLabel.font = giniConfiguration?.digitalInvoiceSecondaryMessageTextFont ??
            GiniConfiguration.shared.digitalInvoiceSecondaryMessageTextFont
        secondaryMessageLabel.textColor = giniConfiguration?.digitalInvoiceSecondaryMessageTextColor ??
            GiniConfiguration.shared.digitalInvoiceSecondaryMessageTextColor
        secondaryMessageLabel.textAlignment = .center
        
        self.secondaryMessageLabel = secondaryMessageLabel
        
        let spacerView = UIView()
        spacerView.translatesAutoresizingMaskIntoConstraints = false
        spacerView.heightAnchor.constraint(equalToConstant: 15).isActive = true
        spacerView.backgroundColor = .clear
        
        let imageView = UIImageView(image: UIImage(named: "invoiceIllustration",
                                                   in: Bundle(for: GiniVision.self),
                                                   compatibleWith: nil))
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.heightAnchor.constraint(equalToConstant: 153).isActive = true
        imageView.contentMode = .scaleAspectFit
        
        let spacerView1 = UIView()
        spacerView1.translatesAutoresizingMaskIntoConstraints = false
        spacerView1.heightAnchor.constraint(equalToConstant: 15).isActive = true
        spacerView1.backgroundColor = .clear
        
        let stackView = UIStackView(arrangedSubviews: [messageLabel,
                                                       secondaryMessageLabel,
                                                       spacerView,
                                                       imageView,
                                                       spacerView1])
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 5
        
        contentView.addSubview(stackView)
        
        stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 50).isActive = true
        stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).isActive = true
        stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -50).isActive = true
        stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8).isActive = true
    }
}
