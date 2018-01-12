//
//  GiniQRCodeDocument.swift
//  Bolts
//
//  Created by Enrique del Pozo Gómez on 12/5/17.
//

import Foundation

@objc final public class GiniQRCodeDocument: NSObject, GiniVisionDocument {
    public var type: GiniVisionDocumentType = .qrcode
    public var data: Data
    public lazy var previewImage: UIImage? = {
        return UIImage(qrData: self.data)
    }()
    public var isReviewable: Bool = false
    public var isImported: Bool = false
    public lazy var extractedParameters: [String: String] = QRCodesExtractor
        .extractParameters(from: self.scannedString, withFormat: self.qrCodeFormat)
    public lazy var paymentInformation: Data? = self.formatPaymentInformation()
    
    fileprivate let scannedString: String
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
    
    public init(scannedString: String) {
        self.data = scannedString.data(using: String.Encoding.isoLatin1) ?? Data(count: 0)
        self.scannedString = scannedString
        super.init()
    }
    
    public func checkType() throws {
        if self.qrCodeFormat == nil || self.extractedParameters.isEmpty {
            throw DocumentValidationError.qrCodeFormatNotValid
        }
    }
    
    fileprivate func formatPaymentInformation() -> Data? {
        let jsonDict: [String: Any] = ["qrcode": scannedString, "paymentdata": extractedParameters]

        return try? JSONSerialization.data(withJSONObject: jsonDict, options: .prettyPrinted)
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
