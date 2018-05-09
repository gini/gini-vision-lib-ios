//
//  UIImage.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 12/8/17.
//

import Foundation

internal extension UIImage {
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
    
    func rotated90Degrees() -> UIImage? {
        guard let cgImage = self.cgImage else { return nil }
        let rotatedOrientation = nextImageOrientationClockwise(self.imageOrientation)
        return UIImage(cgImage: cgImage, scale: 1.0, orientation: rotatedOrientation)
    }
    
    fileprivate func nextImageOrientationClockwise(_ orientation: UIImageOrientation) -> UIImageOrientation {
        var nextOrientation: UIImageOrientation!
        switch orientation {
        case .up, .upMirrored:
            nextOrientation = .right
        case .down, .downMirrored:
            nextOrientation = .left
        case .left, .leftMirrored:
            nextOrientation = .up
        case .right, .rightMirrored:
            nextOrientation = .down
        }
        return nextOrientation
    }
    
}
