//
//  HelpMenuReturnAssistantCountCell.swift
//  GiniVision
//
//  Created by Nadya Karaban on 28.10.20.
//

import Foundation
import UIKit

class HelpMenuReturnAssistantCountCell: UITableViewCell {
    @IBOutlet weak var titlePage: UILabel!
    @IBOutlet weak var instructionText: UILabel!
    @IBOutlet weak var helpImage: UIImageView!
    
    var viewModel: HelpMenuReturnAssistantCountCellViewModel? {
        didSet {
            if let vm = viewModel {
                titlePage.text = vm.sectionTitle
                titlePage.textColor = UIColor.from(giniColor: vm.giniConfig.helpReturnAssistantScreenSectionTitleColor)
                titlePage.font = vm.giniConfig.helpReturnAssistantScreenSectionTitleFont
                
                instructionText.text = vm.instructionText
                instructionText.textColor = UIColor.from(giniColor: vm.giniConfig.helpReturnAssistantScreenInstructionColor)
                instructionText.font = vm.giniConfig.helpReturnAssistantScreenInstructionFont
                
                helpImage.image = vm.helpImage
            }
        }
    }
}
