//
//  DigitalInvoiceTotalPriceCell.swift
//  GiniVision
//
//  Created by Maciej Trybilo on 11.12.19.
//

import Foundation

class DigitalInvoiceTotalPriceCell: UITableViewCell {
    
    var giniConfiguration = GiniConfiguration.shared
    
    private var totalPriceMainUnitLabel: UILabel?
    private var totalPriceFractionalUnitLabel: UILabel?
    
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
                        
            totalPriceMainUnitLabel?.text = totalPrice.mainUnitComponentString
            totalPriceFractionalUnitLabel?.text = totalPrice.fractionalUnitComponentString
        }
    }
    
    private func setup() {
        
        selectionStyle = .none
        
        let totalPriceMainUnitLabel = UILabel()
        totalPriceMainUnitLabel.translatesAutoresizingMaskIntoConstraints = false
        totalPriceMainUnitLabel.font = giniConfiguration.digitalInvoiceTotalPriceMainUnitFont
        
        self.totalPriceMainUnitLabel = totalPriceMainUnitLabel
        
        let totalPriceFractionalUnitLabel = UILabel()
        totalPriceFractionalUnitLabel.translatesAutoresizingMaskIntoConstraints = false
        totalPriceFractionalUnitLabel.font = giniConfiguration.digitalInvoiceTotalPriceFractionalUnitFont
        
        self.totalPriceFractionalUnitLabel = totalPriceFractionalUnitLabel
        
        contentView.addSubview(totalPriceMainUnitLabel)
        contentView.addSubview(totalPriceFractionalUnitLabel)
        
        totalPriceFractionalUnitLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                       constant: -16).isActive = true
        totalPriceFractionalUnitLabel.topAnchor.constraint(equalTo: totalPriceMainUnitLabel.topAnchor,
                                                           constant: 3).isActive = true
        
        totalPriceMainUnitLabel.trailingAnchor.constraint(equalTo: totalPriceFractionalUnitLabel.leadingAnchor,
                                                      constant: 0).isActive = true
        totalPriceMainUnitLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        totalPriceMainUnitLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }
}
