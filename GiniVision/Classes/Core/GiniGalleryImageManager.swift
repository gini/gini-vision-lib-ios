//
//  GiniGalleryImageManager.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 2/26/18.
//

import Foundation
import Photos

protocol GiniGalleryImageManagerProtocol: class {
    func fetchImage(from album: Album,
                    at indexPath: IndexPath,
                    completion: @escaping ((UIImage) -> Void))
}

final class GiniGalleryImageManager: GiniGalleryImageManagerProtocol {
    
    let cachingImageManager = PHCachingImageManager()
    lazy var albums: [Album] = self.fetchAlbums().sorted(by: {
        return $0.count > $1.count
    })
    
    init() {
        preFetchImages()
    }
    
    func fetchImage(from album: Album, at indexPath: IndexPath, completion: @escaping ((UIImage) -> Void)) {
        cachingImageManager.requestImage(for: album.assets[indexPath.row],
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
            self.cachingImageManager.startCachingImages(for: self.albums.first!.assets,
                                                        targetSize: PHImageManagerMaximumSize,
                                                        contentMode: .default,
                                                        options: nil)
        }
    }
    
    fileprivate func fetchAssets(in collection: PHAssetCollection) -> [PHAsset] {
        var assets: [PHAsset] = []
        
        let options = PHFetchOptions()
        options.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: true)
        ]
        options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        
        let results = PHAsset.fetchAssets(in: collection, options: options)
        results.enumerateObjects({ asset, _, _ in
            assets.append(asset)
        })
        
        return assets
    }
    
    fileprivate func fetchAlbums() -> [Album] {
        var albums: [Album] = []
        let userAlbums = PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.smartAlbum,
                                                                 subtype: PHAssetCollectionSubtype.any,
                                                                 options: nil)
        userAlbums.enumerateObjects({ (object, _, _) in
            let assets: [PHAsset] = self.fetchAssets(in: object)
            if !assets.isEmpty {
                let album = Album(title: object.localizedTitle!, assets: assets)
                albums.append(album)
            }
        })
        
        return albums
    }
}
