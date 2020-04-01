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
    
    var quantityString: String? {
        
        switch lineItem.selectedState {
        case .selected:
            return String.localizedStringWithFormat(NSLocalizedStringPreferredFormat("ginivision.digitalinvoice.lineitem.quantity",
                                                                                     comment: ""),
                                                    lineItem.quantity)
        case .deselected:
            return nil
        }
    }
    
    var quantityOrReturnReasonFont: UIFont {
        
        return giniConfiguration.digitalInvoiceLineItemQuantityOrReturnReasonFont
    }
    
    var totalPriceString: String? {
        return lineItem.totalPrice.string
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
    
    func checkboxButtonTapped(cell: DigitalLineItemTableViewCell, viewModel: DigitalLineItemViewModel)
    func editTapped(cell: DigitalLineItemTableViewCell, viewModel: DigitalLineItemViewModel)
}

class DigitalLineItemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var shadowCastView: UIView!
    
    @IBOutlet weak var checkboxButton: CheckboxButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var quantityOrReturnReasonLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var priceLabel: UILabel!
    
    var viewModel: DigitalLineItemViewModel? {
        didSet {
            
            nameLabel.text = viewModel?.name
            quantityOrReturnReasonLabel.text = viewModel?.quantityString
            quantityOrReturnReasonLabel.font = viewModel?.quantityOrReturnReasonFont
            
            if let viewModel = viewModel, let priceString = viewModel.totalPriceString {
                
                let attributedString =
                    NSMutableAttributedString(string: priceString,
                                              attributes: [NSAttributedString.Key.foregroundColor: viewModel.primaryTextColor,
                                                           NSAttributedString.Key.font: viewModel.priceMainUnitFont])
                
                attributedString.setAttributes([NSAttributedString.Key.foregroundColor: viewModel.primaryTextColor,
                                                NSAttributedString.Key.baselineOffset: 6,
                                                NSAttributedString.Key.font: viewModel.priceFractionalUnitFont],
                                               range: NSRange(location: priceString.count - 3, length: 3))
                
                priceLabel.attributedText = attributedString
                let format = NSLocalizedStringPreferredFormat("ginivision.digitalinvoice.total.accessibilitylabel",
                                                              comment: "")
                priceLabel.accessibilityLabel = String.localizedStringWithFormat(format, priceString)
            }
            
            checkboxButton.tintColor = viewModel?.checkboxTintColor
            
            editButton.setTitleColor(viewModel?.editButtonTintColor ?? .black, for: .normal)
            editButton.titleLabel?.font = viewModel?.editButtonTitleFont
            editButton.tintColor = viewModel?.editButtonTintColor ?? .black
            
            editButton.setTitle(NSLocalizedString("ginivision.digitalinvoice.lineitem.editbutton",
                                                  bundle: Bundle(for: GiniVision.self),
                                                  comment: ""), for: .normal)
            
            nameLabel.textColor = viewModel?.primaryTextColor

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
    }
    
    @IBAction func checkButtonTapped(_ sender: Any) {
        
        if let viewModel = viewModel {
            delegate?.checkboxButtonTapped(cell: self, viewModel: viewModel)
        }
    }
    
    @IBAction func editButtonTapped(_ sender: Any) {
        
        if let viewModel = viewModel {
            delegate?.editTapped(cell: self, viewModel: viewModel)
        }
    }
}
