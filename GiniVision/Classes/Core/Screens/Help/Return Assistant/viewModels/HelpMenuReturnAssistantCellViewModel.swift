//
//  HelpMenuReturnAssistantCellViewModel.swift
//  GiniVision
//
//  Created by Nadya Karaban on 29.10.20.
//

import Foundation
class HelpMenuReturnAssistantCellViewModel {
    let sectionTitle: String
    let instructionText1: String
    let instructionText2: String
    let helpImage: UIImage
    let giniConfig = GiniConfiguration.shared

    init(title: String, instruction1: String, instruction2: String, image: UIImage) {
        sectionTitle = title
        instructionText1 = instruction1
        instructionText2 = instruction2
        helpImage = image
    }
}
