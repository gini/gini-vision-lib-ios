//
//  SettingsViewController.swift
//  GiniVision_Example
//
//  Created by Enrique del Pozo Gómez on 10/30/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import UIKit
import GiniVision

protocol SettingsViewControllerDelegate: class {
    func settings(settingViewController: SettingsViewController,
                  didChangeConfiguration configuration: GiniConfiguration)
}

final class SettingsViewController: UIViewController {
    
    weak var delegate: SettingsViewControllerDelegate?
    var giniConfiguration: GiniConfiguration!

    @IBOutlet weak var fileImportControl: UISegmentedControl!
    @IBOutlet weak var openWithSwitch: UISwitch!
    @IBOutlet weak var qrCodeScanningSwitch: UISwitch!
    @IBOutlet weak var multipageSwitch: UISwitch!
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
        
        delegate?.settings(settingViewController: self, didChangeConfiguration: giniConfiguration)
    }
    
    @IBAction func closeButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func openWithSwitch(_ sender: UISwitch) {
        giniConfiguration.openWithEnabled = sender.isOn
        delegate?.settings(settingViewController: self, didChangeConfiguration: giniConfiguration)
    }
    
    @IBAction func qrCodeScanningSwitch(_ sender: UISwitch) {
        giniConfiguration.qrCodeScanningEnabled = sender.isOn
        delegate?.settings(settingViewController: self, didChangeConfiguration: giniConfiguration)
    }
    
    @IBAction func multipageSwitch(_ sender: UISwitch) {
        giniConfiguration.multipageEnabled = sender.isOn
        delegate?.settings(settingViewController: self, didChangeConfiguration: giniConfiguration)

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        openWithSwitch.setOn(giniConfiguration.openWithEnabled, animated: true)
        qrCodeScanningSwitch.setOn(giniConfiguration.qrCodeScanningEnabled, animated: true)
        multipageSwitch.setOn(giniConfiguration.multipageEnabled, animated: true)
        
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
