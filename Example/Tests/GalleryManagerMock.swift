//
//  GalleryManagerMock.swift
//  GiniVision_Tests
//
//  Created by Enrique del Pozo Gómez on 2/26/18.
//  Copyright © 2018 Gini GmbH. All rights reserved.
//

import Foundation
import Photos
@testable import GiniVision

final class GalleryManagerMock: GalleryManagerProtocol {
    var isGalleryAccessLimited: Bool = false
    var albums: [Album] = [Album(assets: [Asset(identifier: "Asset 1")],
                                 title: "Album 1",
                                 identifier: "Album 1"),
                           Album(assets: [Asset(identifier: "Asset 1"), Asset(identifier: "Asset 2")],
                                 title: "Album 2",
                                 identifier: "Album 2"),
                           Album(assets: [Asset(identifier: "Asset 1"), Asset(identifier: "Asset 2")],
                                 title: "Album 3",
                                 identifier: "Album 3")]
    
    var isCaching = false
        
    func reloadAlbums() {
        
    }
    
    func startCachingImages(for album: Album) {
        isCaching = true
    }
    
    func stopCachingImages(for album: Album) {
        isCaching = false
    }
    
    func fetchImageData(from asset: Asset, completion: @escaping ((Data?) -> Void)) {
        completion(Data(count: 10))
    }
    
    func fetchRemoteImageData(from asset: Asset, completion: @escaping ((Data?) -> Void)) {
        completion(Data(count: 10))
    }
    
    func fetchImage(from asset: Asset, imageQuality: ImageQuality, completion: @escaping ((UIImage) -> Void)) {
        
    }
}

extension Asset {
    init(identifier: String) {
        self.init(value: PHAsset())
        self.identifier = identifier
    }
}
