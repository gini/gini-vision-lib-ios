//
//  SupportedTypesViewController.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 10/19/17.
//

import UIKit

final class SupportedFormatsViewController: UITableViewController {
    
    let reuseIdentifier = "reuseIdentifier"
    let rowHeight: CGFloat = 70
    let sectionHeight: CGFloat = 70
    var sections: [(title: String, items: [String], itemsImageBackgroundColor: UIColor)] = [
        ("Folgende Formate werden unterstützt:",
         ["Computer-erstellte Überweisungsträger und Rechnungen",
          "Einseitige Bilder im jpg, png oder tif Format",
          "PDF Dokumente von bis zu 10 Seiten"],
         GiniConfiguration.sharedConfiguration.supportedFormatsIconColor),
        ("Was nicht analysiert wird:",
         ["Handschrift",
          "Fotos von Bildschirme"],
         GiniConfiguration.sharedConfiguration.nonSupportedFormatsIconColor)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Unterstützte Formate"
        tableView.register(SupportedTypeTableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = rowHeight
        tableView.tableFooterView = UIView()
        tableView.sectionHeaderHeight = sectionHeight
        tableView.allowsSelection = false
        tableView.backgroundColor = Colors.Gini.pearl
        tableView.alwaysBounceVertical = false
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
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! SupportedTypeTableViewCell
        cell.textLabel?.text = item
        cell.imageView?.image = UIImageNamedPreferred(named: "navigationCameraClose")!.withRenderingMode(.alwaysTemplate)
        cell.imageBackgroundView.backgroundColor = section.itemsImageBackgroundColor

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }

}

final class SupportedTypeTableViewCell: UITableViewCell {
    
    let imageViewSize = CGSize(width: 12.5, height: 12.5)
    let imageBackgroundSize = CGSize(width: 22, height: 22)
    
    lazy var imageBackgroundView: UIView = {
        let view = UIView(frame: CGRect(origin: .zero, size: self.imageBackgroundSize))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = view.frame.width / 2
        return view
    }()
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        textLabel?.font = textLabel?.font.withSize(14)
        textLabel?.numberOfLines = 0
        if let imageView = imageView {
            imageView.tintColor = .white
            imageView.transform = CGAffineTransform(scaleX: imageViewSize.width / imageView.frame.width, y: imageViewSize.height / imageView.frame.height)
            contentView.insertSubview(imageBackgroundView, belowSubview: imageView)
            addConstraints()
        }
    }
    
    private func addConstraints() {
        ConstraintUtils.addActiveConstraint(item: imageBackgroundView, attribute: .centerX, relatedBy: .equal, toItem: imageView!, attribute: .centerX, multiplier: 1.0, constant: 0)
        ConstraintUtils.addActiveConstraint(item: imageBackgroundView, attribute: .centerY, relatedBy: .equal, toItem: imageView!, attribute: .centerY, multiplier: 1.0, constant: 0)

        ConstraintUtils.addActiveConstraint(item: imageBackgroundView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 22)
        ConstraintUtils.addActiveConstraint(item: imageBackgroundView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 22)
    }
}
