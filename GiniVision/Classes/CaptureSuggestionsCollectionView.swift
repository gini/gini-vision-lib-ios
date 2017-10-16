//
//  CaptureSuggestionsCollectionView.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 10/6/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import UIKit

final class CaptureSuggestionsCollectionView: UICollectionView {
    
    static let cellIdentifier = "cellIdentifier"
    static let headerIdentifier = "headerIdentifier"

    private let minimunCellHeight: CGFloat = 80.0
    private let headerHeight: CGFloat = 60.0
    private let rowsInLandscape: CGFloat = 2.0
    private var sectionInset: UIEdgeInsets {
        if UIDevice.current.isIpad {
            return UIEdgeInsetsMake(20, 20, 20, 20)
        } else {
            return .zero
        }
    }

    init(){
        super.init(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        self.register(CaptureSuggestionsCollectionCell.self, forCellWithReuseIdentifier: CaptureSuggestionsCollectionView.cellIdentifier)
        self.register(CaptureSuggestionsCollectionHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: CaptureSuggestionsCollectionView.headerIdentifier)
        self.showsVerticalScrollIndicator = false
        self.backgroundColor = .white
        
        guard let layout = self.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = sectionInset
        
        if #available(iOS 9.0, *) {
            layout.sectionHeadersPinToVisibleBounds = true
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(frame:collectionViewLayout:) should be used instead")
    }
    
    func cellSize(ofSection section: Int = 0) -> CGSize{
        guard let layout = self.collectionViewLayout as? UICollectionViewFlowLayout else { return .zero }
        let isLandscape = UIScreen.main.bounds.width > UIScreen.main.bounds.height
        var height: CGFloat = (self.frame.height - headerHeight - layout.sectionInset.top - layout.sectionInset.bottom) / CGFloat(self.numberOfItems(inSection: section))
        var width: CGFloat = (UIScreen.main.bounds.width - layout.sectionInset.left - layout.sectionInset.right)
        
        if isLandscape && UIDevice.current.isIpad {
            height = height * rowsInLandscape
            width = width / rowsInLandscape
        }
        
        if height < minimunCellHeight {
            height = minimunCellHeight
        }
        
        return CGSize(width: width, height: height)
    }
    
    func headerSize() -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: headerHeight)
    }

}

final class CaptureSuggestionsCollectionCell: UICollectionViewCell {
    
    var suggestionImage: UIImageView = {
        let suggestionImage = UIImageView()
        suggestionImage.contentMode = .scaleAspectFit
        return suggestionImage
    }()
    var suggestionText: UILabel = {
        let suggestionText = UILabel()
        suggestionText.numberOfLines = 0
        suggestionText.adjustsFontSizeToFitWidth = true
        suggestionText.minimumScaleFactor = 10 / 16
        return suggestionText
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCellViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(frame:) should be used instead")
    }
    
    private func setupCellViews() {
        self.addSubview(suggestionImage)
        self.addSubview(suggestionText)
        suggestionImage.translatesAutoresizingMaskIntoConstraints = false
        suggestionText.translatesAutoresizingMaskIntoConstraints = false
        
        ConstraintUtils.addActiveConstraint(item: suggestionImage, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 20)
        ConstraintUtils.addActiveConstraint(item: suggestionImage, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: -20)
        ConstraintUtils.addActiveConstraint(item: suggestionImage, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 20)
        ConstraintUtils.addActiveConstraint(item: suggestionImage, attribute: .trailing, relatedBy: .equal, toItem: suggestionText, attribute: .leading, multiplier: 1.0, constant: -20)
        ConstraintUtils.addActiveConstraint(item: suggestionImage, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 85)
        
        ConstraintUtils.addActiveConstraint(item: suggestionText, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 10)
        ConstraintUtils.addActiveConstraint(item: suggestionText, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: -10)
        ConstraintUtils.addActiveConstraint(item: suggestionText, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: -20, priority: 999)
    }
}

final class CaptureSuggestionsCollectionHeader: UICollectionReusableView {
    
    var headerTitle: UILabel = {
        let headerTitle = UILabel()
        headerTitle.translatesAutoresizingMaskIntoConstraints = false
        headerTitle.text = "Tipps für bessere Foto"
        headerTitle.numberOfLines = 0
        return headerTitle
    }()
    var bottomLine: UIView = {
        let bottomLine = UIView()
        bottomLine.translatesAutoresizingMaskIntoConstraints = false
        bottomLine.backgroundColor = .black
        return bottomLine
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        setupHeaderViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(frame:) should be used instead")
    }
    
    private func setupHeaderViews() {
        self.addSubview(headerTitle)
        self.addSubview(bottomLine)
        
        ConstraintUtils.addActiveConstraint(item: headerTitle, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 20)
        ConstraintUtils.addActiveConstraint(item: headerTitle, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 20)
        ConstraintUtils.addActiveConstraint(item: headerTitle, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: -20)
        ConstraintUtils.addActiveConstraint(item: headerTitle, attribute: .bottom, relatedBy: .equal, toItem: bottomLine, attribute: .top, multiplier: 1.0, constant: -20)
        
        ConstraintUtils.addActiveConstraint(item: bottomLine, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0)
        ConstraintUtils.addActiveConstraint(item: bottomLine, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0)
        ConstraintUtils.addActiveConstraint(item: bottomLine, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0)
        ConstraintUtils.addActiveConstraint(item: bottomLine, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0.5)

    }
}
