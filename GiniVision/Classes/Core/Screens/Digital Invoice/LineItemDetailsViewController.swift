//
//  LineItemDetailsViewController.swift
//  GiniVision
//
//  Created by Maciej Trybilo on 18.12.19.
//

import UIKit

protocol LineItemDetailsViewControllerDelegate: class {
    
    func didSaveLineItem(lineItemDetailsViewController: LineItemDetailsViewController,
                         lineItem: DigitalInvoice.LineItem,
                         index: Int)
}

class LineItemDetailsViewController: UIViewController {

    var lineItem: DigitalInvoice.LineItem? {
        didSet {
            update()
        }
    }
    
    var lineItemIndex: Int?
    
    var giniConfiguration = GiniConfiguration.shared
    
    weak var delegate: LineItemDetailsViewControllerDelegate?
    
    private let stackView = UIStackView()

    private let checkboxContainerStackView = UIStackView()
    private let checkboxButton = CheckboxButton()
    private let checkboxButtonTextLabel = UILabel()

    private let itemNameTextField = GiniTextField()
    
    private let quantityAndItemPriceContainer = UIView()
    private let quantityTextField = GiniTextField()
    private let multiplicationLabel = UILabel()
    private let itemPriceTextField = GiniTextField()
    
    private let totalPriceStackView = UIStackView()
    private let totalPriceTitleLabel = UILabel()
    private let totalPriceLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: .localized(resource: DigitalInvoiceStrings.lineItemSaveButtonTitle),
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(saveButtonTapped))
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        checkboxContainerStackView.translatesAutoresizingMaskIntoConstraints = false
        checkboxButton.translatesAutoresizingMaskIntoConstraints = false
        checkboxButtonTextLabel.translatesAutoresizingMaskIntoConstraints = false
        itemNameTextField.translatesAutoresizingMaskIntoConstraints = false
        quantityAndItemPriceContainer.translatesAutoresizingMaskIntoConstraints = false
        quantityTextField.translatesAutoresizingMaskIntoConstraints = false
        multiplicationLabel.translatesAutoresizingMaskIntoConstraints = false
        itemPriceTextField.translatesAutoresizingMaskIntoConstraints = false
        totalPriceStackView.translatesAutoresizingMaskIntoConstraints = false
        totalPriceTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        totalPriceLabel.translatesAutoresizingMaskIntoConstraints = false
        
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
        } else {
            view.backgroundColor = .white
        }
        
        stackView.axis = .vertical
        stackView.spacing = 16
        
        checkboxContainerStackView.axis = .horizontal
        
        checkboxButton.tintColor = giniConfiguration.lineItemTintColor
        checkboxButton.checkedState = .checked
        checkboxButton.addTarget(self, action: #selector(checkboxButtonTapped), for: .touchUpInside)
        checkboxContainerStackView.addArrangedSubview(checkboxButton)
        
        checkboxButtonTextLabel.font = giniConfiguration.lineItemDetailsDescriptionLabelFont
        checkboxButtonTextLabel.textColor = giniConfiguration.lineItemDetailsDescriptionLabelColor
        checkboxContainerStackView.addArrangedSubview(checkboxButtonTextLabel)
        
        // This is outside of the main stackView in order to deal with the checkbox button being larger
        // than it appears (for accessibility reasons)
        view.addSubview(checkboxContainerStackView)
        
        let margin: CGFloat = 16
        
        if #available(iOS 11.0, *) {
            
            checkboxContainerStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                                                constant: margin - CheckboxButton.margin).isActive = true
            checkboxContainerStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                                            constant: margin - CheckboxButton.margin).isActive = true
            checkboxContainerStackView.trailingAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                                 constant: -margin).isActive = true
            
        } else {
            
            checkboxContainerStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                                constant: margin - CheckboxButton.margin).isActive = true
            checkboxContainerStackView.topAnchor.constraint(equalTo: view.topAnchor,
                                                            constant: margin - CheckboxButton.margin).isActive = true
            checkboxContainerStackView.trailingAnchor.constraint(greaterThanOrEqualTo: view.trailingAnchor,
                                                                 constant: -margin).isActive = true
        }
        
        view.addSubview(stackView)
        
        stackView.topAnchor.constraint(equalTo: checkboxContainerStackView.bottomAnchor,
                                       constant: margin - CheckboxButton.margin).isActive = true
        
        if #available(iOS 11.0, *) {
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                               constant: margin).isActive = true

            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                constant: -margin).isActive = true
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor,
                                              constant: -margin).isActive = true
        } else {
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                               constant: margin).isActive = true
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                constant: -margin).isActive = true
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor,
                                              constant: -margin).isActive = true
        }
        
        itemNameTextField.titleFont = giniConfiguration.lineItemDetailsDescriptionLabelFont
        itemNameTextField.titleTextColor = giniConfiguration.lineItemDetailsDescriptionLabelColor
        itemNameTextField.title = .localized(resource: DigitalInvoiceStrings.lineItemNameTextFieldTitle)
        itemNameTextField.textFont = giniConfiguration.lineItemDetailsContentLabelFont
        itemNameTextField.textColor = giniConfiguration.lineItemDetailsContentLabelColor
        itemNameTextField.prefixText = nil
        
        stackView.addArrangedSubview(itemNameTextField)
        
        quantityTextField.titleFont = giniConfiguration.lineItemDetailsDescriptionLabelFont
        quantityTextField.titleTextColor = giniConfiguration.lineItemDetailsDescriptionLabelColor
        quantityTextField.title = .localized(resource: DigitalInvoiceStrings.lineItemQuantityTextFieldTitle)
        quantityTextField.textFont = giniConfiguration.lineItemDetailsContentLabelFont
        quantityTextField.textColor = giniConfiguration.lineItemDetailsContentLabelColor
        quantityTextField.prefixText = nil
        quantityTextField.keyboardType = .numberPad
        quantityTextField.delegate = self
        quantityAndItemPriceContainer.addSubview(quantityTextField)
        
        multiplicationLabel.font = giniConfiguration.lineItemDetailsContentLabelFont
        multiplicationLabel.textColor = giniConfiguration.lineItemDetailsContentLabelColor
        multiplicationLabel.text = "X"
        quantityAndItemPriceContainer.addSubview(multiplicationLabel)
        
        itemPriceTextField.titleFont = giniConfiguration.lineItemDetailsDescriptionLabelFont
        itemPriceTextField.titleTextColor = giniConfiguration.lineItemDetailsDescriptionLabelColor
        itemPriceTextField.title = .localized(resource: DigitalInvoiceStrings.lineItemPriceTextFieldTitle)
        itemPriceTextField.textFont = giniConfiguration.lineItemDetailsContentLabelFont
        itemPriceTextField.textColor = giniConfiguration.lineItemDetailsContentLabelColor
        
        itemPriceTextField.keyboardType = .decimalPad
        itemPriceTextField.delegate = self
        quantityAndItemPriceContainer.addSubview(itemPriceTextField)
        
        quantityTextField.leadingAnchor.constraint(equalTo: quantityAndItemPriceContainer.leadingAnchor).isActive = true
        quantityTextField.topAnchor.constraint(equalTo: quantityAndItemPriceContainer.topAnchor).isActive = true
        quantityTextField.trailingAnchor.constraint(equalTo: multiplicationLabel.leadingAnchor,
                                                    constant: -margin).isActive = true
        quantityTextField.bottomAnchor.constraint(equalTo: quantityAndItemPriceContainer.bottomAnchor).isActive = true
        
        multiplicationLabel.centerXAnchor.constraint(equalTo: quantityAndItemPriceContainer.centerXAnchor)
            .isActive = true
        multiplicationLabel.firstBaselineAnchor.constraint(equalTo: quantityTextField.textFieldFirstBaselineAnchor)
            .isActive = true
        multiplicationLabel.trailingAnchor.constraint(equalTo: itemPriceTextField.leadingAnchor,
                                                      constant: -margin).isActive = true
        multiplicationLabel.setContentHuggingPriority(.required, for: .horizontal)
        multiplicationLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        multiplicationLabel.accessibilityLabel = .localized(resource: DigitalInvoiceStrings.lineItemMultiplicationAccessibilityLabel)
        
        itemPriceTextField.topAnchor.constraint(equalTo: quantityAndItemPriceContainer.topAnchor).isActive = true
        itemPriceTextField.trailingAnchor.constraint(equalTo: quantityAndItemPriceContainer.trailingAnchor)
            .isActive = true
        itemPriceTextField.bottomAnchor.constraint(equalTo: quantityAndItemPriceContainer.bottomAnchor).isActive = true
        
        stackView.addArrangedSubview(quantityAndItemPriceContainer)
        
        totalPriceStackView.axis = .horizontal
        totalPriceStackView.spacing = 16
        
        let dummyView = UIView()
        dummyView.translatesAutoresizingMaskIntoConstraints = false
        
        totalPriceStackView.addArrangedSubview(dummyView)
        
        totalPriceTitleLabel.setContentHuggingPriority(.required, for: .horizontal)
        totalPriceTitleLabel.font = giniConfiguration.lineItemDetailsDescriptionLabelFont
        totalPriceTitleLabel.textColor = giniConfiguration.lineItemDetailsDescriptionLabelColor
        totalPriceTitleLabel.text = .localized(resource: DigitalInvoiceStrings.lineItemTotalPriceTitle)
        totalPriceTitleLabel.font = UIFont.systemFont(ofSize: 12)
        
        totalPriceStackView.addArrangedSubview(totalPriceTitleLabel)
        
        totalPriceLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        totalPriceStackView.addArrangedSubview(totalPriceLabel)
        
        stackView.addArrangedSubview(totalPriceStackView)
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        view.addGestureRecognizer(gestureRecognizer)
     
        accessibilityElements = [checkboxContainerStackView,
                                 itemNameTextField,
                                 quantityTextField,
                                 multiplicationLabel,
                                 itemPriceTextField,
                                 totalPriceTitleLabel,
                                 totalPriceLabel]
        
        update()
    }
    
    @objc func saveButtonTapped() {
        
        if let index = lineItemIndex, let lineItem = lineItemFromFields() {
            
            delegate?.didSaveLineItem(lineItemDetailsViewController: self,
                                      lineItem: lineItem,
                                      index: index)
        }
    }
    
    @objc func checkboxButtonTapped() {
        
        guard let lineItem = lineItem else { return }
        
        switch lineItem.selectedState {
        case .deselected:
            self.lineItem?.selectedState = .selected
        case .selected:
            self.lineItem?.selectedState = .deselected
        }
    }
    
    @objc func backgroundTapped() {
        
        _ = itemNameTextField.resignFirstResponder()
        _ = quantityTextField.resignFirstResponder()
        _ = itemPriceTextField.resignFirstResponder()
    }
}

extension LineItemDetailsViewController {
    
    private func update() {
        
        guard isViewLoaded else { return }
        
        guard let lineItem = lineItem else { return }
        
        checkboxButtonTextLabel.text = String.localizedStringWithFormat(DigitalInvoiceStrings.lineItemCheckmarkLabel.localizedFormat,
                                                                        lineItem.quantity)
        
        itemNameTextField.text = lineItem.name
        quantityTextField.text = String(lineItem.quantity)
        itemPriceTextField.prefixText = lineItem.price.currencySymbol
        itemPriceTextField.text = lineItem.price.stringWithoutSymbol
        
        switch lineItem.selectedState {
        case .selected:
            checkboxButton.checkedState = .checked
        case .deselected:
            checkboxButton.checkedState = .unchecked
        }
        
        if let totalPriceString = lineItem.totalPrice.string {
            
            let attributedString =
                NSMutableAttributedString(string: totalPriceString,
                                          attributes: [NSAttributedString.Key.foregroundColor: giniConfiguration.lineItemDetailsContentLabelColor,
                                                       NSAttributedString.Key.font: giniConfiguration.lineItemDetailsTotalPriceMainUnitFont])
            
            attributedString.setAttributes([NSAttributedString.Key.foregroundColor: giniConfiguration.lineItemDetailsContentLabelColor,
                                            NSAttributedString.Key.baselineOffset: 5,
                                            NSAttributedString.Key.font: giniConfiguration.lineItemDetailsTotalPriceFractionalUnitFont],
                                           range: NSRange(location: totalPriceString.count - 3, length: 3))
            
            totalPriceLabel.attributedText = attributedString
        }
    }
}

extension LineItemDetailsViewController {
    
    private func lineItemFromFields() -> DigitalInvoice.LineItem? {
        
        guard var lineItem = lineItem else { return nil }
        guard let priceValue = Decimal(string: itemPriceTextField.text ?? "0") else { return nil }
        
        lineItem.name = itemNameTextField.text
        lineItem.quantity = Int(quantityTextField.text ?? "") ?? 0
        lineItem.price = Price(value: priceValue, currencyCode: lineItem.price.currencyCode)
        
        return lineItem
    }
}

extension LineItemDetailsViewController: GiniTextFieldDelegate {
    
    func textDidChange(_ giniTextField: GiniTextField) {
        
        lineItem = lineItemFromFields()
    }
}
