//
//  DigitalLineItemTableViewCell.swift
//  GiniVision
//
//  Created by Maciej Trybilo on 22.11.19.
//

import Foundation

struct DigitalLineItemViewModel {
    
    var lineItem: DigitalInvoice.LineItem
    let giniConfiguration: GiniConfiguration
    
    let index: Int
    
    var name: String? {
        return lineItem.name
    }
    
    var quantityOrReturnReasonString: String {
        
        switch lineItem.selectedState {
        case .selected:
            return "Quantity: \(lineItem.quantity)"
        case .deselected(let reason):
            return reason.displayString
        }
    }
    
    var quantityOrReturnReasonFont: UIFont {
        
        return giniConfiguration.digitalInvoiceLineItemQuantityOrReturnReasonFont
    }
    
    var priceMainUnitString: String {
        
        return Price(valueInFractionalUnit: lineItem.price * lineItem.quantity).mainUnitComponentString
    }
    
    var priceFractionalUnitString: String {
        
        return Price(valueInFractionalUnit: lineItem.price * lineItem.quantity).fractionalUnitComponentString
    }
    
    var checkboxBackgroundColor: UIColor {
        
        switch lineItem.selectedState {
        case .selected:
            return giniConfiguration.lineItemTintColor
        case .deselected:
            return .white
        }
    }
    
    var editButtonTintColor: UIColor {
        switch lineItem.selectedState {
        case .selected:
            return giniConfiguration.lineItemTintColor
        case .deselected:
            if #available(iOS 13.0, *) {
                return .secondaryLabel
            } else {
                return .gray
            }
        }
    }
    
    var primaryTextColor: UIColor {
        switch lineItem.selectedState {
        case .selected:
            if #available(iOS 13.0, *) {
                return .label
            } else {
                return .black
            }
        case .deselected:
            if #available(iOS 13.0, *) {
                return .secondaryLabel
            } else {
                return .gray
            }
        }
    }
    
    var priceMainUnitFont: UIFont {
        return giniConfiguration.digitalInvoiceLineItemPriceMainUnitFont
    }
    
    var priceFractionalUnitFont: UIFont {
        return giniConfiguration.digitalInvoiceLineItemPriceFractionalUnitFont
    }
    
    var nameLabelFont: UIFont {
        return giniConfiguration.digitalInvoiceLineItemNameFont
    }
    
    var editButtonTitleFont: UIFont {
        return giniConfiguration.digitalInvoiceLineItemEditButtonTitleFont
    }
    
    var cellShadowColor: UIColor {
        switch lineItem.selectedState {
        case .selected:
            return .black
        case .deselected:
            return .clear
        }
    }
    
    var cellBorderColor: UIColor {
        switch lineItem.selectedState {
        case .selected:
            return giniConfiguration.lineItemTintColor
        case .deselected:
            if #available(iOS 13.0, *) {
                return .secondaryLabel
            } else {
                return .gray
            }
        }
    }
}

protocol DigitalLineItemTableViewCellDelegate: class {
    
    func checkButtonTapped(viewModel: DigitalLineItemViewModel)
    func editTapped(viewModel: DigitalLineItemViewModel)
}

class DigitalLineItemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var shadowCastView: UIView!
    
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var quantityOrReturnReasonLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var priceMainUnitLabel: UILabel!
    @IBOutlet weak var priceFractionalUnitLabel: UILabel!
    
    var viewModel: DigitalLineItemViewModel? {
        didSet {
            
            nameLabel.text = viewModel?.name
            quantityOrReturnReasonLabel.text = viewModel?.quantityOrReturnReasonString
            quantityOrReturnReasonLabel.font = viewModel?.quantityOrReturnReasonFont
            priceMainUnitLabel.text = viewModel?.priceMainUnitString
            priceFractionalUnitLabel.text = viewModel?.priceFractionalUnitString
            checkButton.backgroundColor = viewModel?.checkboxBackgroundColor
            checkButton.layer.borderColor = viewModel?.cellBorderColor.cgColor
            
            editButton.setTitleColor(viewModel?.editButtonTintColor ?? .black, for: .normal)
            editButton.titleLabel?.font = viewModel?.editButtonTitleFont
            editButton.tintColor = viewModel?.editButtonTintColor ?? .black
            
            nameLabel.textColor = viewModel?.primaryTextColor
            priceMainUnitLabel.textColor = viewModel?.primaryTextColor
            priceMainUnitLabel.font = viewModel?.priceMainUnitFont
            priceFractionalUnitLabel.textColor = viewModel?.primaryTextColor
            priceFractionalUnitLabel.font = viewModel?.priceFractionalUnitFont

            nameLabel.font = viewModel?.nameLabelFont
            
            shadowCastView.layer.shadowColor = viewModel?.cellShadowColor.cgColor
            shadowCastView.layer.borderColor = viewModel?.cellBorderColor.cgColor
            
            setup()
        }
    }
    
    weak var delegate: DigitalLineItemTableViewCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setup()
    }
    
    private func setup() {
                
        shadowCastView.layer.cornerRadius = 7
        shadowCastView.layer.shadowRadius = 5
        shadowCastView.layer.shadowOpacity = 0.15
        shadowCastView.layer.shadowOffset = .zero
        
        shadowCastView.layer.borderWidth = 0.5
        
        selectionStyle = .none
        
        checkButton.layer.cornerRadius = 3
        checkButton.layer.borderWidth = 1
    }
    
    @IBAction func checkButtonTapped(_ sender: Any) {
        
        if let viewModel = viewModel {
            delegate?.checkButtonTapped(viewModel: viewModel)
        }
    }
    
    @IBAction func editButtonTapped(_ sender: Any) {
        
        if let viewModel = viewModel {
            delegate?.editTapped(viewModel: viewModel)
        }
    }
}
