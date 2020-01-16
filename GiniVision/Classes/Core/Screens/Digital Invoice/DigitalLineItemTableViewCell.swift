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
            return String.localizedStringWithFormat(NSLocalizedStringPreferredFormat("ginivision.digitalinvoice.lineitem.quantity",
                                                                                     comment: ""),
                                                    lineItem.quantity)
        case .deselected(let reason):
            return reason.displayString
        }
    }
    
    var quantityOrReturnReasonFont: UIFont {
        
        return giniConfiguration.digitalInvoiceLineItemQuantityOrReturnReasonFont
    }
    
    var totalPriceMainUnitString: String {
        
        return lineItem.totalPrice.mainUnitComponentString
    }
    
    var totalPriceFractionalUnitString: String {
        
        return lineItem.totalPrice.fractionalUnitComponentString
    }
    
    var checkboxTintColor: UIColor {
        
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
    
    func checkboxButtonTapped(viewModel: DigitalLineItemViewModel)
    func editTapped(viewModel: DigitalLineItemViewModel)
}

class DigitalLineItemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var shadowCastView: UIView!
    
    @IBOutlet weak var checkboxButton: CheckboxButton!
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
            priceMainUnitLabel.text = viewModel?.totalPriceMainUnitString
            priceFractionalUnitLabel.text = viewModel?.totalPriceFractionalUnitString
            checkboxButton.tintColor = viewModel?.checkboxTintColor
            
            editButton.setTitleColor(viewModel?.editButtonTintColor ?? .black, for: .normal)
            editButton.titleLabel?.font = viewModel?.editButtonTitleFont
            editButton.tintColor = viewModel?.editButtonTintColor ?? .black
            
            editButton.setTitle(NSLocalizedString("ginivision.digitalinvoice.lineitem.editbutton",
                                                  bundle: Bundle(for: GiniVision.self),
                                                  comment: ""), for: .normal)
            
            nameLabel.textColor = viewModel?.primaryTextColor
            priceMainUnitLabel.textColor = viewModel?.primaryTextColor
            priceMainUnitLabel.font = viewModel?.priceMainUnitFont
            priceFractionalUnitLabel.textColor = viewModel?.primaryTextColor
            priceFractionalUnitLabel.font = viewModel?.priceFractionalUnitFont

            nameLabel.font = viewModel?.nameLabelFont
            
            shadowCastView.layer.shadowColor = viewModel?.cellShadowColor.cgColor
            shadowCastView.layer.borderColor = viewModel?.cellBorderColor.cgColor
            
            if let viewModel = viewModel {
                switch viewModel.lineItem.selectedState {
                case .selected:
                    checkboxButton.checkedState = .checked
                case .deselected:
                    checkboxButton.checkedState = .unchecked
                }
            }
            
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
        
        let nameLabelTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(nameLabelTapped(_:)))
        nameLabel.isUserInteractionEnabled = true
        nameLabel.addGestureRecognizer(nameLabelTapGestureRecognizer)
    }
    
    @IBAction func checkButtonTapped(_ sender: Any) {
        
        if let viewModel = viewModel {
            delegate?.checkboxButtonTapped(viewModel: viewModel)
        }
    }
    
    @objc func nameLabelTapped(_ sender: UITapGestureRecognizer) {
        
        if let viewModel = viewModel {
            delegate?.checkboxButtonTapped(viewModel: viewModel)
        }
    }
    
    @IBAction func editButtonTapped(_ sender: Any) {
        
        if let viewModel = viewModel {
            delegate?.editTapped(viewModel: viewModel)
        }
    }
}
