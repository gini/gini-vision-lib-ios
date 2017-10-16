//
//  NoResultsViewController.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 10/6/17.
//

import Foundation
import UIKit

public final class NoResultsViewController: UIViewController {
    
    // Views
    fileprivate var warningViewContainer: UIView = {
        let container = UIView()
        container.backgroundColor = UIColor(red:0.99, green:0.42, blue:0.49, alpha:1)
        return container
    }()
    fileprivate var warningViewIcon: UIImageView = {
        let closeButtonResources = PreferredButtonResource(image: "navigationCameraClose", title: "ginivision.navigationbar.camera.close", comment: "Button title in the navigation bar for the close button on the camera screen", configEntry: GiniConfiguration.sharedConfiguration.navigationBarCameraTitleCloseButton)
        let icon = UIImageView(image: closeButtonResources.preferredImage)
        icon.contentMode = .scaleAspectFit
        return icon
    }()
    fileprivate var warningViewText: UILabel = {
        let text = UILabel()
        text.numberOfLines = 0
        text.text = "Es konnten keine Daten ausgelesen werden. Bitte wiederholen Sie die Aufnahme."
        text.textColor = .white
        return text
    }()
    fileprivate var tipsCollectionView: CaptureSuggestionsCollectionView = CaptureSuggestionsCollectionView()
    fileprivate var repeatAnalysisButton: UIButton = {
        let closeButtonResources = PreferredButtonResource(image: "navigationCameraClose", title: "ginivision.navigationbar.camera.close", comment: "Button title in the navigation bar for the close button on the camera screen", configEntry: GiniConfiguration.sharedConfiguration.navigationBarCameraTitleCloseButton)
        let repeatButton = UIButton()
        repeatButton.setTitle("Aufnahme wiederholen", for: .normal)
        repeatButton.setImage(closeButtonResources.preferredImage, for: .normal)
        repeatButton.backgroundColor = .black
        return repeatButton
    }()
    
    fileprivate let captureTips: [(image: UIImage?, text: String)] = [
        (UIImageNamedPreferred(named: "onboardingTip1"), NSLocalizedString("ginivision.analysis.suggestion.1", bundle: Bundle(for: GiniVision.self), comment: "First suggestion text for analysis screen")),
        (UIImageNamedPreferred(named: "onboardingTip2"), NSLocalizedString("ginivision.analysis.suggestion.2", bundle: Bundle(for: GiniVision.self), comment: "Second suggestion text for analysis screen")),
        (UIImageNamedPreferred(named: "onboardingTip3"), NSLocalizedString("ginivision.analysis.suggestion.3", bundle: Bundle(for: GiniVision.self), comment: "Third suggestion text for analysis screen")),
        (UIImageNamedPreferred(named: "onboardingTip4"), NSLocalizedString("ginivision.analysis.suggestion.4", bundle: Bundle(for: GiniVision.self), comment: "Forth suggestion text for analysis screen"))
    ]
    
    override public func loadView() {
        super.loadView()
        view = UIView()
        view.backgroundColor = .white
        
        tipsCollectionView.dataSource = self
        tipsCollectionView.delegate = self
        
        warningViewContainer.addSubview(warningViewIcon)
        warningViewContainer.addSubview(warningViewText)
        view.addSubview(warningViewContainer)
        view.addSubview(tipsCollectionView)
        view.addSubview(repeatAnalysisButton)
        
        addConstraints()
        addConstraintsWarningView()
    }
    
    fileprivate func addConstraints() {
        tipsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        repeatAnalysisButton.translatesAutoresizingMaskIntoConstraints = false
        
        ConstraintUtils.addActiveConstraint(item: self.view, attribute: .bottom, relatedBy: .equal, toItem: repeatAnalysisButton, attribute: .bottom, multiplier: 1.0, constant: 0)
        ConstraintUtils.addActiveConstraint(item: self.view, attribute: .leading, relatedBy: .equal, toItem: repeatAnalysisButton, attribute: .leading, multiplier: 1.0, constant: 0)
        ConstraintUtils.addActiveConstraint(item: self.view, attribute: .trailing, relatedBy: .equal, toItem: repeatAnalysisButton, attribute: .trailing, multiplier: 1.0, constant: 0)
        ConstraintUtils.addActiveConstraint(item: repeatAnalysisButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 60)
        
        ConstraintUtils.addActiveConstraint(item: tipsCollectionView, attribute: .top, relatedBy: .equal, toItem: warningViewContainer, attribute: .bottom, multiplier: 1.0, constant: 0)
        ConstraintUtils.addActiveConstraint(item: tipsCollectionView, attribute: .bottom, relatedBy: .equal, toItem: repeatAnalysisButton, attribute: .top, multiplier: 1.0, constant: 0)
        ConstraintUtils.addActiveConstraint(item: self.view, attribute: .leading, relatedBy: .equal, toItem: tipsCollectionView, attribute: .leading, multiplier: 1.0, constant: 0)
        ConstraintUtils.addActiveConstraint(item: self.view, attribute: .trailing, relatedBy: .equal, toItem: tipsCollectionView, attribute: .trailing, multiplier: 1.0, constant: 0)
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
        return tipsCollectionView.cellSize()
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return tipsCollectionView.headerSize()
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
