//
//  NoResultsViewController.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 10/6/17.
//

import Foundation
import UIKit

/**
 The `NoResultsViewController` provides a custom no results screen which shows some capture suggestions when there is no results when analysing an image.
 
 **Text resources for this screen**
 
 * `ginivision.noresults.warning`
 
 - note: Setting `ginivision.navigationbar.analysis.back` explicitly to the empty string in your localized strings will make `AnalysisViewController` revert to the default iOS back button.
 
 **Image resources for this screen**
 
 * `repeatAnalysis`
 * `warningNoResults`
 * `captureSuggestion1`
 * `captureSuggestion2`
 * `captureSuggestion3`
 * `captureSuggestion4`
 */

public final class NoResultsViewController: UIViewController {
    
    // Views
    fileprivate var warningViewContainer: UIView = {
        let container = UIView()
        container.backgroundColor = GiniConfiguration.sharedConfiguration.noResultsWarningContainerBackgroundColor
        return container
    }()
    fileprivate var warningViewIcon: UIImageView = {
        let icon = UIImageView(image: UIImageNamedPreferred(named: "warningNoResults"))
        icon.contentMode = .scaleAspectFit
        return icon
    }()
    fileprivate var warningViewText: UILabel = {
        let text = UILabel()
        text.numberOfLines = 0
        text.text = NSLocalizedStringPreferred("ginivision.noresults.warning", comment: "Warning text that indicates that there was any result for this photo analysis")
        text.textColor = .white
        return text
    }()
    fileprivate var suggestionsCollectionView: CaptureSuggestionsCollectionView = CaptureSuggestionsCollectionView()
    fileprivate var repeatAnalysisButton: UIButton = {
        let repeatButton = UIButton()
        repeatButton.setTitle("Aufnahme wiederholen", for: .normal)
        repeatButton.setImage(UIImageNamedPreferred(named: "repeatAnalysis"), for: .normal)
        repeatButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 20)
        repeatButton.backgroundColor = .black
        return repeatButton
    }()
    
    fileprivate let captureTips: [(image: UIImage?, text: String)] = [
        (UIImageNamedPreferred(named: "captureSuggestion1"), NSLocalizedString("ginivision.analysis.suggestion.1", bundle: Bundle(for: GiniVision.self), comment: "First suggestion for analysis screen")),
        (UIImageNamedPreferred(named: "captureSuggestion3"), NSLocalizedString("ginivision.analysis.suggestion.3", bundle: Bundle(for: GiniVision.self), comment: "Third suggestion for analysis screen")),
        (UIImageNamedPreferred(named: "captureSuggestion4"), NSLocalizedString("ginivision.analysis.suggestion.4", bundle: Bundle(for: GiniVision.self), comment: "Forth suggestion for analysis screen")),
        (UIImageNamedPreferred(named: "captureSuggestion2"), NSLocalizedString("ginivision.analysis.suggestion.2", bundle: Bundle(for: GiniVision.self), comment: "Second suggestion for analysis screen"))
    ]
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        edgesForExtendedLayout = []
        
        suggestionsCollectionView.dataSource = self
        suggestionsCollectionView.delegate = self
        
        warningViewContainer.addSubview(warningViewIcon)
        warningViewContainer.addSubview(warningViewText)
        view.addSubview(warningViewContainer)
        view.addSubview(suggestionsCollectionView)
        view.addSubview(repeatAnalysisButton)
        addConstraints()
        addConstraintsWarningView()
    }
    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { _ in
            self.suggestionsCollectionView.collectionViewLayout.invalidateLayout()
        }, completion: nil)
    }
    
    fileprivate func addConstraints() {
        suggestionsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        repeatAnalysisButton.translatesAutoresizingMaskIntoConstraints = false
        
        ConstraintUtils.addActiveConstraint(item: self.view, attribute: .bottom, relatedBy: .equal, toItem: repeatAnalysisButton, attribute: .bottom, multiplier: 1.0, constant: 0)
        ConstraintUtils.addActiveConstraint(item: self.view, attribute: .leading, relatedBy: .equal, toItem: repeatAnalysisButton, attribute: .leading, multiplier: 1.0, constant: 0)
        ConstraintUtils.addActiveConstraint(item: self.view, attribute: .trailing, relatedBy: .equal, toItem: repeatAnalysisButton, attribute: .trailing, multiplier: 1.0, constant: 0)
        ConstraintUtils.addActiveConstraint(item: repeatAnalysisButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 60)
        
        ConstraintUtils.addActiveConstraint(item: suggestionsCollectionView, attribute: .top, relatedBy: .equal, toItem: warningViewContainer, attribute: .bottom, multiplier: 1.0, constant: 0)
        ConstraintUtils.addActiveConstraint(item: suggestionsCollectionView, attribute: .bottom, relatedBy: .equal, toItem: repeatAnalysisButton, attribute: .top, multiplier: 1.0, constant: 0)
        ConstraintUtils.addActiveConstraint(item: self.view, attribute: .leading, relatedBy: .equal, toItem: suggestionsCollectionView, attribute: .leading, multiplier: 1.0, constant: 0)
        ConstraintUtils.addActiveConstraint(item: self.view, attribute: .trailing, relatedBy: .equal, toItem: suggestionsCollectionView, attribute: .trailing, multiplier: 1.0, constant: 0)
        ConstraintUtils.addActiveConstraint(item: repeatAnalysisButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 60)
    }
    
    fileprivate func addConstraintsWarningView() {
        warningViewContainer.translatesAutoresizingMaskIntoConstraints = false
        warningViewText.translatesAutoresizingMaskIntoConstraints = false
        warningViewIcon.translatesAutoresizingMaskIntoConstraints = false
        
        ConstraintUtils.addActiveConstraint(item: self.view, attribute: .top, relatedBy: .equal, toItem: warningViewContainer, attribute: .top, multiplier: 1.0, constant: 0)
        ConstraintUtils.addActiveConstraint(item: self.view, attribute: .leading, relatedBy: .equal, toItem: warningViewContainer, attribute: .leading, multiplier: 1.0, constant: 0)
        ConstraintUtils.addActiveConstraint(item: self.view, attribute: .trailing, relatedBy: .equal, toItem: warningViewContainer, attribute: .trailing, multiplier: 1.0, constant: 0)
        ConstraintUtils.addActiveConstraint(item: warningViewContainer, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 100)
        
        ConstraintUtils.addActiveConstraint(item: warningViewIcon, attribute: .top, relatedBy: .equal, toItem: warningViewContainer, attribute: .top, multiplier: 1.0, constant: 16)
        ConstraintUtils.addActiveConstraint(item: warningViewIcon, attribute: .bottom, relatedBy: .equal, toItem: warningViewContainer, attribute: .bottom, multiplier: 1.0, constant: -16)
        ConstraintUtils.addActiveConstraint(item: warningViewIcon, attribute: .leading, relatedBy: .equal, toItem: warningViewContainer, attribute: .leading, multiplier: 1.0, constant: 16)
        ConstraintUtils.addActiveConstraint(item: warningViewIcon, attribute: .trailing, relatedBy: .equal, toItem: warningViewText, attribute: .leading, multiplier: 1.0, constant: -16)
        ConstraintUtils.addActiveConstraint(item: warningViewIcon, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 25)
        
        ConstraintUtils.addActiveConstraint(item: warningViewText, attribute: .top, relatedBy: .equal, toItem: warningViewContainer, attribute: .top, multiplier: 1.0, constant: 16)
        ConstraintUtils.addActiveConstraint(item: warningViewText, attribute: .bottom, relatedBy: .equal, toItem: warningViewContainer, attribute: .bottom, multiplier: 1.0, constant: -16)
        ConstraintUtils.addActiveConstraint(item: warningViewText, attribute: .trailing, relatedBy: .equal, toItem: warningViewContainer, attribute: .trailing, multiplier: 1.0, constant: -16, priority: 999)
        
    }
}

// MARK: UICollectionViewDataSource

extension NoResultsViewController: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return captureTips.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CaptureSuggestionsCollectionView.cellIdentifier, for: indexPath) as! CaptureSuggestionsCollectionCell
        cell.suggestionText.text = self.captureTips[indexPath.row].text
        cell.suggestionImage.image = self.captureTips[indexPath.row].image
        return cell
    }
}

// MARK: UICollectionViewDelegateFlowLayout

extension NoResultsViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return suggestionsCollectionView.cellSize()
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return suggestionsCollectionView.headerSize()
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: CaptureSuggestionsCollectionView.headerIdentifier, for: indexPath)
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 0 {
            scrollView.contentOffset = .zero
        }
        
    }
}
