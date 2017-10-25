//
//  CaptureSuggestionsCollectionView.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 10/6/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import UIKit

final class CaptureSuggestionsCollectionView: UICollectionView {
    
    static let captureSuggestionsCellIdentifier = "captureSuggestionsCellIdentifier"
    static let captureSuggestionsHeaderIdentifier = "captureSuggestionsHeaderIdentifier"
    
    private let cellHeight: (max: CGFloat, min: CGFloat) = (180.0, 80.0)
    private let headerHeight: CGFloat = 60.0
    private let rowsInLandscape: CGFloat = 2.0
    private var captureSuggestionsCollectionLayout: UICollectionViewFlowLayout {
        return collectionViewLayout as! UICollectionViewFlowLayout
    }
    
    public var sectionInset: UIEdgeInsets {
        if UIDevice.current.isIpad {
            return UIEdgeInsetsMake(0, 20, 20, 20)
        } else {
            return UIEdgeInsetsMake(10, 0, 10, 0)
        }
    }
    
    init() {
        super.init(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        self.register(CaptureSuggestionsCollectionCell.self, forCellWithReuseIdentifier: CaptureSuggestionsCollectionView.captureSuggestionsCellIdentifier)
        self.register(CaptureSuggestionsCollectionHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: CaptureSuggestionsCollectionView.captureSuggestionsHeaderIdentifier)
        
        self.showsVerticalScrollIndicator = false
        self.backgroundColor = .white
        
        captureSuggestionsCollectionLayout.minimumLineSpacing = 10
        captureSuggestionsCollectionLayout.minimumInteritemSpacing = 0
        captureSuggestionsCollectionLayout.sectionInset = sectionInset
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init() should be used instead")
    }
    
    func cellSize(ofSection section: Int = 0) -> CGSize {
        let isLandscape = UIScreen.main.bounds.width > UIScreen.main.bounds.height
        let itemCount = CGFloat(self.numberOfItems(inSection: section))
        var height: CGFloat = (self.frame.height -
            headerHeight -
            captureSuggestionsCollectionLayout.sectionInset.top -
            captureSuggestionsCollectionLayout.sectionInset.bottom -
            (captureSuggestionsCollectionLayout.minimumLineSpacing  * (itemCount - 1))) / itemCount
        var width: CGFloat = (UIScreen.main.bounds.width -
            captureSuggestionsCollectionLayout.sectionInset.left -
            captureSuggestionsCollectionLayout.sectionInset.right)
        
        if isLandscape && UIDevice.current.isIpad {
            height = height * rowsInLandscape
            width = width / rowsInLandscape
        }
        
        if height < cellHeight.min {
            height = cellHeight.min
        } else if height > cellHeight.max {
            height = cellHeight.max
        }
        
        return CGSize(width: width, height: height)
    }
    
    func headerSize() -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: headerHeight)
    }
    
}

