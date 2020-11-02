//
//  HelpMenuReturnAssistantCell.swift
//  GiniVision
//
//  Created by Nadya Karaban on 28.10.20.
//

import Foundation
import UIKit

class HelpMenuReturnAssistantCell: UITableViewCell {
    @IBOutlet weak var titlePage: UILabel!
    @IBOutlet weak var instructionText1: UILabel!
    @IBOutlet weak var instructionText2: UILabel!
    @IBOutlet weak var helpImage: UIImageView!
    
    var viewModel: HelpMenuReturnAssistantCellViewModel? {
        didSet {
            if let vm = viewModel {
                titlePage.text = vm.sectionTitle
                titlePage.textColor = UIColor.from(giniColor: vm.giniConfig.helpReturnAssistantScreenSectionTitleColor)
                titlePage.font = vm.giniConfig.helpReturnAssistantScreenPageTitleFont
                
                instructionText1.text = vm.instructionText1
                instructionText1.textColor = UIColor.from(giniColor: vm.giniConfig.helpReturnAssistantScreenInstructionColor)
                instructionText1.font = vm.giniConfig.helpReturnAssistantScreenInstructionFont
                
                instructionText2.text = vm.instructionText2
                instructionText2.textColor = UIColor.from(giniColor: vm.giniConfig.helpReturnAssistantScreenInstructionColor)
                instructionText2.font = vm.giniConfig.helpReturnAssistantScreenInstructionFont
                
                helpImage.image = vm.helpImage
            }
        }
    }
}
