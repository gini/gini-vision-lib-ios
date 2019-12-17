//
//  DigitalInvoiceTotalPriceCell.swift
//  GiniVision
//
//  Created by Maciej Trybilo on 11.12.19.
//

import Foundation

class DigitalInvoiceTotalPriceCell: UITableViewCell {
    
    var giniConfiguration: GiniConfiguration?
    
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
    
    var totalPrice: Int? {
        didSet {
            
            guard let totalPrice = totalPrice else { return }
            
            let price = Price(valueInFractionalUnit: totalPrice)
            
            totalPriceMainUnitLabel?.text = price.mainUnitComponentString
            totalPriceFractionalUnitLabel?.text = price.fractionalUnitComponentString
        }
    }
    
    private func setup() {
        
        selectionStyle = .none
        
        let totalPriceMainUnitLabel = UILabel()
        totalPriceMainUnitLabel.translatesAutoresizingMaskIntoConstraints = false
        totalPriceMainUnitLabel.font = giniConfiguration?.digitalInvoiceTotalPriceMainUnitFont ??
            GiniConfiguration.shared.digitalInvoiceTotalPriceMainUnitFont
        
        self.totalPriceMainUnitLabel = totalPriceMainUnitLabel
        
        let totalPriceFractionalUnitLabel = UILabel()
        totalPriceFractionalUnitLabel.translatesAutoresizingMaskIntoConstraints = false
        totalPriceFractionalUnitLabel.font = giniConfiguration?.digitalInvoiceTotalPriceFractionalUnitFont ??
            GiniConfiguration.shared.digitalInvoiceTotalPriceFractionalUnitFont
        
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
