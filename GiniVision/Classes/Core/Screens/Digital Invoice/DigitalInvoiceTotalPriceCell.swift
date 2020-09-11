//
//  DigitalInvoiceTotalPriceCell.swift
//  GiniVision
//
//  Created by Maciej Trybilo on 11.12.19.
//

import Foundation

class DigitalInvoiceTotalPriceCell: UITableViewCell {
    
    var giniConfiguration = GiniConfiguration.shared
    
    private var totalPriceLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setup()
    }
    
    var totalPrice: Price? {
        didSet {
            
            guard let totalPrice = totalPrice else { return }
            
            guard let totalPriceString = totalPrice.string else { return }
            
            let attributedString =
                NSMutableAttributedString(string: totalPriceString,
                                          attributes: [NSAttributedString.Key.foregroundColor: giniConfiguration.digitalInvoiceTotalPriceColor,
                                                       NSAttributedString.Key.font: giniConfiguration.digitalInvoiceTotalPriceMainUnitFont])
            
            attributedString.setAttributes([NSAttributedString.Key.foregroundColor: giniConfiguration.digitalInvoiceTotalPriceColor,
                                            NSAttributedString.Key.baselineOffset: 9,
                                            NSAttributedString.Key.font: giniConfiguration.digitalInvoiceTotalPriceFractionalUnitFont],
                                           range: NSRange(location: totalPriceString.count - 3, length: 3))
            
            totalPriceLabel.attributedText = attributedString
            
            let format = DigitalInvoiceStrings.totalAccessibilityLabel.localizedFormat
            totalPriceLabel.accessibilityLabel = String.localizedStringWithFormat(format,
                                                                                  totalPriceString)
        }
    }
    
    private func setup() {
        
        selectionStyle = .none
        
        totalPriceLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(totalPriceLabel)
        
        totalPriceLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16).isActive = true
        totalPriceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
        totalPriceLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }
}
