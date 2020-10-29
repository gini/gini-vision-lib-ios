//
//  HelpMenuReturnAssistantCell.swift
//  GiniVision
//
//  Created by Nadya Karaban on 28.10.20.
//

import Foundation
import UIKit

class HelpMenuReturnAssistantCell: UITableViewCell {
    @IBOutlet weak var titlePage1: UILabel!
    @IBOutlet weak var instructionText1: UILabel!
    @IBOutlet weak var instructionText2: UILabel!
    @IBOutlet weak var helpImage: UIImageView!
    
    var viewModel: HelpMenuReturnAssistantCellViewModel? {
        didSet {
            if let vm = viewModel {
                titlePage1.text = vm.sectionTitle
                //titlePage1.textColor
               // titlePage1.font =
                
                instructionText1.text = vm.instructionText1
                //instructionText1.textColor
               // instructionText1.font =
                
                instructionText2.text = vm.instructionText2
                //instructionText2.textColor
               // instructionText2.font =
                
                helpImage.image = vm.helpImage
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }
    
    func configure() {
        
    }
}
