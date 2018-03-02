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
    
    var selectedIndexes: [IndexPath] = []
    
    func imagePicker(_ viewController: ImagePickerViewController, didSelectAssetAt index: IndexPath, in album: Album) {
        selectedIndexes.append(index)
    }
    
    func imagePicker(_ viewController: ImagePickerViewController, didDeselectAssetAt index: IndexPath, in album: Album) {
        if let index = selectedIndexes.index(of: index) {
            selectedIndexes.remove(at: index)
        }
    }
    
    
}
