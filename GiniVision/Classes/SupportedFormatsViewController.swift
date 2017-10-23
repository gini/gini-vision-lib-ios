//
//  SupportedTypesViewController.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 10/19/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import UIKit

final class SupportedFormatsViewController: UITableViewController {
    
    typealias SupportedFormatCollectionSection = (title: String, items: [String], itemsImage:UIImage?, itemsImageBackgroundColor: UIColor)
    
    let supportedFormatsCellIdentifier = "SupportedFormatsCellIdentifier"
    let rowHeight: CGFloat = 70
    let sectionHeight: CGFloat = 70
    var sections: [SupportedFormatCollectionSection] = [
        (NSLocalizedString("ginivision.supportedFormats.section.1.title", bundle: Bundle(for: GiniVision.self), comment: "title for supported formats section"),
         [NSLocalizedString("ginivision.supportedFormats.section.1.item.1", bundle: Bundle(for: GiniVision.self), comment: "message for first item on supported formats section"),
          NSLocalizedString("ginivision.supportedFormats.section.1.item.2", bundle: Bundle(for: GiniVision.self), comment: "message for second item on supported formats section"),
          NSLocalizedString("ginivision.supportedFormats.section.1.item.3", bundle: Bundle(for: GiniVision.self), comment: "message for third item on supported formats section")],
         UIImage(named: "supportedFormatsIcon", in: Bundle(for: GiniVision.self), compatibleWith: nil),
         GiniConfiguration.sharedConfiguration.supportedFormatsIconColor),
        (NSLocalizedString("ginivision.supportedFormats.section.2.title", bundle: Bundle(for: GiniVision.self), comment: "title for unsupported formats section"),
         [NSLocalizedString("ginivision.supportedFormats.section.2.item.1", bundle: Bundle(for: GiniVision.self), comment: "message for first item on unsupported formats section"),
          NSLocalizedString("ginivision.supportedFormats.section.2.item.2", bundle: Bundle(for: GiniVision.self), comment: "message for second item on unsupported formats section")],
         UIImage(named: "nonSupportedFormatsIcon", in: Bundle(for: GiniVision.self), compatibleWith: nil),
         GiniConfiguration.sharedConfiguration.nonSupportedFormatsIconColor)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("ginivision.supportedFormats.title", bundle: Bundle(for: GiniVision.self), comment: "supported and unsupported formats screen title")
        tableView.register(SupportedFormatsTableViewCell.self, forCellReuseIdentifier: supportedFormatsCellIdentifier)
        tableView.rowHeight = rowHeight
        tableView.tableFooterView = UIView()
        tableView.sectionHeaderHeight = sectionHeight
        tableView.allowsSelection = false
        tableView.backgroundColor = Colors.Gini.pearl
        tableView.alwaysBounceVertical = false
        
        if #available(iOS 11.0, *) { // On iOS is .automatic by default and it the transition to this view controller looks weird.
            tableView.contentInsetAdjustmentBehavior = .never
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]
        let item = section.items[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: supportedFormatsCellIdentifier, for: indexPath) as! SupportedFormatsTableViewCell
        cell.textLabel?.text = item
        cell.imageView?.image = section.itemsImage
        cell.imageBackgroundView.backgroundColor = section.itemsImageBackgroundColor

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.backgroundView?.backgroundColor = nil
        }
    }

}
