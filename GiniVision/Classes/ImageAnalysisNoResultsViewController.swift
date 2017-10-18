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
    
    // Views
    lazy var warningViewContainer: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }()
    lazy var warningViewContainerBottomLine: UIView = {
        let line = UIView()
        line.translatesAutoresizingMaskIntoConstraints = false
        line.backgroundColor = .lightGray
        return line
    }()
    lazy var warningViewIcon: UIImageView = {
        let icon = UIImageView(image: self.warningIconImage)
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.contentMode = .scaleAspectFit
        icon.tintColor = GiniConfiguration.sharedConfiguration.noResultsWarningContainerIconColor
        return icon
    }()
    lazy var warningViewText: UILabel = {
        let text = UILabel()
        text.translatesAutoresizingMaskIntoConstraints = false
        text.numberOfLines = 0
        text.text = self.warningText
        return text
    }()
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
    
    let captureSuggestions: [(image: UIImage?, text: String)] = [
        (UIImageNamedPreferred(named: "captureSuggestion1"), NSLocalizedString("ginivision.analysis.suggestion.1", bundle: Bundle(for: GiniVision.self), comment: "First suggestion for analysis screen")),
        (UIImageNamedPreferred(named: "captureSuggestion2"), NSLocalizedString("ginivision.analysis.suggestion.2", bundle: Bundle(for: GiniVision.self), comment: "Second suggestion for analysis screen")),
        (UIImageNamedPreferred(named: "captureSuggestion3"), NSLocalizedString("ginivision.analysis.suggestion.3", bundle: Bundle(for: GiniVision.self), comment: "Third suggestion for analysis screen")),
        (UIImageNamedPreferred(named: "captureSuggestion4"), NSLocalizedString("ginivision.analysis.suggestion.4", bundle: Bundle(for: GiniVision.self), comment: "Forth suggestion for analysis screen"))
    ]
    
    fileprivate var suggestionsTitle: String?
    fileprivate var warningText: String?
    fileprivate var warningIconImage: UIImage?
    fileprivate var bottomButtonText: String?
    fileprivate var bottomButtonIconImage: UIImage?
    
    public var didTapBottomButton: (() -> ()) = { }
    
    public init(suggestionsTitle: String? = "Tipps für bessere Foto",
                warningText: String = NSLocalizedStringPreferred("ginivision.noresults.warning", comment: "Warning text that indicates that there was any result for this photo analysis"),
                warningIcon: UIImage? = UIImage(named: "warningNoResults", in: Bundle(for: GiniVision.self), compatibleWith: nil)?.withRenderingMode(UIImageRenderingMode.alwaysTemplate),
                bottomButtonText: String? = "Zur Kamera",
                bottomButtonIcon: UIImage? = UIImage(named: "cameraIcon", in: Bundle(for: GiniVision.self), compatibleWith: nil)) {
        super.init(nibName: nil, bundle: nil)
        self.suggestionsTitle = suggestionsTitle
        self.warningText = warningText
        self.warningIconImage = warningIcon
        self.bottomButtonText = bottomButtonText
        self.bottomButtonIconImage = bottomButtonIcon
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(suggestionsTitle:warningText:warningIcon:) has not been implemented")
    }
    
    public override func loadView() {
        super.loadView()
        view.backgroundColor = .white
        edgesForExtendedLayout = []
        
        warningViewContainer.addSubview(warningViewContainerBottomLine)
        warningViewContainer.addSubview(warningViewText)
        if warningIconImage != nil {
            warningViewContainer.addSubview(warningViewIcon)
        }
        
        view.addSubview(warningViewContainer)
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
        
        // Button
        if bottomButtonText != nil {
            ConstraintUtils.addActiveConstraint(item: self.view, attribute: .bottom, relatedBy: .equal, toItem: bottomButton, attribute: .bottom, multiplier: 1.0, constant: 20)
            ConstraintUtils.addActiveConstraint(item: self.view, attribute: .leading, relatedBy: .equal, toItem: bottomButton, attribute: .leading, multiplier: 1.0, constant: -20)
            ConstraintUtils.addActiveConstraint(item: self.view, attribute: .trailing, relatedBy: .equal, toItem: bottomButton, attribute: .trailing, multiplier: 1.0, constant: 20, priority: 999)
            ConstraintUtils.addActiveConstraint(item: bottomButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 60)
            ConstraintUtils.addActiveConstraint(item: bottomButton, attribute: .top, relatedBy: .equal, toItem: suggestionsCollectionView, attribute: .bottom, multiplier: 1.0, constant:0, priority: 999)
        } else {
            ConstraintUtils.addActiveConstraint(item: self.view, attribute: .bottom, relatedBy: .equal, toItem: suggestionsCollectionView, attribute: .bottom, multiplier: 1.0, constant:0, priority: 999)
        }
        
        // Collection View
        ConstraintUtils.addActiveConstraint(item: suggestionsCollectionView, attribute: .top, relatedBy: .equal, toItem: warningViewContainer, attribute: .bottom, multiplier: 1.0, constant: 0)
        ConstraintUtils.addActiveConstraint(item: self.view, attribute: .leading, relatedBy: .equal, toItem: suggestionsCollectionView, attribute: .leading, multiplier: 1.0, constant: 0)
        ConstraintUtils.addActiveConstraint(item: self.view, attribute: .trailing, relatedBy: .equal, toItem: suggestionsCollectionView, attribute: .trailing, multiplier: 1.0, constant: 0)
        
        // Top warning view
        ConstraintUtils.addActiveConstraint(item: warningViewContainerBottomLine, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0.5)
        ConstraintUtils.addActiveConstraint(item: warningViewContainerBottomLine, attribute: .width, relatedBy: .equal, toItem: warningViewContainer, attribute: .width, multiplier: 1.0, constant: 0)
        ConstraintUtils.addActiveConstraint(item: warningViewContainerBottomLine, attribute: .bottom, relatedBy: .equal, toItem: warningViewContainer, attribute: .bottom, multiplier: 1.0, constant: 0)
        
        // Warning Container
        ConstraintUtils.addActiveConstraint(item: self.view, attribute: .top, relatedBy: .equal, toItem: warningViewContainer, attribute: .top, multiplier: 1.0, constant: 0)
        ConstraintUtils.addActiveConstraint(item: self.view, attribute: .leading, relatedBy: .equal, toItem: warningViewContainer, attribute: .leading, multiplier: 1.0, constant: 0)
        ConstraintUtils.addActiveConstraint(item: self.view, attribute: .trailing, relatedBy: .equal, toItem: warningViewContainer, attribute: .trailing, multiplier: 1.0, constant: 0)
        ConstraintUtils.addActiveConstraint(item: warningViewContainer, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 100)
        
        // Warning Icon
        if warningIconImage != nil {
            ConstraintUtils.addActiveConstraint(item: warningViewIcon, attribute: .top, relatedBy: .equal, toItem: warningViewContainer, attribute: .top, multiplier: 1.0, constant: 16)
            ConstraintUtils.addActiveConstraint(item: warningViewIcon, attribute: .bottom, relatedBy: .equal, toItem: warningViewContainer, attribute: .bottom, multiplier: 1.0, constant: -16)
            ConstraintUtils.addActiveConstraint(item: warningViewIcon, attribute: .leading, relatedBy: .equal, toItem: warningViewContainer, attribute: .leading, multiplier: 1.0, constant: 16)
            ConstraintUtils.addActiveConstraint(item: warningViewIcon, attribute: .trailing, relatedBy: .equal, toItem: warningViewText, attribute: .leading, multiplier: 1.0, constant: -16)
            ConstraintUtils.addActiveConstraint(item: warningViewIcon, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 25)
        } else {
            ConstraintUtils.addActiveConstraint(item: warningViewText, attribute: .leading, relatedBy: .equal, toItem: warningViewContainer, attribute: .leading, multiplier: 1.0, constant: 16)
        }
        
        // Warning text
        ConstraintUtils.addActiveConstraint(item: warningViewText, attribute: .top, relatedBy: .equal, toItem: warningViewContainer, attribute: .top, multiplier: 1.0, constant: 16)
        ConstraintUtils.addActiveConstraint(item: warningViewText, attribute: .bottom, relatedBy: .equal, toItem: warningViewContainer, attribute: .bottom, multiplier: 1.0, constant: -16)
        ConstraintUtils.addActiveConstraint(item: warningViewText, attribute: .trailing, relatedBy: .equal, toItem: warningViewContainer, attribute: .trailing, multiplier: 1.0, constant: -16, priority: 999)
        
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CaptureSuggestionsCollectionView.cellIdentifier, for: indexPath) as! CaptureSuggestionsCollectionCell
        cell.suggestionText.text = self.captureSuggestions[indexPath.row].text
        cell.suggestionImage.image = self.captureSuggestions[indexPath.row].image
        return cell
    }
}

// MARK: UICollectionViewDelegateFlowLayout

extension ImageAnalysisNoResultsViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return suggestionsCollectionView.cellSize()
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if self.suggestionsTitle != nil {
            return suggestionsCollectionView.headerSize()
        }
        return .zero
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: CaptureSuggestionsCollectionView.headerIdentifier, for: indexPath) as! CaptureSuggestionsCollectionHeader
        header.headerTitle.text = self.suggestionsTitle
        return header
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 0 {
            scrollView.contentOffset = .zero
        }
    }
}


