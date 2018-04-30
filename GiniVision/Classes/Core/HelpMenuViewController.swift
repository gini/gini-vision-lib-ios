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
 use the _Open with_ feature and which formats are supported by the Gini Vision Library.
 
 **Text resources for this screen**
 
 * `ginivision.navigationbar.help.backToCamera`
 * `ginivision.navigationbar.help.backToMenu`

 - note: Setting `ginivision.navigationbar.help.backToCamera` and `ginivision.navigationbar.help.backToMenu`
 explicitly to the empty string in your localized strings will make `HelpMenuViewController`
 revert to the default iOS back button.
 
 **Image resources for this screen**
 
 * `navigationReviewBack`
 * `arrowBack`
 
 */

final public class HelpMenuViewController: UITableViewController {
    
    let giniConfiguration: GiniConfiguration
    let tableRowHeight: CGFloat = 64
    var helpMenuCellIdentifier = "helpMenuCellIdentifier"
    lazy var items: [(text: String, id: Int)] = {
        var items = [
            (NSLocalizedString("ginivision.helpmenu.firstItem",
                               bundle: Bundle(for: GiniVision.self),
                               comment: "help menu first item text"), 1),
            (NSLocalizedString("ginivision.helpmenu.thirdItem",
                               bundle: Bundle(for: GiniVision.self),
                               comment: "help menu third item text"), 3)
        ]
        
        if self.giniConfiguration.openWithEnabled {
            items.insert((NSLocalizedString("ginivision.helpmenu.secondItem",
                                            bundle: Bundle(for: GiniVision.self),
                                            comment: "help menu second item text"), 2), at: 1)
        }
        
        return items
    }()
    
    // Button resources
    fileprivate lazy var backToCameraButtonResource =
        PreferredButtonResource(image: "navigationReviewBack",
                                title: "ginivision.navigationbar.review.back",
                                comment: "Button title in the navigation bar for the " +
                                         "back button on the help menu screen",
                                configEntry: self.giniConfiguration.navigationBarHelpMenuTitleBackToCameraButton)
    
    fileprivate lazy var backToMenuButtonResource =
        PreferredButtonResource(image: "arrowBack",
                                title: "ginivision.navigationbar.review.back",
                                comment: "Button title in the navigation bar for the back button on the help screen",
                                configEntry: self.giniConfiguration.navigationBarHelpScreenTitleBackToMenuButton)
    
    public init(giniConfiguration: GiniConfiguration) {
        self.giniConfiguration = giniConfiguration
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(giniConfiguration:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("ginivision.helpmenu.title",
                                  bundle: Bundle(for: GiniVision.self),
                                  comment: "help menu view controller title")
        tableView.tableFooterView = UIView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: helpMenuCellIdentifier)
        tableView.rowHeight = tableRowHeight
        tableView.backgroundColor = Colors.Gini.pearl
        
        // In iOS it is .automatic by default, having an initial animation when the view is loaded.
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
        setupNavigationItem(usingResources: backToCameraButtonResource,
                            selector: #selector(back),
                            position: .left,
                            target: self)
    }
    
    @objc func back() {
        navigationController?.popViewController(animated: true)
    }
    
    func viewController(forRowWithId id: Int) -> UIViewController? {
        let viewController: UIViewController
        switch id {
        case 1:
            let title = NSLocalizedString("ginivision.noresults.title",
                                          bundle: Bundle(for: GiniVision.self),
                                          comment: "navigation title shown on no results tips, " +
                "when the screen is shown through the help menu")
            let topViewText = NSLocalizedString("ginivision.noresults.warningHelpMenu",
                                                bundle: Bundle(for: GiniVision.self),
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
            viewController = vc
        case 2:
            viewController = OpenWithTutorialViewController()
        case 3:
            viewController = SupportedFormatsViewController(style: .plain)
        default:
            return nil
        }
        
        viewController.setupNavigationItem(usingResources: backToMenuButtonResource,
                                           selector: #selector(back),
                                           position: .left,
                                           target: self)
        
        return viewController
    }
    
}

// MARK: - UITableViewDataSource

extension HelpMenuViewController {
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
    
}
