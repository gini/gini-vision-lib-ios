//
//  HelpMenuViewController.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 10/18/17.
//

import UIKit

class HelpMenuViewController: UITableViewController {
    
    let tableRowHeight: CGFloat = 64
    var reuseIdentifier = "reuseIdentifier"
    var items: [(text: String, id: Int)] = [
        ("Tipps für beste Ergebnisse aus Fotos", 1),
        ("Dokumente aus anderen Apps öffnen", 2),
        ("Unterstützte Formate", 3)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = tableRowHeight
        tableView.backgroundColor = Colors.Gini.pearl
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
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
