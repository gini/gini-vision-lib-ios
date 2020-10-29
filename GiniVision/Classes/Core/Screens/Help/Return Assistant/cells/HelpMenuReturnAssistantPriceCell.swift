//
//  HelpMenuReturnAssistantPriceCell.swift
//  GiniVision
//
//  Created by Nadya Karaban on 28.10.20.
//

import Foundation
import UIKit

class HelpMenuReturnAssistantPriceCell: UITableViewCell {
    @IBOutlet weak var titlePage3: UILabel!
    @IBOutlet weak var instructionText: UILabel!
    @IBOutlet weak var helpImage: UIImageView!
    @IBOutlet weak var backButton: UIButton!
    
    var viewModel: HelpMenuReturnAssistantPriceCellViewModel? {
        didSet {
            if let vm = viewModel {
                titlePage3.text = vm.sectionTitle
                //titlePage3.textColor
               // titlePage3.font =
                
                instructionText.text = vm.instructionText
                //instructionText1.textColor
               // instructionText1.font =
                
                helpImage.image = vm.helpImage
                backButton.setTitle(vm.backTitle, for: .normal)
               // backButton.tintColor
               // backButton.
                //backButton.addAction(vm.onBackHandling, for: .to)
            }
        }
    }
    @IBAction func backButtonPressed(_ sender: Any) {
        viewModel?.onBackHandling()
    }
    
}
