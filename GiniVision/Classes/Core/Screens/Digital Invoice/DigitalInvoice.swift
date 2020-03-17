//
//  DigitalInvoice.swift
//  GiniVision
//
//  Created by Maciej Trybilo on 20.11.19.
//

import Foundation
import Gini

public struct DigitalInvoice {
    
    private let _extractionResult: ExtractionResult
    var lineItems: [LineItem]
    
    var total: Price? {
        
        guard let firstLineItem = lineItems.first else { return nil }
        
        return lineItems.reduce(Price(value: 0, currencyCode: firstLineItem.price.currencyCode)) { (current, lineItem) -> Price? in
            
            guard let current = current else { return nil }
            
            switch lineItem.selectedState {
            case .selected: return try? current + lineItem.totalPrice
            case .deselected: return current
            }
        }
    }
}

extension DigitalInvoice.LineItem.SelectedState.Reason: ExpressibleByStringLiteral {
    
    public init(stringLiteral value: String) {
        
        self = .init(displayString: NSLocalizedString(value, bundle: Bundle(for: GiniVision.self), comment: ""))
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
    
    public init(extractionResult: ExtractionResult) throws {
        
        self._extractionResult = extractionResult
        
        guard let extractedLineItems = extractionResult.lineItems else { throw DigitalInvoiceParsingException.lineItemsMissing }
        
        lineItems = try extractedLineItems.map { try LineItem(extractions: $0) }
        
        if let firstLineItem = lineItems.first {
            for lineItem in lineItems where lineItem.price.currencyCode != firstLineItem.price.currencyCode {
                throw DigitalInvoiceParsingException.mixedCurrenciesInOneInvoice
            }
        }
    }
    
    public var extractionResult: ExtractionResult {
        
        return ExtractionResult(extractions: _extractionResult.extractions,
                                lineItems: lineItems.map { $0.extractions })
    }
}