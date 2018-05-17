//
//  HelpMenuViewController.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 10/18/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import UIKit

/**
 The `HelpMenuViewController` provides explanations on how to take better pictures, how to
 use the open with feature and which formats are supported by Gini Vision Library.
 
 */

final public class HelpMenuViewController: UITableViewController {
    
    let tableRowHeight: CGFloat = 64
    var helpMenuCellIdentifier = "helpMenuCellIdentifier"
    lazy var items: [(text: String, id: Int)] = {
        var items = [
            (NSLocalizedStringPreferred("ginivision.helpmenu.firstItem",
                               comment: "help menu first item text"), 1),
            (NSLocalizedStringPreferred("ginivision.helpmenu.thirdItem",
                               comment: "help menu third item text"), 3)
        ]
        
        if GiniConfiguration.sharedConfiguration.openWithEnabled {
            items.insert((NSLocalizedStringPreferred("ginivision.helpmenu.secondItem",
                                            comment: "help menu second item text"), 2), at: 1)
        }
        
        return items
    }()
    
    public init() {
        super.init(style: .plain)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(showOpenWithTutorial:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedStringPreferred("ginivision.helpmenu.title",
                                  comment: "help menu view controller title")
        tableView.tableFooterView = UIView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: helpMenuCellIdentifier)
        tableView.rowHeight = tableRowHeight
        tableView.backgroundColor = Colors.Gini.pearl
        
        // On iOS is .automatic by default and it the transition to this view controller looks weird.
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
    }
    
    // MARK: - Table view data source
    
    override public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: helpMenuCellIdentifier, for: indexPath)
        cell.textLabel?.text = items[indexPath.row].0
        cell.textLabel?.font = cell.textLabel?.font.withSize(14)
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = .white
        
        return cell
    }
    
    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let viewController = viewController(forRowWithId: items[indexPath.row].id) {
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    func viewController(forRowWithId id: Int) -> UIViewController? {
        switch id {
        case 1:
            let title = NSLocalizedStringPreferred("ginivision.noresults.title",
                                          comment: "navigation title shown on no results tips, " +
                                                   "when the screen is shown through the help menu")
            let topViewText = NSLocalizedStringPreferred("ginivision.noresults.warningHelpMenu",
                                                comment: "warning text shown on no results tips, " +
                                                         "when the screen is shown through the help menu")
            let vc = ImageAnalysisNoResultsViewController(title: title,
                                                          subHeaderText: nil,
                                                          topViewText: topViewText,
                                                          topViewIcon: nil)
            vc.didTapBottomButton = {
                if let cameraViewController = (self.navigationController?
                    .viewControllers
                    .flatMap { $0 as? CameraViewController })?
                    .first {
                    _ = self.navigationController?.popToViewController(cameraViewController, animated: true)
                }
            }
            return vc
        case 2:
            return OpenWithTutorialViewController()
        case 3:
            return SupportedFormatsViewController(style: .plain)
        default:
            return nil
        }
    }
    
}
