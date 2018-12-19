//
//  GiniVisionPage.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 4/12/18.
//

import Foundation

/**
 Page processed by the _Gini Vision Library_ when using Multipage analysis.
 It holds a document, an error (if any) and if it has been uploaded
 */
public struct GiniVisionPage {
    public var document: GiniVisionDocument
    public var error: Error?
    public var isUploaded = false
    var thumbnails: [ThumbnailType: UIImage] = [:]
    
    enum ThumbnailType {
        case big, small
    }

    public init(document: GiniVisionDocument, error: Error? = nil, isUploaded: Bool = false) {
        self.document = document
        self.error = error
        self.isUploaded = isUploaded
        
        thumbnails = thumbnails(from: document.data)
    }
    
    private func thumbnails(from data: Data, screen: UIScreen = .main) -> [ThumbnailType: UIImage] {
        let imageSize = UIImage(data: data)?.size ?? .zero
        var thumbnails: [ThumbnailType: UIImage] = [:]
        
        if imageSize.width > (screen.bounds.size.width * 2) {
            let maxWidth = screen.bounds.size.width * 2
            let targetSize = CGSize(width: maxWidth, height: imageSize.height * maxWidth / imageSize.width)
            
            thumbnails[.big] = UIImage.downsample(from: data, to: targetSize, scale: 1.0)
            thumbnails[.small] = UIImage.downsample(from: data, to: targetSize, scale: 1/4)
        } else {
            thumbnails[.big] = UIImage(data: data)
            thumbnails[.small] = UIImage.downsample(from: data, to: imageSize, scale: 1/4)
        }
        
        return thumbnails
    }
}
