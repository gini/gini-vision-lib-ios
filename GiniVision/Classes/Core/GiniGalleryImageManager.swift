//
//  GiniGalleryImageManager.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 2/26/18.
//

import Foundation
import Photos

protocol GiniGalleryImageManagerProtocol: class {
    var numberOfItems: Int { get }
    func fetchImage(at indexPath: IndexPath, completion: @escaping ((UIImage) -> Void))
}

final class GiniGalleryImageManager: GiniGalleryImageManagerProtocol {
    
    let cachingImageManager = PHCachingImageManager()
    lazy var assets: [PHAsset] = self.fetchAssets()
    
    var numberOfItems: Int {
        return assets.count
    }
    
    init() {
        preFetchImages()
    }
    
    func fetchImage(at indexPath: IndexPath, completion: @escaping ((UIImage) -> Void)) {
        cachingImageManager.requestImage(for: assets[indexPath.row],
                                         targetSize: CGSize(width: 250, height: 250),
                                         contentMode: .default,
                                         options: nil) { image, _ in
                                            if let image = image {
                                                completion(image)
                                            }
        }
    }
}

// MARK: Private Methods

extension GiniGalleryImageManager {
    fileprivate func preFetchImages() {
        DispatchQueue.global().async {
            self.cachingImageManager.startCachingImages(for: self.assets,
                                                        targetSize: PHImageManagerMaximumSize,
                                                        contentMode: .default,
                                                        options: nil)
        }
    }
    
    fileprivate func fetchAssets() -> [PHAsset] {
        var assets: [PHAsset] = []
        
        let options: PHFetchOptions = {
            let options = PHFetchOptions()
            options.sortDescriptors = [
                NSSortDescriptor(key: "creationDate", ascending: true)
            ]
            return options
        }()
        
        let results = PHAsset.fetchAssets(with: .image, options: options)
        results.enumerateObjects({ asset, _, _ in
            assets.append(asset)
        })
        
        return assets
    }
}
