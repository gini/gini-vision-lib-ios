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
                    imageQuality: ImageQuality,
                    completion: @escaping ((UIImage, String) -> Void))
    func startCachingImages(for album: Album)
    func stopCachingImages(for album: Album)
}

enum ImageQuality {
    case original, thumbnail
}

final class GalleryManager: GalleryManagerProtocol {
    
    fileprivate let cachingImageManager = PHCachingImageManager()
    lazy var albums: [Album] = self.fetchAlbums().sorted(by: {
        return $0.count > $1.count
    })
    
    init() {
        
    }
    
    func fetchImage(from album: Album,
                    at indexPath: IndexPath,
                    imageQuality: ImageQuality,
                    completion: @escaping ((UIImage, String) -> Void)) {
        let asset = album.assets[indexPath.row]
        let size = imageQuality == .original ? PHImageManagerMaximumSize: CGSize(width: 250, height: 250)
        cachingImageManager.requestImage(for: asset,
                                         targetSize: size,
                                         contentMode: .default,
                                         options: nil) { image, _ in
                                            if let image = image {
                                                completion(image, asset.localIdentifier)
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
        let userAlbumsCollection  = PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.smartAlbum,
                                                                 subtype: PHAssetCollectionSubtype.any,
                                                                 options: nil)
        let topUserAlbumsCollection  = PHAssetCollection.fetchTopLevelUserCollections(with: nil)
        
        let collections: [PHFetchResult<AnyObject>] = [userAlbumsCollection as! PHFetchResult<AnyObject>, topUserAlbumsCollection as! PHFetchResult<AnyObject>]
        collections.forEach { albumsCollection in
            albumsCollection.enumerateObjects({ (object, _, _) in
                let assets: [PHAsset] = self.fetchAssets(in: object as! PHAssetCollection)
                if !assets.isEmpty {
                    let album = Album(title: object.localizedTitle!, assets: assets)
                    albums.append(album)
                }
            })
        }

        
        return albums
    }
}
