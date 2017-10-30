//
//  ExampleSettingsViewController.swift
//  GiniVision_Example
//
//  Created by Enrique del Pozo Gómez on 10/30/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import UIKit
import GiniVision

final class ExampleSettingsViewController: UIViewController {
    
    var giniConfiguration: GiniConfiguration!

    @IBOutlet weak var fileImportControl: UISegmentedControl!
    @IBOutlet weak var openWithSwitch: UISwitch!
    @IBAction func fileImportOptions(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            giniConfiguration.fileImportSupportedTypes = .none
        case 1:
            giniConfiguration.fileImportSupportedTypes = .pdf
        case 2:
            giniConfiguration.fileImportSupportedTypes = .pdf_and_images
        default: return
        }
    }
    
    @IBAction func closeButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func openWithSwitch(_ sender: UISwitch) {
        giniConfiguration.openWithEnabled = sender.isOn
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        openWithSwitch.setOn(giniConfiguration.openWithEnabled, animated: true)

        switch giniConfiguration.fileImportSupportedTypes {
        case .none:
            fileImportControl.selectedSegmentIndex = 0
        case .pdf:
            fileImportControl.selectedSegmentIndex = 1
        case .pdf_and_images:
            fileImportControl.selectedSegmentIndex = 2
        }
        
    }
}
