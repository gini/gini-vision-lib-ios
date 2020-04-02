//
//  DigitalLineItemViewModelTests.swift
//  GiniVision-Unit-Tests
//
//  Created by Maciej Trybilo on 17.12.19.
//

import XCTest
@testable import GiniVision

class DigitalLineItemViewModelTests: XCTestCase {
    
    let selectedLineItemVM = DigitalLineItemViewModel(lineItem: DigitalInvoice.LineItem(name: "Nike Sportswear Air Max 97 - Sneaker",
                                                                                        quantity: 3,
                                                                                        price: Price(value: 76.02, currencyCode: "eur"),
                                                                                        selectedState: .selected),
                                                      giniConfiguration: GiniConfiguration.shared,
                                                      index: 0)
    
    let deselectedLineItemVM = DigitalLineItemViewModel(lineItem: DigitalInvoice.LineItem(name: "Nike Sportswear INTERNATIONALIST",
                                                                                          quantity: 1,
                                                                                          price: Price(value: 220.00, currencyCode: "eur"),
                                                                                          selectedState: .deselected),
                                                        giniConfiguration: GiniConfiguration.shared,
                                                        index: 0)
    
    func testName() {
        
        XCTAssertEqual(selectedLineItemVM.name, "Nike Sportswear Air Max 97 - Sneaker")
        XCTAssertEqual(deselectedLineItemVM.name, "Nike Sportswear INTERNATIONALIST")
    }
    
    func testQuantityOrReasonString() {
        
        XCTAssertEqual(selectedLineItemVM.quantityString, "Quantity: 3")
        XCTAssertEqual(deselectedLineItemVM.quantityString, nil)
    }
    
    func testCheckboxTintColor() {
        
        XCTAssertEqual(selectedLineItemVM.checkboxTintColor, selectedLineItemVM.giniConfiguration.lineItemTintColor)
        XCTAssertEqual(deselectedLineItemVM.checkboxTintColor, .white)
    }
    
    func testEditButtonTintColor() {
        
        XCTAssertEqual(selectedLineItemVM.editButtonTintColor, selectedLineItemVM.giniConfiguration.lineItemTintColor)
        
        let deselectedColor: UIColor
        if #available(iOS 13.0, *) {
            deselectedColor = .secondaryLabel
        } else {
            deselectedColor = .gray
        }
        
        XCTAssertEqual(deselectedLineItemVM.editButtonTintColor, deselectedColor)
    }
    
    func testPrimaryTextColor() {
        
        let selectedColor: UIColor
        
        if #available(iOS 13.0, *) {
            selectedColor = .label
        } else {
            selectedColor = .black
        }
        
        XCTAssertEqual(selectedLineItemVM.primaryTextColor, selectedColor)
        
        let deselectedColor: UIColor
        
        if #available(iOS 13.0, *) {
            deselectedColor = .secondaryLabel
        } else {
            deselectedColor = .gray
        }
        
        XCTAssertEqual(deselectedLineItemVM.primaryTextColor, deselectedColor)
    }
    
    func testCellShadowColor() {
        
        XCTAssertEqual(selectedLineItemVM.cellShadowColor, .black)
        XCTAssertEqual(deselectedLineItemVM.cellShadowColor, .clear)
    }
    
    func testCellBorderColor() {
        
        XCTAssertEqual(selectedLineItemVM.cellBorderColor, selectedLineItemVM.giniConfiguration.lineItemTintColor)
        
        let deselectedColor: UIColor
        
        if #available(iOS 13.0, *) {
            deselectedColor = .secondaryLabel
        } else {
            deselectedColor = .gray
        }
        
        XCTAssertEqual(deselectedLineItemVM.cellBorderColor, deselectedColor)
    }
}
