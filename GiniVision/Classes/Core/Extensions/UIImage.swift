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
            self.init(ciImage: outputImage.applying(CGAffineTransform(scaleX: 2, y: 2)))
        } else {
            return nil
        }
    }
}
