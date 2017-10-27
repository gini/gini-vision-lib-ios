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
    lazy var items: [(image: UIImage?, text: String)] = [
        (UIImageNamedPreferred(named: "captureSuggestion1"), NSLocalizedString("ginivision.analysis.suggestion.1", bundle: Bundle(for: GiniVision.self), comment: "First suggestion for analysis screen")),
        (UIImageNamedPreferred(named: "captureSuggestion2"), NSLocalizedString("ginivision.analysis.suggestion.2", bundle: Bundle(for: GiniVision.self), comment: "Second suggestion for analysis screen")),
        (UIImageNamedPreferred(named: "captureSuggestion3"), NSLocalizedString("ginivision.analysis.suggestion.3", bundle: Bundle(for: GiniVision.self), comment: "Third suggestion for analysis screen")),
        (UIImageNamedPreferred(named: "captureSuggestion4"), NSLocalizedString("ginivision.analysis.suggestion.4", bundle: Bundle(for: GiniVision.self), comment: "Forth suggestion for analysis screen"))
    ]
    
    override func setUp() {
        _ = viewController.view
    }
    
    func testViewControllerTitleOnInitialization() {
        let vcTitle = viewController.title
        
        XCTAssertEqual(viewControllerTitle, vcTitle, "view controller title should be equals to the one passed in the initialization")
    }
    
    func testSuggestionCollectionItemsCount(){
        let suggestionsCount = items.count
        
        let suggestionsCollectionItemsCount = viewController.collectionView(viewController.suggestionsCollectionView, numberOfItemsInSection: 0)
        
        XCTAssertEqual(suggestionsCount, suggestionsCollectionItemsCount, "suggestionsCollectionView items count should be equal to captureSuggestions array count")
    }
    
    func testFirstSuggestionCell() {
        let indexPath = IndexPath(row: 0, section: 0)
        
        let suggestion1Text = items[indexPath.row].text
        let suggestion1Image = items[indexPath.row].image
        
        let suggestionCollectionCell = viewController.collectionView(viewController.suggestionsCollectionView, cellForItemAt: indexPath) as! CaptureSuggestionsCollectionCell
        
        XCTAssertEqual(suggestion1Text, suggestionCollectionCell.suggestionText.text, "first suggestionsCollectionView item text should be equal to first captureSuggestions item text")
        XCTAssertEqual(suggestion1Image, suggestionCollectionCell.suggestionImage.image, "first suggestionsCollectionView item image should be equal to first captureSuggestions item image")

    }
    
    func testSecondSuggestionCell() {
        let indexPath = IndexPath(row: 1, section: 0)
        
        let suggestion2Text = items[indexPath.row].text
        let suggestion2Image = items[indexPath.row].image
        
        let suggestionCollectionCell = viewController.collectionView(viewController.suggestionsCollectionView, cellForItemAt: indexPath) as! CaptureSuggestionsCollectionCell
        
        XCTAssertEqual(suggestion2Text, suggestionCollectionCell.suggestionText.text, "second suggestionsCollectionView item text should be equal to second captureSuggestions item text")
        XCTAssertEqual(suggestion2Image, suggestionCollectionCell.suggestionImage.image, "second suggestionsCollectionView item image should be equal to second captureSuggestions item image")
        
    }
    
    func testThirdSuggestionCell() {
        let indexPath = IndexPath(row: 2, section: 0)
        
        let suggestion3Text = items[indexPath.row].text
        let suggestion3Image = items[indexPath.row].image
        
        let suggestionCollectionCell = viewController.collectionView(viewController.suggestionsCollectionView, cellForItemAt: indexPath) as! CaptureSuggestionsCollectionCell
        
        XCTAssertEqual(suggestion3Text, suggestionCollectionCell.suggestionText.text, "third suggestionsCollectionView item text should be equal to third captureSuggestions item text")
        XCTAssertEqual(suggestion3Image, suggestionCollectionCell.suggestionImage.image, "third suggestionsCollectionView item image should be equal to third captureSuggestions item image")
        
    }
    
    func testFourthSuggestionCell() {
        let indexPath = IndexPath(row: 3, section: 0)
        
        let suggestion4Text = items[indexPath.row].text
        let suggestion4Image = items[indexPath.row].image
        
        let suggestionCollectionCell = viewController.collectionView(viewController.suggestionsCollectionView, cellForItemAt: indexPath) as! CaptureSuggestionsCollectionCell
        
        XCTAssertEqual(suggestion4Text, suggestionCollectionCell.suggestionText.text, "fourth suggestionsCollectionView item text should be equal to fourth captureSuggestions item text")
        XCTAssertEqual(suggestion4Image, suggestionCollectionCell.suggestionImage.image, "fourth suggestionsCollectionView item image should be equal to fourth captureSuggestions item image")
        
    }
    
    func testNoBottomButtonWhenNoText() {
        viewController = ImageAnalysisNoResultsViewController(bottomButtonText: nil)
        _ = viewController.view
        
        let bottomButton = viewController.bottomButton
        
        XCTAssertFalse(viewController.view.subviews.contains(bottomButton))
    }
}
