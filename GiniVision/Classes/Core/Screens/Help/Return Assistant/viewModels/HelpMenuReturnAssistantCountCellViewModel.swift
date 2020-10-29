//
//  HelpMenuReturnAssistantCountCellViewModel.swift
//  GiniVision
//
//  Created by Nadya Karaban on 29.10.20.
//

import Foundation
class HelpMenuReturnAssistantCountCellViewModel {
    let sectionTitle: String
    let instructionText: String
    let helpImage: UIImage
    let giniConfig = GiniConfiguration.shared

    init(title: String, instruction: String, image: UIImage) {
        sectionTitle = title
        instructionText = instruction
        helpImage = image
    }
}
