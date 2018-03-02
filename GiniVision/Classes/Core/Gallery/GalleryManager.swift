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
                    at index: Int,
                    imageQuality: ImageQuality,
                    completion: @escaping ((UIImage, String) -> Void))
    func fetchImageData(from album: Album,
                        at index: Int,
                        completion: @escaping ((Data, String) -> Void))
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
        
    func fetchImage(from album: Album,
                    at index: Int,
                    imageQuality: ImageQuality,
                    completion: @escaping ((UIImage, String) -> Void)) {
        let asset = album.assets[index]
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
    
    func fetchImageData(from album: Album, at index: Int, completion: @escaping ((Data, String) -> Void)) {
        let asset = album.assets[index]
        cachingImageManager.requestImageData(for: asset, options: nil) { data, _, _, _ in
            if let data = data {
                completion(data, asset.localIdentifier)
            }
        }
    }
    
    func startCachingImages(for album: Album) {
        self.cachingImageManager.startCachingImages(for: album.assets,
                                                    targetSize: PHImageManagerMaximumSize,
                                                    contentMode: .default,
                                                    options: nil)
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
        let userAlbumsCollection = PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.smartAlbum,
                                                                           subtype: PHAssetCollectionSubtype.any,
                                                                           options: nil) as? PHFetchResult<PHCollection>
        let topUserAlbumsCollection = PHAssetCollection.fetchTopLevelUserCollections(with: nil)
        
        let collections = [userAlbumsCollection!, topUserAlbumsCollection]
        collections.forEach { albumsCollection in
            albumsCollection.enumerateObjects({ (collection, _, _) in
                if let collection = collection as? PHAssetCollection {
                    let assets: [PHAsset] = self.fetchAssets(in: collection)
                    if !assets.isEmpty {
                        let album = Album(assets: assets,
                                          title: collection.localizedTitle ?? "",
                                          identifier: collection.localIdentifier)
                        albums.append(album)
                    }
                }
            })
        }

        return albums
    }
}
