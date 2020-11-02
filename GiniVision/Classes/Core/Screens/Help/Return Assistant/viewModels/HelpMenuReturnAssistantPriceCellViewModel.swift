//
//  HelpMenuReturnAssistantPriceCellViewModel.swift
//  GiniVision
//
//  Created by Nadya Karaban on 29.10.20.
//

import Foundation
class HelpMenuReturnAssistantPriceCellViewModel {
    let sectionTitle: String
    let instructionText: String
    let backTitle: String
    let helpImage: UIImage
    let giniConfig = GiniConfiguration.shared
    var onBackHandling: () -> Void = {}

    init(title: String, instruction: String, image: UIImage, buttonTitle: String, action: @escaping () -> Void) {
        sectionTitle = title
        instructionText = instruction
        backTitle = buttonTitle
        helpImage = image
        onBackHandling = action
    }
}
