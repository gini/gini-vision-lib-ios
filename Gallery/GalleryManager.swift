//
//  GalleryManager.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 2/26/18.
//

import Foundation
import Photos

protocol GalleryManagerProtocol: class {
    var albums: [Album] { get }
    func fetchImage(from album: Album,
                    at indexPath: IndexPath,
                    completion: @escaping ((UIImage) -> Void))
    func startCachingImages(for album: Album)
    func stopCachingImages(for album: Album)
}

final class GalleryManager: GalleryManagerProtocol {
    
    fileprivate let cachingImageManager = PHCachingImageManager()
    lazy var albums: [Album] = self.fetchAlbums().sorted(by: {
        return $0.count > $1.count
    })
    
    init() {
        
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
    
    func startCachingImages(for album: Album) {
        DispatchQueue.global().async {
            self.cachingImageManager.startCachingImages(for: album.assets,
                                                        targetSize: PHImageManagerMaximumSize,
                                                        contentMode: .default,
                                                        options: nil)
        }
    }
    
    func stopCachingImages(for album: Album) {
        self.cachingImageManager.stopCachingImages(for: album.assets,
                                                   targetSize: PHImageManagerMaximumSize,
                                                   contentMode: .default,
                                                   options: nil)
    }
}

// MARK: Private Methods

extension GalleryManager {
    
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
