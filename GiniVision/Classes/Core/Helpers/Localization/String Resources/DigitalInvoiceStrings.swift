//
//  DigitalInvoiceStrings.swift
//  AppHost-GiniVision-Unit-Tests
//
//  Created by Alpár Szotyori on 03.09.20.
//

import Foundation

enum DigitalInvoiceStrings: LocalizableStringResource {
    
    case screenTitle
    case noInvoicePayButtonTitle, payButtonTitle, payButtonTitleAccessibilityLabel
    case items, itemsAccessibilityLabel
    case whatIsThisButtonTitle
    case whatIsThisActionSheetTitle, whatIsThisActionSheetMessage, whatIsThisActionSheetActionHelpful, whatIsThisActionSheetActionNotHelpful,
    whatIsThisActionSheetActionCancel
    case lineItemCheckmarkLabel, lineItemQuantity, lineItemEditButtonTitle, lineItemSaveButtonTitle, lineItemNameTextFieldTitle, lineItemQuantityTextFieldTitle,
    lineItemPriceTextFieldTitle, lineItemMultiplicationAccessibilityLabel, lineItemTotalPriceTitle
    case checkmarkButtonDeselectAccessibilityLabel, checkmarkButtonSelectAccessibilityLabel
    case headerMessagePrimary, headerMessageSecondary
    case totalAccessibilityLabel
    case footerMessage
    case addonNameDiscount, addonNameGiftCard, addonNameOtherDiscounts, addonNameOtherCharges, addonNameShipment
    
    
    var tableName: String {
        return "digitalinvoice"
    }
    
    var tableEntry: LocalizationEntry {
        switch self {
        
        case .screenTitle:
            return ("screentitle", "Digital invoice screen title")
        case .noInvoicePayButtonTitle:
            return ("paybuttontitle.noinvoice", "Digital invoice pay button title when the invoice is missing")
        case .payButtonTitle:
            return ("paybuttontitle", "Digital invoice pay button title")
        case .payButtonTitleAccessibilityLabel:
            return ("paybuttontitle.accessibilitylabel", "Digital invoice pay button accessibility label")
        case .items:
            return ("items", "Digital invoice selected and total items")
        case .itemsAccessibilityLabel:
            return ("items.accessibilitylabel", "Digital invoice selected and total items accessibility label")
        case .whatIsThisButtonTitle:
            return ("whatisthisbutton", "Digital invoice 'What is this?' button title")
        case .whatIsThisActionSheetTitle:
            return ("whatisthisactionsheet.title", "Digital invoice 'What is this?' action sheet title")
        case .whatIsThisActionSheetMessage:
            return ("whatisthisactionsheet.message", "Digital invoice 'What is this?' action sheet message")
        case .whatIsThisActionSheetActionHelpful:
            return ("whatisthisactionsheet.action.helpful", "Digital invoice 'What is this?' action sheet helpful action button title")
        case .whatIsThisActionSheetActionNotHelpful:
            return ("whatisthisactionsheet.action.nothelpful", "Digital invoice 'What is this?' action sheet not helpful action button title")
        case .whatIsThisActionSheetActionCancel:
            return ("whatisthisactionsheet.action.cancel", "Digital invoice 'What is this?' action sheet cancel action button title")
        case .lineItemCheckmarkLabel:
            return ("lineitem.checkmark.label", "Digital invoice line item checkmark label")
        case .lineItemQuantity:
            return ("lineitem.quantity", "Digital invoice line item quantity label")
        case .lineItemEditButtonTitle:
            return ("lineitem.editbutton", "Digital invoice line item edit button title")
        case .lineItemSaveButtonTitle:
            return ("lineitem.savebutton", "Digital invoice line item save button title")
        case .lineItemNameTextFieldTitle:
            return ("lineitem.itemnametextfieldtitle", "Digital invoice line item name text field title")
        case .lineItemQuantityTextFieldTitle:
            return ("lineitem.quantitytextfieldtitle", "Digital invoice line item quantity text field title")
        case .lineItemPriceTextFieldTitle:
            return ("lineitem.pricetextfieldtitle", "Digital invoice line item price text field title")
        case .lineItemMultiplicationAccessibilityLabel:
            return ("lineitem.multiplication.accessibilitylabel", "Digital invoice line item multiplication symbol accessibility label")
        case .lineItemTotalPriceTitle:
            return ("lineitem.totalpricetitle", "Digital invoice line item total price title")
        case .checkmarkButtonDeselectAccessibilityLabel:
            return ("checkmarkbutton.deselect.accessibilitylabel", "Digital invoice checkmark deselect accessibility label")
        case .checkmarkButtonSelectAccessibilityLabel:
            return ("checkmarkbutton.select.accessibilitylabel", "Digital invoice checkmark select accessibility label")
        case .headerMessagePrimary:
            return ("headermessage.primary", "Digital invoice primary header text")
        case .headerMessageSecondary:
            return ("headermessage.secondary", "Digital invoice secondary header text")
        case .totalAccessibilityLabel:
            return ("total.accessibilitylabel", "Digital invoice total price accessibility label")
        case .footerMessage:
            return ("footermessage", "Digital invoice footer message")
        case .addonNameDiscount:
            return ("addonname.discount", "Digital invoice discount addon label")
        case .addonNameGiftCard:
            return ("addonname.giftcard", "Digital invoice gift card addon label")
        case .addonNameOtherDiscounts:
            return ("addonname.otherdiscounts", "Digital invoice other discounts addon label")
        case .addonNameOtherCharges:
            return ("addonname.othercharges", "Digital invoice other charges addon label")
        case .addonNameShipment:
            return ("addonname.shipment", "Digital invoice shipment addon label")
        }
    }
    
    var fallbackTableEntry: String {
        switch self {
        default:
            return ""
        }
    }
    
    var isCustomizable: Bool {
        return true
    }
    
}
