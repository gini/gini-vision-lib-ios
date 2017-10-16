//
//  GININoResultsViewControllerTests.swift
//  GiniVision_Tests
//
//  Created by Enrique del Pozo Gómez on 10/16/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest
@testable import GiniVision

class GININoResultsViewControllerTests: XCTestCase {
    
    var viewController: ImageAnalysisNoResultsViewController!
    
    override func setUp() {
        viewController = ImageAnalysisNoResultsViewController()
        _ = viewController.view
    }
    
    func testSuggestionCollectionCount(){
        let suggestionsCount = viewController.captureSuggestions.count
        
        let suggestionsCollectionItemsCount = viewController.collectionView(viewController.suggestionsCollectionView, numberOfItemsInSection: 0)
        
        XCTAssertEqual(suggestionsCount, suggestionsCollectionItemsCount, "suggestionsCollectionView items count should be equal to captureSuggestions array count")
    }
    
    func testSuggestionCollectionCellText() {
        let suggestion1Text = viewController.captureSuggestions[0].text
        
        let suggestionCollectionCell = viewController.collectionView(viewController.suggestionsCollectionView, cellForItemAt: IndexPath(row: 0, section: 0)) as! CaptureSuggestionsCollectionCell
        let suggestionCollectionCellText = suggestionCollectionCell.suggestionText.text
        
        XCTAssertEqual(suggestion1Text, suggestionCollectionCellText, "first suggestionsCollectionView item text should be equal to first captureSuggestions item text")
    }
    
    func testWarningBackgroundColor() {
        let giniConfigurationColor = GiniConfiguration.sharedConfiguration.noResultsWarningContainerIconColor
        
        let warningBackgroundColor = viewController.warningViewIcon.tintColor
        
        XCTAssertEqual(giniConfigurationColor, warningBackgroundColor, "warningViewContainerItem tint color should be the one declared in the GiniConfiguration file")
    }
    
    func testCollectionViewScrollUp() {
        let scrollView = viewController.suggestionsCollectionView
        scrollView.contentOffset.y = -1
        
        viewController.scrollViewDidScroll(scrollView)
        
        XCTAssertEqual(viewController.suggestionsCollectionView.contentOffset, .zero, "when collection view is scrollable, it should not bounce on top")
    }
    
    func testCollectionViewScrollDown() {
        let scrollView = viewController.suggestionsCollectionView
        scrollView.contentOffset.y = 1
        
        viewController.scrollViewDidScroll(scrollView)
        
        XCTAssertNotEqual(viewController.suggestionsCollectionView.contentOffset, .zero, "when collection view is scrollable, it should not be zero when it is scrolling down")
    }
    
    func testCollectionHeaderText() {
        _ = viewController.suggestionsCollectionView.numberOfSections
        let collectionHeader = viewController.suggestionsCollectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: CaptureSuggestionsCollectionView.headerIdentifier, for: IndexPath(item: 0, section: 0)) as? CaptureSuggestionsCollectionHeader
        
        let collectionHeaderText = collectionHeader?.headerTitle.text
        
        XCTAssertEqual(collectionHeaderText, "Tipps für bessere Foto", "suggestion collection view header text should not be modified")
    }
}
