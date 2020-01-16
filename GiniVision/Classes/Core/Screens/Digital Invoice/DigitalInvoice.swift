//
//  DigitalInvoice.swift
//  GiniVision
//
//  Created by Maciej Trybilo on 20.11.19.
//

import Foundation

struct DigitalInvoice {
        
    struct LineItem {
        
        enum SelectedState {
            
            enum Reason: String, CaseIterable {
                case looksDifferent
                case poorQualityOrFaulty
                case doesNotFit
                case doesNotSuit
                case wrongItem
                case damaged
                case arrivedTooLate
            }
            
            case selected
            case deselected(reason: Reason)
        }
        
        var name: String?
        var quantity: Int
        var price: Price
        var selectedState: SelectedState
        
        var totalPrice: Price {
            return price * quantity
        }
    }
    
    var recipientName: String?
    var iban: String?
    var reference: String?
    
    var total: Price {
        
        return lineItems.reduce(Price.zero) { (current, lineItem) -> Price in
            
            switch lineItem.selectedState {
            case .selected: return current + lineItem.totalPrice
            case .deselected: return current
            }            
        }
    }
    
    var lineItems: [LineItem]
}

extension DigitalInvoice.LineItem.SelectedState.Reason {
    
    var displayString: String {
        
        switch self {
        case .looksDifferent: return NSLocalizedString("ginivision.digitalinvoice.deselectreason.looksdifferent",
                                                       bundle: Bundle(for: GiniVision.self), comment: "")
        case .poorQualityOrFaulty: return NSLocalizedString("ginivision.digitalinvoice.deselectreason.poorqualityorfaulty",
                                                            bundle: Bundle(for: GiniVision.self), comment: "")
        case .doesNotFit: return NSLocalizedString("ginivision.digitalinvoice.deselectreason.doesnotfit",
                                                   bundle: Bundle(for: GiniVision.self), comment: "")
        case .doesNotSuit: return NSLocalizedString("ginivision.digitalinvoice.deselectreason.doesnotsuit",
                                                    bundle: Bundle(for: GiniVision.self), comment: "")
        case .wrongItem: return NSLocalizedString("ginivision.digitalinvoice.deselectreason.wrongitem",
                                                  bundle: Bundle(for: GiniVision.self), comment: "")
        case .damaged: return NSLocalizedString("ginivision.digitalinvoice.deselectreason.damaged",
                                                bundle: Bundle(for: GiniVision.self), comment: "")
        case .arrivedTooLate: return NSLocalizedString("ginivision.digitalinvoice.deselectreason.arrivedtoolate",
                                                       bundle: Bundle(for: GiniVision.self), comment: "")
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
