//
//  UIImage.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 12/8/17.
//

import Foundation

extension UIImage {
    convenience init?(qrData data: Data) {
        let filter = CIFilter(name: "CIQRCodeGenerator")
        
        filter?.setValue(data, forKey: "inputMessage")
        filter?.setValue("Q", forKey: "inputCorrectionLevel")

        if let outputImage = filter?.outputImage {
            self.init(ciImage: outputImage.transformed(by: CGAffineTransform(scaleX: 2, y: 2)))
        } else {
            return nil
        }
    }
    
    convenience init(bundleName: StaticString) {
        self.init(named: "\(bundleName)", in: Bundle(for: GiniVision.self), compatibleWith: nil)!
    }
    
    func rotated90Degrees() -> UIImage? {
        guard let cgImage = self.cgImage else { return nil }
        let rotatedOrientation = nextImageOrientationClockwise(self.imageOrientation)
        return UIImage(cgImage: cgImage, scale: 1.0, orientation: rotatedOrientation)
    }
    
    fileprivate func nextImageOrientationClockwise(_ orientation: UIImage.Orientation) -> UIImage.Orientation {
        var nextOrientation: UIImage.Orientation!
        switch orientation {
        case .up, .upMirrored:
            nextOrientation = .right
        case .down, .downMirrored:
            nextOrientation = .left
        case .left, .leftMirrored:
            nextOrientation = .up
        case .right, .rightMirrored:
            nextOrientation = .down
        @unknown default:
            preconditionFailure("All orientation must be handled")
        }
        return nextOrientation
    }
    
    static func downsample(from data: Data, to pointSize: CGSize, scale: CGFloat) -> UIImage {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        let imageSource = CGImageSourceCreateWithData(data as CFData, imageSourceOptions)!
        let maxDimensionInPixels = max(pointSize.width, pointSize.height) * scale
        let downsampleOptions =
            [kCGImageSourceCreateThumbnailFromImageAlways: true,
             kCGImageSourceShouldCacheImmediately: true,
             kCGImageSourceCreateThumbnailWithTransform: true,
             kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels] as CFDictionary
        let downsampledImage =
            CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions)!
        return UIImage(cgImage: downsampledImage)
    }
    
}
