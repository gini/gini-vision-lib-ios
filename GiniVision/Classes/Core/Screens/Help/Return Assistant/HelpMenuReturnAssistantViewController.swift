//
//  HelpMenuReturnAssistantViewController.swift
//  GiniVision
//
//  Created by Nadya Karaban on 27.10.20.
//

import Foundation

final class HelpMenuReturnAssistantViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    struct Constants {
        static let storyboard = "HelpMenuReturnAssistant"
        static let viewControllerIdentifier = "helpMenuReturnAssistantViewController"
        static let helpReturnAssistantCellId = "helpReturnAssistantCellId"
        static let helpReturnAssistantCountCellId = "helpReturnAssistantCountCellId"
        static let helpReturnAssistantPriceCellId = "helpReturnAssistantPriceCellId"
    }

    enum CellType: Int, CaseIterable {
        case returnAssistant
        case changeQuantity
        case changePrice
    }
    
    fileprivate var pageTitle: String {
        return
            NSLocalizedStringPreferredFormat("ginivision.help.menu.returnAssistant.title", comment: "title for the help menu return assistant screen")
    }

    fileprivate var titleSection1: String {
        return
            NSLocalizedStringPreferredFormat("ginivision.help.menu.returnAssistant.section1.title", comment: "title for the first section on the help menu return assistant screen")
    }

    fileprivate var section1Body1: String {
        return
            NSLocalizedStringPreferredFormat("ginivision.help.menu.returnAssistant.section1.body1", comment: "first body text for the first section on the help menu return assistant screen")
    }

    fileprivate var section1Body2: String {
        return
            NSLocalizedStringPreferredFormat("ginivision.help.menu.returnAssistant.section1.body2", comment: "second body text for the first section on the help menu return assistant screen")
    }

    fileprivate var titleSection2: String {
        return
            NSLocalizedStringPreferredFormat("ginivision.help.menu.returnAssistant.section2.title", comment: "title for the second section on the help menu return assistant screen")
    }
    
    fileprivate var section1Image: UIImage {
        return UIImageNamedPreferred(named: "helpMenuReturnAssistantSection1Image") ?? UIImage()
    }

    fileprivate var section2Body: String {
        return
            NSLocalizedStringPreferredFormat("ginivision.help.menu.returnAssistant.section2.body", comment: "first body text for the second section on the help menu return assistant screen")
    }

    fileprivate var titleSection3: String {
        return
            NSLocalizedStringPreferredFormat("ginivision.help.menu.returnAssistant.section3.title", comment: "title for the third section on the help menu return assistant screen")
    }

    fileprivate var section3Body: String {
        return
            NSLocalizedStringPreferredFormat("ginivision.help.menu.returnAssistant.section3.body", comment: "first body text for the third section on the help menu return assistant screen")
    }

    fileprivate var section2Image: UIImage {
        return UIImageNamedPreferred(named: "helpMenuReturnAssistantSection2Image") ?? UIImage()
    }

    fileprivate var section3Image: UIImage {
        return UIImageNamedPreferred(named: "helpMenuReturnAssistantSection3Image") ?? UIImage()
    }

    fileprivate var backButtonTitle: String {
        return NSLocalizedStringPreferredFormat("ginivision.help.menu.returnAssistant.backButton.title", comment: "title for the back button on the help menu return assistant screen")
    }

    @IBOutlet var helpReturnAssistantTableView: UITableView!

    override public func viewDidLoad() {
        super.viewDidLoad()
        helpReturnAssistantTableView.delegate = self
        helpReturnAssistantTableView.dataSource = self
        configureUI()
    }
    
    fileprivate func configureUI() {
        title = pageTitle
        helpReturnAssistantTableView.backgroundColor = UIColor.from(giniColor: GiniConfiguration.shared.helpScreenBackgroundColor)
   }

    static func instantiate() -> HelpMenuReturnAssistantViewController {
        let bundle = giniBundle()
        return UIStoryboard(name: Constants.storyboard, bundle: bundle).instantiateViewController(withIdentifier: Constants.viewControllerIdentifier) as! HelpMenuReturnAssistantViewController
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CellType.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = CellType(rawValue: indexPath.row)
        
        switch cellType {
        case .returnAssistant:
            if let cell = tableView.dequeueReusableCell(withIdentifier:Constants.helpReturnAssistantCellId, for: indexPath) as? HelpMenuReturnAssistantCell {
                let viewModelCell = HelpMenuReturnAssistantCellViewModel.init(title: titleSection1, instruction1: section1Body1, instruction2: section1Body2, image: section1Image)
                cell.viewModel = viewModelCell
                return cell
            } else {
                return UITableViewCell()
            }
        case .changeQuantity:
            if let cell = tableView.dequeueReusableCell(withIdentifier: Constants.helpReturnAssistantCountCellId, for: indexPath) as? HelpMenuReturnAssistantCountCell {
                let viewModelCell = HelpMenuReturnAssistantCountCellViewModel.init(title: titleSection2, instruction: section2Body, image: section2Image)
                cell.viewModel = viewModelCell
                return cell
            } else {
                return UITableViewCell()
            }
       case .changePrice:
        if let cell = tableView.dequeueReusableCell(withIdentifier: Constants.helpReturnAssistantPriceCellId, for: indexPath) as? HelpMenuReturnAssistantPriceCell {
            let handler: () -> () = {
                self.navigationController?.popViewController(animated: true)
            }
            let viewModelCell = HelpMenuReturnAssistantPriceCellViewModel.init(title: titleSection3, instruction: section3Body, image:section3Image , buttonTitle: backButtonTitle, action: handler)
            cell.viewModel = viewModelCell
            return cell
        } else {
            return UITableViewCell()
        }
        case .none:
            return UITableViewCell()
        }
    }
}

