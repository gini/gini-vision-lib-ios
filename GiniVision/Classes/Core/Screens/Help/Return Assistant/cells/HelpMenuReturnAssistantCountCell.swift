//
//  HelpMenuReturnAssistantCountCell.swift
//  GiniVision
//
//  Created by Nadya Karaban on 28.10.20.
//

import Foundation
import UIKit

class HelpMenuReturnAssistantCountCell: UITableViewCell {
    @IBOutlet weak var titlePage2: UILabel!
    @IBOutlet weak var instructionText: UILabel!
    @IBOutlet weak var helpImage: UIImageView!
    
    var viewModel: HelpMenuReturnAssistantCountCellViewModel? {
        didSet {
            if let vm = viewModel {
                titlePage2.text = vm.sectionTitle
                //titlePage1.textColor
               // titlePage1.font =
                
                instructionText.text = vm.instructionText
                //instructionText1.textColor
               // instructionText1.font =
                
                helpImage.image = vm.helpImage
            }
        }
    }
}
