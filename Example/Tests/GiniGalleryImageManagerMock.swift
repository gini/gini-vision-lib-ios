//
//  GiniGalleryImageManagerMock.swift
//  GiniVision_Tests
//
//  Created by Enrique del Pozo Gómez on 2/26/18.
//  Copyright © 2018 Gini GmbH. All rights reserved.
//

import Foundation
import Photos
@testable import GiniVision

final class GiniGalleryImageManagerMock: GalleryManagerProtocol {
    var albums: [Album] = [Album(assets: [PHAsset()], title: "Album 1", identifier: "Album 1"),
                           Album(assets: [PHAsset(), PHAsset()], title: "Album 2", identifier: "Album 2"),
                           Album(assets: [], title: "Album 3", identifier: "Album 3")]
    
    func startCachingImages(for album: Album) {

    }
    
    func stopCachingImages(for album: Album) {
        
    }
    
    func fetchImageData(from album: Album, at index: Int, completion: @escaping ((Data, String) -> Void)) {
        
    }
    
    func fetchImage(from album: Album, at index: Int, imageQuality: ImageQuality, completion: @escaping ((UIImage, String) -> Void)) {
        
    }
}
