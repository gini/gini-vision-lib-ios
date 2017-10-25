//
//  GINIImageAnalysisNoResultsViewControllerTests.swift
//  GiniVision_Tests
//
//  Created by Enrique del Pozo Gómez on 10/16/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniVision

final class GINIImageAnalysisNoResultsViewControllerTests: XCTestCase {
    
    let viewControllerTitle = "Title"
    lazy var viewController: ImageAnalysisNoResultsViewController = ImageAnalysisNoResultsViewController(title: self.viewControllerTitle)
    lazy var mockedItems: [(image: UIImage?, text: String)] = [
        (self.loadImage(withName: "tabBarIconHelp"), "item 1 text"),
        (self.loadImage(withName: "tabBarIconHelp"), "item 2 text"),
        (self.loadImage(withName: "tabBarIconHelp"), "item 3 text"),
    ]
    
    override func setUp() {
        _ = viewController.view
    }
    
    func testViewControllerTitleOnInitialization() {
        let vcTitle = viewController.title
        
        XCTAssertEqual(viewControllerTitle, vcTitle, "view controller title should be equals to the one passed in the initialization")
    }
    
    func testSuggestionCollectionMockedItemsCount(){
        viewController.captureSuggestions = mockedItems
        let suggestionsCollectionItemsCount = viewController.collectionView(viewController.suggestionsCollectionView, numberOfItemsInSection: 0)
        
        XCTAssertEqual(3, suggestionsCollectionItemsCount, "suggestionsCollectionView items count should be equal to the mocked items count declared above")
    }
    
    func testSuggestionCollectionItemsCount(){
        let suggestionsCount = viewController.captureSuggestions.count
        
        let suggestionsCollectionItemsCount = viewController.collectionView(viewController.suggestionsCollectionView, numberOfItemsInSection: 0)
        
        XCTAssertEqual(suggestionsCount, suggestionsCollectionItemsCount, "suggestionsCollectionView items count should be equal to captureSuggestions array count")
    }
    
    func testFirstMockedSuggestionCollectionCellText() {
        viewController.captureSuggestions = mockedItems
        let suggestionCollectionCell = viewController.collectionView(viewController.suggestionsCollectionView, cellForItemAt: IndexPath(row: 0, section: 0)) as! CaptureSuggestionsCollectionCell
        
        let suggestionCollectionCellText = suggestionCollectionCell.suggestionText.text
        
        XCTAssertEqual("item 1 text", suggestionCollectionCellText, "first suggestionsCollectionView item text should be equal to first mocked item text")
    }
    
    func testFirstSuggestionCell() {
        let indexPath = IndexPath(row: 0, section: 0)
        
        let suggestion1Text = viewController.captureSuggestions[indexPath.row].text
        let suggestion1Image = viewController.captureSuggestions[indexPath.row].image
        
        let suggestionCollectionCell = viewController.collectionView(viewController.suggestionsCollectionView, cellForItemAt: indexPath) as! CaptureSuggestionsCollectionCell
        
        XCTAssertEqual(suggestion1Text, suggestionCollectionCell.suggestionText.text, "first suggestionsCollectionView item text should be equal to first captureSuggestions item text")
        XCTAssertEqual(suggestion1Image, suggestionCollectionCell.suggestionImage.image, "first suggestionsCollectionView item image should be equal to first captureSuggestions item image")

    }
    
    func testSecondSuggestionCell() {
        let indexPath = IndexPath(row: 1, section: 0)
        
        let suggestion2Text = viewController.captureSuggestions[indexPath.row].text
        let suggestion2Image = viewController.captureSuggestions[indexPath.row].image
        
        let suggestionCollectionCell = viewController.collectionView(viewController.suggestionsCollectionView, cellForItemAt: indexPath) as! CaptureSuggestionsCollectionCell
        
        XCTAssertEqual(suggestion2Text, suggestionCollectionCell.suggestionText.text, "second suggestionsCollectionView item text should be equal to second captureSuggestions item text")
        XCTAssertEqual(suggestion2Image, suggestionCollectionCell.suggestionImage.image, "second suggestionsCollectionView item image should be equal to second captureSuggestions item image")
        
    }
    
    func testThirdSuggestionCell() {
        let indexPath = IndexPath(row: 2, section: 0)
        
        let suggestion3Text = viewController.captureSuggestions[indexPath.row].text
        let suggestion3Image = viewController.captureSuggestions[indexPath.row].image
        
        let suggestionCollectionCell = viewController.collectionView(viewController.suggestionsCollectionView, cellForItemAt: indexPath) as! CaptureSuggestionsCollectionCell
        
        XCTAssertEqual(suggestion3Text, suggestionCollectionCell.suggestionText.text, "third suggestionsCollectionView item text should be equal to third captureSuggestions item text")
        XCTAssertEqual(suggestion3Image, suggestionCollectionCell.suggestionImage.image, "third suggestionsCollectionView item image should be equal to third captureSuggestions item image")
        
    }
    
    func testFourthSuggestionCell() {
        let indexPath = IndexPath(row: 3, section: 0)
        
        let suggestion4Text = viewController.captureSuggestions[indexPath.row].text
        let suggestion4Image = viewController.captureSuggestions[indexPath.row].image
        
        let suggestionCollectionCell = viewController.collectionView(viewController.suggestionsCollectionView, cellForItemAt: indexPath) as! CaptureSuggestionsCollectionCell
        
        XCTAssertEqual(suggestion4Text, suggestionCollectionCell.suggestionText.text, "fourth suggestionsCollectionView item text should be equal to fourth captureSuggestions item text")
        XCTAssertEqual(suggestion4Image, suggestionCollectionCell.suggestionImage.image, "fourth suggestionsCollectionView item image should be equal to fourth captureSuggestions item image")
        
    }
    
    func testWarningIconColor() {
        let giniConfigurationColor = GiniConfiguration.sharedConfiguration.noResultsWarningContainerIconColor
        
        let warningBackgroundColor = viewController.warningViewIcon.tintColor
        
        XCTAssertEqual(giniConfigurationColor, warningBackgroundColor, "warningViewContainerItem tint color should be the one declared in the GiniConfiguration file")
    }
    
    func testNoCollectionHeaderWhenNoTitle() {
        viewController = ImageAnalysisNoResultsViewController(collectionHeader: nil)
        _ = viewController.view
        
        XCTAssertEqual(viewController.collectionView(viewController.suggestionsCollectionView, layout: viewController.suggestionsCollectionView.collectionViewLayout, referenceSizeForHeaderInSection: 0), CGSize.zero, "when there is no title for collection the header size should be (0,0)")
    }
    
    func testNoWarningIconWhenNoImage() {
        viewController = ImageAnalysisNoResultsViewController(warningIcon: nil)
        _ = viewController.view
        
        let warningIcon = viewController.warningViewIcon
        
        XCTAssertFalse(viewController.warningViewContainer.subviews.contains(warningIcon))
    }
    
    func testNoBottomButtonWhenNoText() {
        viewController = ImageAnalysisNoResultsViewController(bottomButtonText: nil)
        _ = viewController.view
        
        let bottomButton = viewController.bottomButton
        
        XCTAssertFalse(viewController.view.subviews.contains(bottomButton))
    }
}
