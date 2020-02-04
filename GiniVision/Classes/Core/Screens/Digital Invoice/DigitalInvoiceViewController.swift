//
//  DigitalInvoiceViewController.swift
//  GiniVision
//
//  Created by Maciej Trybilo on 20.11.19.
//

import UIKit

class DigitalInvoiceViewController: UIViewController {

    var invoice: DigitalInvoice? {
        didSet {
            tableView.reloadData()
            payButton.setTitle(payButtonTitle(), for: .normal)
            payButton.accessibilityLabel = payButtonAccessibilityLabel()
        }
    }
    
    var giniConfiguration = GiniConfiguration.shared
    
    private let payButton = UIButton(type: .system)
    private let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("ginivision.digitalinvoice.screentitle",
                                  bundle: Bundle(for: GiniVision.self),
                                  comment: "digital invoice screen title")

        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(tableView)
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        
        tableView.register(DigitalInvoiceHeaderCell.self,
                           forCellReuseIdentifier: "DigitalInvoiceHeaderCell")
        
        tableView.register(DigitalInvoiceItemsCell.self,
                           forCellReuseIdentifier: "DigitalInvoiceItemsCell")
        
        tableView.register(TextFieldTableViewCell.self,
                           forCellReuseIdentifier: "TextFieldTableViewCell")
        
        tableView.register(UINib(nibName: "DigitalLineItemTableViewCell",
                                 bundle: Bundle(for: GiniVision.self)),
                           forCellReuseIdentifier: "DigitalLineItemTableViewCell")
        
        tableView.register(DigitalInvoiceTotalPriceCell.self,
                           forCellReuseIdentifier: "DigitalInvoiceTotalPriceCell")
        
        tableView.register(DigitalInvoiceFooterCell.self,
                           forCellReuseIdentifier: "DigitalInvoiceFooterCell")
        
        tableView.separatorStyle = .none
        
        payButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(payButton)
        let payButtonHeight: CGFloat = 48
        let margin: CGFloat = 16
        payButton.heightAnchor.constraint(equalToConstant: payButtonHeight).isActive = true
        payButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin).isActive = true
        payButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin).isActive = true
        
        if #available(iOS 11.0, *) {
            payButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                              constant: -margin).isActive = true
        } else {
            payButton.bottomAnchor.constraint(equalTo: view.bottomAnchor,
                                              constant: -margin).isActive = true
        }
        
        payButton.layer.cornerRadius = 7
        payButton.backgroundColor = giniConfiguration.payButtonBackgroundColor
        payButton.setTitleColor(giniConfiguration.payButtonTitleTextColor, for: .normal)
        payButton.titleLabel?.font = giniConfiguration.payButtonTitleFont
        
        payButton.setTitle(payButtonTitle(), for: .normal)
        payButton.accessibilityLabel = payButtonAccessibilityLabel()
        
        payButton.layer.shadowColor = UIColor.black.cgColor
        payButton.layer.shadowRadius = 4
        payButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        payButton.layer.shadowOpacity = 0.15
        
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: payButtonHeight + margin * 2, right: 0)
    }
    
    private func payButtonTitle() -> String {
        
        guard let invoice = invoice else {
            return NSLocalizedString("ginivision.digitalinvoice.paybuttontitle.noinvoice",
                                     bundle: Bundle(for: GiniVision.self),
                                     comment: "digital invoice pay button title when the invoice is missing")
        }
                
        return String.localizedStringWithFormat(NSLocalizedStringPreferredFormat("ginivision.digitalinvoice.paybuttontitle",
                                                                                 comment: "digital invoice pay button title"),
                                                invoice.numSelected,
                                                invoice.numTotal)
    }
    
    private func payButtonAccessibilityLabel() -> String {
        
        guard let invoice = invoice else {
            return NSLocalizedString("ginivision.digitalinvoice.paybuttontitle.noinvoice",
                                     bundle: Bundle(for: GiniVision.self),
                                     comment: "digital invoice pay button title when the invoice is missing")
        }
        
        return String.localizedStringWithFormat(NSLocalizedStringPreferredFormat("ginivision.digitalinvoice.paybuttontitle.accessibilitylabel",
                                                                                 comment: "digital invoice pay button accessibility label"),
                                                invoice.numSelected,
                                                invoice.numTotal)
    }
}

extension DigitalInvoiceViewController: UITableViewDelegate, UITableViewDataSource {

    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    enum Section: Int, CaseIterable {
        case header
        case itemsHeader
        case lineItems
        case totalPrice
        case footer
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        switch Section(rawValue: section) {
        case .header: return 1
        case .itemsHeader: return 1
        case .lineItems: return invoice?.lineItems.count ?? 0
        case .totalPrice: return 1
        case .footer: return 1
        default: fatalError()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch Section(rawValue: indexPath.section) {
        case .header:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "DigitalInvoiceHeaderCell",
                                                     for: indexPath) as! DigitalInvoiceHeaderCell
            
            cell.giniConfiguration = giniConfiguration
            
            return cell
            
        case .itemsHeader:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "DigitalInvoiceItemsCell",
                                                     for: indexPath) as! DigitalInvoiceItemsCell
            
            cell.giniConfiguration = giniConfiguration
            cell.delegate = self
            
            if let invoice = invoice {
                cell.viewModel = DigitalInvoiceItemsCellViewModel(invoice: invoice)
            }
            
            return cell
            
        case .lineItems:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "DigitalLineItemTableViewCell",
                                                     for: indexPath) as! DigitalLineItemTableViewCell
            
            cell.viewModel = DigitalLineItemViewModel(lineItem: invoice!.lineItems[indexPath.row],
                                                      giniConfiguration: GiniConfiguration.shared,
                                                      index: indexPath.row)
            
            cell.delegate = self
            
            return cell
            
        case .totalPrice:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "DigitalInvoiceTotalPriceCell",
                                                     for: indexPath) as! DigitalInvoiceTotalPriceCell
            
            cell.totalPrice = invoice?.total
            
            return cell
            
        case .footer:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "DigitalInvoiceFooterCell",
                                                     for: indexPath) as! DigitalInvoiceFooterCell
            
            cell.giniConfiguration = giniConfiguration
            
            return cell
            
        default: fatalError()
        }
    }
}

extension DigitalInvoiceViewController: DigitalLineItemTableViewCellDelegate {
    
    func checkboxButtonTapped(cell: DigitalLineItemTableViewCell, viewModel: DigitalLineItemViewModel) {
        
        guard let invoice = invoice else { return }
        
        switch invoice.lineItems[viewModel.index].selectedState {
        
        case .selected:
            
            presentReturnReasonActionSheet(for: viewModel.index,
                                           source: cell.checkboxButton)
            
        case .deselected:
            self.invoice?.lineItems[viewModel.index].selectedState = .selected
        }
    }
        
    func editTapped(cell: DigitalLineItemTableViewCell, viewModel: DigitalLineItemViewModel) {
                
        let viewController = LineItemDetailsViewController()
        viewController.lineItem = invoice?.lineItems[viewModel.index]
        viewController.lineItemIndex = viewModel.index
        viewController.delegate = self
        
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension DigitalInvoiceViewController {
    
    private func presentReturnReasonActionSheet(for index: Int, source: UIView) {
        
        DeselectLineItemActionSheet().present(from: self, source: source) { selectedState in
            
            switch selectedState {
            case .selected:
                break
            case .deselected(let reason):
                self.invoice?.lineItems[index].selectedState = .deselected(reason: reason)
            }
        }
    }
}

extension DigitalInvoiceViewController: DigitalInvoiceItemsCellDelegate {
    
    func whatIsThisTapped(source: UIButton) {
        
        let actionSheet = UIAlertController(title: NSLocalizedString("ginivision.digitalinvoice.whatisthisactionsheet.title",
                                                                     bundle: Bundle(for: GiniVision.self),
                                                                     comment: ""),
                                            message: NSLocalizedString("ginivision.digitalinvoice.whatisthisactionsheet.message",
                                                                       bundle: Bundle(for: GiniVision.self),
                                                                       comment: ""),
                                            preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("ginivision.digitalinvoice.whatisthisactionsheet.action.helpful",
                                                                     bundle: Bundle(for: GiniVision.self),
                                                                     comment: ""),
                                            style: .default,
                                            handler: { _ in
                                                // TODO:
        }))
        
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("ginivision.digitalinvoice.whatisthisactionsheet.action.nothelpful",
                                                                     bundle: Bundle(for: GiniVision.self),
                                                                     comment: ""),
                                            style: .destructive,
                                            handler: { _ in
                                                // TODO:
        }))
        
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("ginivision.digitalinvoice.whatisthisactionsheet.action.cancel",
                                                                     bundle: Bundle(for: GiniVision.self),
                                                                     comment: ""),
                                            style: .cancel,
                                            handler: nil))
        
        actionSheet.popoverPresentationController?.sourceView = source
        
        present(actionSheet, animated: true, completion: nil)
    }
}

extension DigitalInvoiceViewController: LineItemDetailsViewControllerDelegate {
    
    func didSaveLineItem(lineItemDetailsViewController: LineItemDetailsViewController,
                         lineItem: DigitalInvoice.LineItem,
                         index: Int) {
        
        navigationController?.popViewController(animated: true)
        invoice?.lineItems[index] = lineItem
    }
}
