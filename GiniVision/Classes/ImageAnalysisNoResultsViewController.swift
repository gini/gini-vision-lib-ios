//
//  ImageAnalysisNoResultsViewController.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 10/6/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import Foundation
import UIKit

/**
 The `ImageAnalysisNoResultsViewController` provides a custom no results screen which shows some capture suggestions when there is no results when analysing an image.
 
 **Text resources for this screen**
 
 * `ginivision.noresults.warning`
 
 - note: Setting `ginivision.navigationbar.analysis.back` explicitly to the empty string in your localized strings will make `AnalysisViewController` revert to the default iOS back button.
 
 **Image resources for this screen**
 
 * `captureSuggestion1`
 * `captureSuggestion2`
 * `captureSuggestion3`
 * `captureSuggestion4`
 */

public final class ImageAnalysisNoResultsViewController: UIViewController {

    lazy var suggestionsCollectionView: CaptureSuggestionsCollectionView = {
        let collection = CaptureSuggestionsCollectionView()
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()
    lazy var bottomButton: UIButton = {
        let bottomButton = UIButton()
        bottomButton.translatesAutoresizingMaskIntoConstraints = false
        bottomButton.setTitle(self.bottomButtonText, for: .normal)
        bottomButton.setTitleColor(UIColor.white.withAlphaComponent(0.5), for: .highlighted)
        bottomButton.setImage(self.bottomButtonIconImage, for: .normal)
        bottomButton.addTarget(self, action: #selector(didTapBottomButtonAction), for: .touchUpInside)
        bottomButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 20)
        bottomButton.backgroundColor = GiniConfiguration.sharedConfiguration.noResultsBottomButtonColor
        return bottomButton
    }()
    
    var captureSuggestions: [(image: UIImage?, text: String)] = [
        (UIImageNamedPreferred(named: "captureSuggestion1"), NSLocalizedString("ginivision.analysis.suggestion.1", bundle: Bundle(for: GiniVision.self), comment: "First suggestion for analysis screen")),
        (UIImageNamedPreferred(named: "captureSuggestion2"), NSLocalizedString("ginivision.analysis.suggestion.2", bundle: Bundle(for: GiniVision.self), comment: "Second suggestion for analysis screen")),
        (UIImageNamedPreferred(named: "captureSuggestion3"), NSLocalizedString("ginivision.analysis.suggestion.3", bundle: Bundle(for: GiniVision.self), comment: "Third suggestion for analysis screen")),
        (UIImageNamedPreferred(named: "captureSuggestion4"), NSLocalizedString("ginivision.analysis.suggestion.4", bundle: Bundle(for: GiniVision.self), comment: "Forth suggestion for analysis screen"))
    ]
    
    fileprivate var subHeaderTitle: String?
    fileprivate var topViewText: String?
    fileprivate var topViewIcon: UIImage?
    fileprivate var bottomButtonText: String?
    fileprivate var bottomButtonIconImage: UIImage?
    
    public var didTapBottomButton: (() -> ()) = { }
    
    public init(title:String? = nil,
                subHeaderText: String? = NSLocalizedString("ginivision.noresults.collection.header", bundle: Bundle(for: GiniVision.self), comment: "no results suggestions collection header title"),
                topViewText: String = NSLocalizedString("ginivision.noresults.warning", bundle: Bundle(for: GiniVision.self), comment: "Warning text that indicates that there was any result for this photo analysis"),
                topViewIcon: UIImage? = UIImage(named: "warningNoResults", in: Bundle(for: GiniVision.self), compatibleWith: nil)?.withRenderingMode(UIImageRenderingMode.alwaysTemplate),
                bottomButtonText: String? = NSLocalizedString("ginivision.noresults.gotocamera", bundle: Bundle(for: GiniVision.self), comment: "bottom button title (go to camera button)"),
                bottomButtonIcon: UIImage? = UIImage(named: "cameraIcon", in: Bundle(for: GiniVision.self), compatibleWith: nil)) {
        super.init(nibName: nil, bundle: nil)
        self.title = title
        self.subHeaderTitle = subHeaderText
        self.topViewText = topViewText
        self.topViewIcon = topViewIcon
        self.bottomButtonText = bottomButtonText
        self.bottomButtonIconImage = bottomButtonIcon
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(title:subHeaderText:topViewText:topViewIcon:bottomButtonText:bottomButtonIcon:) has not been implemented")
    }
    
    public override func loadView() {
        super.loadView()
        view.backgroundColor = .white
        edgesForExtendedLayout = []
        
        view.addSubview(suggestionsCollectionView)
        
        if bottomButtonText != nil {
            view.addSubview(bottomButton)
        }
        addConstraints()
        
        suggestionsCollectionView.dataSource = self
        suggestionsCollectionView.delegate = self
    }
    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { _ in
            self.suggestionsCollectionView.collectionViewLayout.invalidateLayout()
        }, completion: nil)
    }
    
    fileprivate func addConstraints() {
        
        // Collection View
        ConstraintUtils.addActiveConstraint(item: suggestionsCollectionView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 0)
        ConstraintUtils.addActiveConstraint(item: self.view, attribute: .leading, relatedBy: .equal, toItem: suggestionsCollectionView, attribute: .leading, multiplier: 1.0, constant: 0)
        ConstraintUtils.addActiveConstraint(item: self.view, attribute: .trailing, relatedBy: .equal, toItem: suggestionsCollectionView, attribute: .trailing, multiplier: 1.0, constant: 0)
        
        // Button
        if bottomButtonText != nil {
            ConstraintUtils.addActiveConstraint(item: self.view, attribute: .bottom, relatedBy: .equal, toItem: bottomButton, attribute: .bottom, multiplier: 1.0, constant: 20)
            ConstraintUtils.addActiveConstraint(item: self.view, attribute: .leading, relatedBy: .equal, toItem: bottomButton, attribute: .leading, multiplier: 1.0, constant: -20, priority: 999)
            ConstraintUtils.addActiveConstraint(item: self.view, attribute: .trailing, relatedBy: .equal, toItem: bottomButton, attribute: .trailing, multiplier: 1.0, constant: 20, priority: 999)
            ConstraintUtils.addActiveConstraint(item: self.view, attribute: .centerX, relatedBy: .equal, toItem: bottomButton, attribute: .centerX, multiplier: 1.0, constant: 0)
            ConstraintUtils.addActiveConstraint(item: bottomButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 60)
            ConstraintUtils.addActiveConstraint(item: bottomButton, attribute: .width, relatedBy: .lessThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 375)
            ConstraintUtils.addActiveConstraint(item: bottomButton, attribute: .top, relatedBy: .equal, toItem: suggestionsCollectionView, attribute: .bottom, multiplier: 1.0, constant:0, priority: 999)
        } else {
            ConstraintUtils.addActiveConstraint(item: self.view, attribute: .bottom, relatedBy: .equal, toItem: suggestionsCollectionView, attribute: .bottom, multiplier: 1.0, constant:0, priority: 999)
        }

    }
    
    // MARK: Button action
    func didTapBottomButtonAction() {
        didTapBottomButton()
    }
}

// MARK: UICollectionViewDataSource

extension ImageAnalysisNoResultsViewController: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return captureSuggestions.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CaptureSuggestionsCollectionView.captureSuggestionsCellIdentifier, for: indexPath) as! CaptureSuggestionsCollectionCell
        cell.suggestionText.text = self.captureSuggestions[indexPath.row].text
        cell.suggestionImage.image = self.captureSuggestions[indexPath.row].image
        return cell
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
}

// MARK: UICollectionViewDelegateFlowLayout

extension ImageAnalysisNoResultsViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return suggestionsCollectionView.cellSize()
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return suggestionsCollectionView.headerSize(withSubHeader: subHeaderTitle != nil)
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: CaptureSuggestionsCollectionView.captureSuggestionsHeaderIdentifier, for: indexPath) as! CaptureSuggestionsCollectionHeader
        header.subHeaderTitle.text = self.subHeaderTitle
        header.topViewIcon.image = self.topViewIcon
        header.topViewText.text = self.topViewText
        header.shouldShowTopViewIcon = topViewIcon != nil
        header.shouldShowSubHeader = subHeaderTitle != nil
        return header
    }
}
