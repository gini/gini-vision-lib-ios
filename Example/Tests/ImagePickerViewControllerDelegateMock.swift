//
//  ImagePickerViewControllerDelegateMock.swift
//  GiniVision_Example
//
//  Created by Enrique del Pozo Gómez on 3/2/18.
//  Copyright © 2018 Gini GmbH. All rights reserved.
//

import Foundation
@testable import GiniVision

final class ImagePickerViewControllerDelegateMock: ImagePickerViewControllerDelegate {
    var selectedAssets: [Asset] = []

    func imagePicker(_ viewController: ImagePickerViewController, didSelectAsset asset: Asset) {
        selectedAssets.append(asset)
    }
    
    func imagePicker(_ viewController: ImagePickerViewController, didDeselectAsset asset: Asset) {
        if let index = selectedAssets.index(where: { $0.identifier == asset.identifier}) {
            selectedAssets.remove(at: index)
        }
    }
    
}
