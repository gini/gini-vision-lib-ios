//
//  DigitalInvoiceItemsCell.swift
//  GiniVision
//
//  Created by Maciej Trybilo on 11.12.19.
//

import Foundation

protocol DigitalInvoiceItemsCellDelegate: class {
    
    func whatIsThisTapped()
}

struct DigitalInvoiceItemsCellViewModel {
    
    let itemsLabelText: String
    
    init(invoice: DigitalInvoice) {
        
        itemsLabelText = "Items \(invoice.numSelected)/\(invoice.numTotal)"
    }
}

class DigitalInvoiceItemsCell: UITableViewCell {
    
    weak var delegate: DigitalInvoiceItemsCellDelegate?
    var giniConfiguration: GiniConfiguration?
    
    private var itemsLabel: UILabel?
    
    var viewModel: DigitalInvoiceItemsCellViewModel? {
        didSet {
            itemsLabel?.text = viewModel?.itemsLabelText
        }
    }
    
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
        
        let itemsLabel = UILabel()
        itemsLabel.translatesAutoresizingMaskIntoConstraints = false
        itemsLabel.font = giniConfiguration?.digitalInvoiceItemsSectionHeaderTextFont ??
            GiniConfiguration.shared.digitalInvoiceItemsSectionHeaderTextFont
        
        self.itemsLabel = itemsLabel
        
        if #available(iOS 13.0, *) {
            itemsLabel.textColor = .secondaryLabel
        } else {
            itemsLabel.textColor = .gray
        }
        
        contentView.addSubview(itemsLabel)
        
        itemsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
        itemsLabel.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        itemsLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0).isActive = true
        
        let whatIsThisButton = UIButton(type: .system)
        whatIsThisButton.translatesAutoresizingMaskIntoConstraints = false
        whatIsThisButton.setTitle("What is this?", for: .normal)
        whatIsThisButton.titleLabel?.font = giniConfiguration?.digitalInvoiceItemsSectionHeaderTextFont ??
        GiniConfiguration.shared.digitalInvoiceItemsSectionHeaderTextFont
        
        let image = UIImage(named: "infoIcon",
                            in: Bundle(for: GiniVision.self),
                            compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        
        whatIsThisButton.setImage(image, for: .normal)
        
        whatIsThisButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        whatIsThisButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: -48, bottom: 0, right: 0)
        whatIsThisButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 73, bottom: 0, right: 0)
        
        if #available(iOS 13.0, *) {
            whatIsThisButton.setTitleColor(.secondaryLabel, for: .normal)
        } else {
            whatIsThisButton.setTitleColor(.gray, for: .normal)
        }
        
        whatIsThisButton.tintColor = giniConfiguration?.lineItemTintColor ??
            GiniConfiguration.shared.lineItemTintColor
                
        contentView.addSubview(whatIsThisButton)
        
        whatIsThisButton.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        whatIsThisButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
        whatIsThisButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        
        whatIsThisButton.addTarget(self, action: #selector(whatIsThisButtonTapped), for: .touchUpInside)
    }
    
    @objc func whatIsThisButtonTapped() {
        delegate?.whatIsThisTapped()
    }
}
