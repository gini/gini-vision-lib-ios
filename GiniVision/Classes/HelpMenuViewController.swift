//
//  HelpMenuViewController.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 10/18/17.
//

import UIKit

final class HelpMenuViewController: UITableViewController {
    
    let tableRowHeight: CGFloat = 64
    var helpMenuCellIdentifier = "helpMenuCellIdentifier"
    lazy var items: [(text: String, id: Int)] = {
        var items = [
            (NSLocalizedString("ginivision.helpmenu.firstItem", bundle: Bundle(for: GiniVision.self), comment: "help menu first item text"), 1),
            (NSLocalizedString("ginivision.helpmenu.thirdItem", bundle: Bundle(for: GiniVision.self), comment: "help menu third item text"), 3)
        ]
        
        if GiniConfiguration.sharedConfiguration.openWithEnabled {
            items.insert((NSLocalizedString("ginivision.helpmenu.secondItem", bundle: Bundle(for: GiniVision.self), comment: "help menu second item text"), 2), at: 1)
        }
        
        return items
    }()
    
    init() {
        super.init(style: .plain)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(showOpenWithTutorial:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("ginivision.helpmenu.title", bundle: Bundle(for: GiniVision.self), comment: "help menu view controller title")
        tableView.tableFooterView = UIView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: helpMenuCellIdentifier)
        tableView.rowHeight = tableRowHeight
        tableView.backgroundColor = Colors.Gini.pearl
        
        if #available(iOS 11.0, *) { // On iOS is .automatic by default and it the transition to this view controller looks weird.
            tableView.contentInsetAdjustmentBehavior = .never
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: helpMenuCellIdentifier, for: indexPath)
        cell.textLabel?.text = items[indexPath.row].0
        cell.textLabel?.font = cell.textLabel?.font.withSize(14)
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = .white
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let viewController = viewController(forRowWithId: items[indexPath.row].id) {
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    func viewController(forRowWithId id: Int) -> UIViewController? {
        switch id {
        case 1:
            return HelpMenuViewController()
        case 2:
            return HelpMenuViewController()
        case 3:
            return HelpMenuViewController()
        default:
            return nil
        }
    }
    
}
