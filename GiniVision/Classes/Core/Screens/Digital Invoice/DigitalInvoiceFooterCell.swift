//
//  DigitalInvoiceFooterCell.swift
//  GiniVision
//
//  Created by Maciej Trybilo on 11.12.19.
//

import UIKit

class DigitalInvoiceFooterCell: UITableViewCell {
    
    var giniConfiguration: GiniConfiguration?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setup()
    }
    
    private func setup() {
        
        selectionStyle = .none
        backgroundColor = UIColor.from(giniColor: giniConfiguration?.digitalInvoiceBackgroundColor ?? GiniConfiguration.shared.digitalInvoiceBackgroundColor)
        let messageLabel = UILabel()
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.text = .localized(resource: DigitalInvoiceStrings.footerMessage)
        messageLabel.numberOfLines = 0
        messageLabel.font = giniConfiguration?.digitalInvoiceFooterMessageTextFont ??
            GiniConfiguration.shared.digitalInvoiceFooterMessageTextFont
        
        if #available(iOS 13.0, *) {
            messageLabel.textColor = .secondaryLabel
        } else {
            messageLabel.textColor = .gray
        }
        messageLabel.textAlignment = .center
        
        contentView.addSubview(messageLabel)
        
        messageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40).isActive = true
        messageLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 35).isActive = true
        messageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40).isActive = true
        messageLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30).isActive = true
    }
}
