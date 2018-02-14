//
//  GiniQRCodeDocument.swift
//  Bolts
//
//  Created by Enrique del Pozo Gómez on 12/5/17.
//

import Foundation

@objc final public class GiniQRCodeDocument: NSObject, GiniVisionDocument {
    public var type: GiniVisionDocumentType = .qrcode
    public lazy var data: Data = {
        return self.paymentInformation ?? Data(count: 0)
    }()
    public lazy var previewImage: UIImage? = {
        return UIImage(qrData: self.data)
    }()
    public var isReviewable: Bool = false
    public var isImported: Bool = false
    
    fileprivate lazy var paymentInformation: Data? = {
        let jsonDict: [String: Any] = ["qrcode": self.scannedString, "paymentdata": self.extractedParameters]
        
        return try? JSONSerialization.data(withJSONObject: jsonDict, options: .prettyPrinted)
    }()
    fileprivate let scannedString: String
    lazy var extractedParameters: [String: String] = QRCodesExtractor
        .extractParameters(from: self.scannedString, withFormat: self.qrCodeFormat)
    fileprivate let epc06912LinesCount = 12
    fileprivate lazy var qrCodeFormat: QRCodesFormat? = {
        if self.scannedString.starts(with: "bank://") {
            return .bezahlcode
        } else {
            let lines = self.scannedString.splitlines
            if lines.count > 9 &&
                (lines[1] == "001" || lines[1] == "002") &&
                (lines[2] == "1" || lines[2] == "2") {
                return .epc06912
            }
            return nil
        }
    }()
    
    init(scannedString: String) {
        self.scannedString = scannedString
        super.init()
    }
    
    public func checkType() throws {
        if self.qrCodeFormat == nil ||
            self.extractedParameters.isEmpty ||
            self.extractedParameters["iban"] == nil {
            throw DocumentValidationError.qrCodeFormatNotValid
        }
    }
    
}

// MARK: Equatable

extension GiniQRCodeDocument {
    public override func isEqual(_ object: Any?) -> Bool {
        if let object = object as? GiniQRCodeDocument {
            return self.scannedString == object.scannedString
        }
        return false
    }
}
