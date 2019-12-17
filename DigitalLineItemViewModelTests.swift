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
                                                                                        price: 7602,
                                                                                        selectedState: .selected),
                                                      giniConfiguration: GiniConfiguration.shared,
                                                      index: 0)
    
    let deselectedLineItemVM = DigitalLineItemViewModel(lineItem: DigitalInvoice.LineItem(name: "Nike Sportswear INTERNATIONALIST",
                                                                                          quantity: 1,
                                                                                          price: 22000,
                                                                                          selectedState: .deselected(reason: .damaged)),
                                                        giniConfiguration: GiniConfiguration.shared,
                                                        index: 0)
    
    func testName() {
        
        XCTAssertEqual(selectedLineItemVM.name, "Nike Sportswear Air Max 97 - Sneaker")
        XCTAssertEqual(deselectedLineItemVM.name, "Nike Sportswear INTERNATIONALIST")
    }
    
    func testQuantityOrReasonString() {
        
        XCTAssertEqual(selectedLineItemVM.quantityOrReturnReasonString, "Quantity: 3")
        XCTAssertEqual(deselectedLineItemVM.quantityOrReturnReasonString, "Parcel damaged")
    }
    
    func testPriceMainUnitString() {
        
        XCTAssertEqual(selectedLineItemVM.priceMainUnitString, "€228")
        XCTAssertEqual(deselectedLineItemVM.priceMainUnitString, "€220")
    }

    func testPriceFractionalUnitString() {
        
        XCTAssertEqual(selectedLineItemVM.priceFractionalUnitString, ".06")
        XCTAssertEqual(deselectedLineItemVM.priceFractionalUnitString, ".00")
    }
    
    func testCheckboxBackgroundColor() {
        
        XCTAssertEqual(selectedLineItemVM.checkboxBackgroundColor, selectedLineItemVM.giniConfiguration.lineItemTintColor)
        XCTAssertEqual(deselectedLineItemVM.checkboxBackgroundColor, .white)
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
