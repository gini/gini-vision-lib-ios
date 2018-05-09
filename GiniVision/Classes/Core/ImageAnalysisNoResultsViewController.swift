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
 The `ImageAnalysisNoResultsViewController` provides a custom no results screen which shows some capture
 suggestions when there is no results when analysing an image.
 
 **Text resources for this screen**
 
 * `ginivision.noresults.warning`
 
 - note: Setting `ginivision.navigationbar.analysis.back` explicitly to the empty string in your localized
         strings will make `AnalysisViewController` revert to the default iOS back button.
 
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
        bottomButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20)
        bottomButton.backgroundColor = GiniConfiguration.shared.noResultsBottomButtonColor
        return bottomButton
    }()
    
    var captureSuggestions: [(image: UIImage?, text: String)] = [
        (UIImageNamedPreferred(named: "captureSuggestion1"),
         NSLocalizedString("ginivision.analysis.suggestion.1", bundle: Bundle(for: GiniVision.self),
                           comment: "First suggestion for analysis screen")),
        (UIImageNamedPreferred(named: "captureSuggestion2"),
         NSLocalizedString("ginivision.analysis.suggestion.2", bundle: Bundle(for: GiniVision.self),
                           comment: "Second suggestion for analysis screen")),
        (UIImageNamedPreferred(named: "captureSuggestion3"),
         NSLocalizedString("ginivision.analysis.suggestion.3", bundle: Bundle(for: GiniVision.self),
                           comment: "Third suggestion for analysis screen")),
        (UIImageNamedPreferred(named: "captureSuggestion4"),
         NSLocalizedString("ginivision.analysis.suggestion.4", bundle: Bundle(for: GiniVision.self),
                           comment: "Forth suggestion for analysis screen")),
        (UIImageNamedPreferred(named: "captureSuggestion5"),
         NSLocalizedString("ginivision.analysis.suggestion.5", bundle: Bundle(for: GiniVision.self),
                           comment: "Fifth suggestion for analysis screen"))
    ]
    
    fileprivate var subHeaderTitle: String?
    fileprivate var topViewText: String?
    fileprivate var topViewIcon: UIImage?
    fileprivate var bottomButtonText: String?
    fileprivate var bottomButtonIconImage: UIImage?
    
    public var didTapBottomButton: (() -> Void) = { }
    
    public init(title: String? = nil,
                subHeaderText: String? = NSLocalizedString("ginivision.noresults.collection.header",
                                                           bundle: Bundle(for: GiniVision.self),
                                                           comment: "no results suggestions collection header title"),
                topViewText: String = NSLocalizedString("ginivision.noresults.warning",
                                                        bundle: Bundle(for: GiniVision.self),
                                                        comment: "Warning text that indicates that there was any " +
                                                                 "result for this photo analysis"),
                topViewIcon: UIImage? = UIImage(named: "warningNoResults",
                                                in: Bundle(for: GiniVision.self),
                                                compatibleWith: nil)?.withRenderingMode(.alwaysTemplate),
                bottomButtonText: String? = NSLocalizedString("ginivision.noresults.gotocamera",
                                                              bundle: Bundle(for: GiniVision.self),
                                                              comment: "bottom button title (go to camera button)"),
                bottomButtonIcon: UIImage? = UIImage(named: "cameraIcon",
                                                     in: Bundle(for: GiniVision.self),
                                                     compatibleWith: nil)) {
        super.init(nibName: nil, bundle: nil)
        self.title = title
        self.subHeaderTitle = subHeaderText
        self.topViewText = topViewText
        self.topViewIcon = topViewIcon
        self.bottomButtonText = bottomButtonText
        self.bottomButtonIconImage = bottomButtonIcon
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(title:subHeaderText:topViewText:topViewIcon:bottomButtonText:bottomButtonIcon:)" +
            "has not been implemented")
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
        Constraints.active(item: suggestionsCollectionView, attr: .top, relatedBy: .equal, to: self.view, attr: .top)
        Constraints.active(item: self.view, attr: .leading, relatedBy: .equal, to: suggestionsCollectionView,
                          attr: .leading)
        Constraints.active(item: self.view, attr: .trailing, relatedBy: .equal, to: suggestionsCollectionView,
                          attr: .trailing)
        
        // Button
        if bottomButtonText != nil {
            Constraints.active(item: self.bottomLayoutGuide, attr: .top, relatedBy: .equal, to: bottomButton,
                              attr: .bottom, constant: 20)
            Constraints.active(item: self.view, attr: .leading, relatedBy: .equal, to: bottomButton, attr: .leading,
                              constant: -20, priority: 999)
            Constraints.active(item: self.view, attr: .trailing, relatedBy: .equal, to: bottomButton, attr: .trailing,
                              constant: 20, priority: 999)
            Constraints.active(item: self.view, attr: .centerX, relatedBy: .equal, to: bottomButton, attr: .centerX)
            Constraints.active(item: bottomButton, attr: .height, relatedBy: .equal, to: nil, attr: .notAnAttribute,
                              constant: 60)
            Constraints.active(item: bottomButton, attr: .width, relatedBy: .lessThanOrEqual, to: nil,
                              attr: .notAnAttribute, constant: 375)
            Constraints.active(item: bottomButton, attr: .top, relatedBy: .equal, to: suggestionsCollectionView,
                              attr: .bottom, constant: 0, priority: 999)
        } else {
            Constraints.active(item: self.view, attr: .bottom, relatedBy: .equal, to: suggestionsCollectionView,
                              attr: .bottom, constant: 0, priority: 999)
        }

    }
    
    // MARK: Button action
    @objc func didTapBottomButtonAction() {
        didTapBottomButton()
    }
}

// MARK: UICollectionViewDataSource

extension ImageAnalysisNoResultsViewController: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return captureSuggestions.count
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = CaptureSuggestionsCollectionView.captureSuggestionsCellIdentifier
        let cell = (collectionView.dequeueReusableCell(withReuseIdentifier: identifier,
                                                      for: indexPath) as? CaptureSuggestionsCollectionCell)!
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
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {
        return suggestionsCollectionView.cellSize()
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               referenceSizeForHeaderInSection section: Int) -> CGSize {
        return suggestionsCollectionView.headerSize(withSubHeader: subHeaderTitle != nil)
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               viewForSupplementaryElementOfKind kind: String,
                               at indexPath: IndexPath) -> UICollectionReusableView {
        let identifier = CaptureSuggestionsCollectionView.captureSuggestionsHeaderIdentifier
        let header = (collectionView
            .dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader,
                                              withReuseIdentifier: identifier,
                                              for: indexPath) as? CaptureSuggestionsCollectionHeader)!
        header.subHeaderTitle.text = self.subHeaderTitle
        header.topViewIcon.image = self.topViewIcon
        header.topViewText.text = self.topViewText
        header.shouldShowTopViewIcon = topViewIcon != nil
        header.shouldShowSubHeader = subHeaderTitle != nil
        return header
    }
}
