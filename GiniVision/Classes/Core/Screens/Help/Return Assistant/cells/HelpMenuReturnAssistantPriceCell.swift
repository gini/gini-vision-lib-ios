//
//  HelpMenuReturnAssistantPriceCell.swift
//  GiniVision
//
//  Created by Nadya Karaban on 28.10.20.
//

import Foundation
import UIKit

class HelpMenuReturnAssistantPriceCell: UITableViewCell {
    @IBOutlet var titlePage: UILabel!
    @IBOutlet var instructionText: UILabel!
    @IBOutlet var helpImage: UIImageView!
    @IBOutlet var backButton: UIButton!

    var viewModel: HelpMenuReturnAssistantPriceCellViewModel? {
        didSet {
            if let vm = viewModel {
                titlePage.text = vm.sectionTitle
                titlePage.textColor = UIColor.from(giniColor: vm.giniConfig.helpReturnAssistantScreenSectionTitleColor)
                titlePage.font = vm.giniConfig.helpReturnAssistantScreenSectionTitleFont

                instructionText.text = vm.instructionText
                instructionText.textColor = UIColor.from(giniColor: vm.giniConfig.helpReturnAssistantScreenInstructionColor)
                instructionText.font = vm.giniConfig.helpReturnAssistantScreenInstructionFont

                helpImage.image = vm.helpImage

                backButton.backgroundColor = vm.giniConfig.helpReturnAssistantScreenBackButtonColor
                backButton.setTitleColor(UIColor.from(giniColor: vm.giniConfig.helpReturnAssistantScreenBackButtonTitleColor), for: .normal)
                backButton.setTitle(vm.backTitle, for: .normal)
                backButton.titleLabel?.font = vm.giniConfig.helpReturnAssistantScreenBackButtonTitleFont
            }
        }
    }

    @IBAction func backButtonPressed(_ sender: Any) {
        viewModel?.onBackHandling()
    }
}
