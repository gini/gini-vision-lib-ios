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
 */

final public class HelpMenuViewController: UITableViewController {
    
    let giniConfiguration: GiniConfiguration
    let tableRowHeight: CGFloat = 64
    var helpMenuCellIdentifier = "helpMenuCellIdentifier"
    
    enum Item {
        case noResultsTips
        case openWithTutorial
        case supportedFormats
        
        var title: String {
            switch self {
            case .noResultsTips:
                return .localized(resource: HelpStrings.menuFirstItemText)
            case .openWithTutorial:
                return .localized(resource: HelpStrings.menuSecondItemText)
            case .supportedFormats:
                return .localized(resource: HelpStrings.menuThirdItemText)
            }
        }
        
        var viewController: UIViewController {
            let viewController: UIViewController
            switch self {
            case .noResultsTips:
                let title: String = .localized(resource: ImageAnalysisNoResultsStrings.titleText)
                let topViewText: String = .localized(resource: ImageAnalysisNoResultsStrings.warningHelpMenuText)
                viewController = ImageAnalysisNoResultsViewController(title: title,
                                                                      subHeaderText: nil,
                                                                      topViewText: topViewText,
                                                                      topViewIcon: nil)
            case .openWithTutorial:
                viewController = OpenWithTutorialViewController()
            case .supportedFormats:
                viewController = SupportedFormatsViewController()
            }
            
            return viewController
            
        }
    }
    
    lazy var items: [Item] = {
        var items: [Item] = [ .noResultsTips]
        
        if giniConfiguration.shouldShowSupportedFormatsScreen {
            items.append(.supportedFormats)
        }
        
        if giniConfiguration.openWithEnabled {
            items.append(.openWithTutorial)
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
        title = .localized(resource: HelpStrings.menuTitle)
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
            let title: String = .localized(resource: ImageAnalysisNoResultsStrings.titleText)
            let topViewText: String = .localized(resource: ImageAnalysisNoResultsStrings.warningHelpMenuText)
            let vc = ImageAnalysisNoResultsViewController(title: title,
                                                          subHeaderText: nil,
                                                          topViewText: topViewText,
                                                          topViewIcon: nil)
            vc.didTapBottomButton = {
                if let cameraViewController = (self.navigationController?
                    .viewControllers
                    .compactMap { $0 as? CameraViewController })?
                    .first {
                    _ = self.navigationController?.popToViewController(cameraViewController, animated: true)
                }
            }
            viewController = vc
        case 2:
            viewController = OpenWithTutorialViewController()
        case 3:
            viewController = SupportedFormatsViewController()
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
        cell.textLabel?.text = items[indexPath.row].title
        cell.textLabel?.font = giniConfiguration.customFont.with(weight: .regular, size: 14, style: .body)
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = .white
        
        return cell
    }
    
    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        let viewController = item.viewController
        viewController.setupNavigationItem(usingResources: backToMenuButtonResource,
                                           selector: #selector(back),
                                           position: .left,
                                           target: self)
        
        if let imageNoResultsViewController = viewController as? ImageAnalysisNoResultsViewController {
            imageNoResultsViewController.didTapBottomButton = {
                if let cameraViewController = (self.navigationController?
                    .viewControllers
                    .compactMap { $0 as? CameraViewController })?
                    .first {
                    _ = self.navigationController?.popToViewController(cameraViewController, animated: true)
                }
            }
        }
        navigationController?.pushViewController(viewController, animated: true)
    }
    
}
