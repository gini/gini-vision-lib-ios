//
//  DigitalInvoice.swift
//  GiniVision
//
//  Created by Maciej Trybilo on 20.11.19.
//

import Foundation
import Gini

/**
 `DigitalInvoice` represents all extracted data in the form usable by the `DigitalInvoiceViewController`.
 The `DigitalInvoiceViewController` returns a `DigitalInvoice` as amended by the user.
 */
public struct DigitalInvoice {
    
    private let _extractionResult: ExtractionResult
    var lineItems: [LineItem]
    var addons: [DigitalInvoiceAddon]
    
    var total: Price? {
        
        guard let firstLineItem = lineItems.first else { return nil }
        
        let lineItemsTotalPrice = lineItems.reduce(Price(value: 0, currencyCode: firstLineItem.price.currencyCode)) { (current, lineItem) -> Price? in
            
            guard let current = current else { return nil }
            
            switch lineItem.selectedState {
            case .selected: return try? current + lineItem.totalPrice
            case .deselected: return current
            }
        }
        
        let addonsTotalPrice = addons.reduce(Price(value: 0, currencyCode: firstLineItem.price.currencyCode)) { (current, addon) -> Price? in
            
            guard let current = current else { return nil }
            
            return try? current + addon.price
        }
        
        if let lineItemsPriceSum = lineItemsTotalPrice,
            let addonsPriceSum = addonsTotalPrice {
            return try? lineItemsPriceSum + addonsPriceSum
        } else {
            return lineItemsTotalPrice
        }
    }
}

extension DigitalInvoice {
    
    var numSelected: Int {
        
        return lineItems.reduce(Int(0)) { (partial, lineItem) -> Int in
            
            switch lineItem.selectedState {
            case .selected: return partial + lineItem.quantity
            case .deselected: return partial
            }
        }
    }
    
    var numTotal: Int {
        
        return lineItems.reduce(Int(0)) { (partial, lineItem) -> Int in
            return partial + lineItem.quantity
        }
    }
}

extension DigitalInvoice {
    
    enum DigitalInvoiceParsingException: Error {
        case lineItemsMissing
        case nameMissing
        case quantityMissing
        case priceMissing
        case articleNumberMissing
        case mixedCurrenciesInOneInvoice
        case cannotParseQuantity(string: String)
        case cannotParsePrice(string: String)
    }
    
    /**
     Returns a `DigitalInfo` instance given an `ExtractionResult`.
     
     - returns: Instance of `DigitalInfo`.
     */
    public init(extractionResult: ExtractionResult) throws {
        
        self._extractionResult = extractionResult
        
        guard let extractedLineItems = extractionResult.lineItems else { throw DigitalInvoiceParsingException.lineItemsMissing }
        
        lineItems = try extractedLineItems.map { try LineItem(extractions: $0) }
        
        if let firstLineItem = lineItems.first {
            for lineItem in lineItems where lineItem.price.currencyCode != firstLineItem.price.currencyCode {
                throw DigitalInvoiceParsingException.mixedCurrenciesInOneInvoice
            }
        }
        
        addons = []
        
        extractionResult.extractions.forEach { extraction in
            if let addon = DigitalInvoiceAddon(from: extraction) {
                addons.append(addon)
            }
        }
    }
    
    /**
     The backing `ExtractionResult` data.
     */
    public var extractionResult: ExtractionResult {
        
        guard let totalValue = total?.extractionString else {
            
            return ExtractionResult(extractions: _extractionResult.extractions,
                                    lineItems: lineItems.map { $0.extractions })
        }
        
        let modifiedExtractions = _extractionResult.extractions.map { extraction -> Extraction in
            
            if extraction.name == "amountToPay" {
                extraction.value = totalValue
            }
            
            return extraction
        }
        
        return ExtractionResult(extractions: modifiedExtractions,
                                lineItems: lineItems.map { $0.extractions })
    }
}
