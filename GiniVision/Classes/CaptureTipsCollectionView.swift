//
//  CaptureTipsCollectionView.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 10/6/17.
//

import UIKit

final class CaptureTipsCollectionView: UICollectionView {
    
    static let cellIdentifier = "cellIdentifier"
    static let headerIdentifier = "headerIdentifier"

    private let minimunCellHeight: CGFloat = 66.0
    private let headerHeight: CGFloat = 50.0

    init(){
        super.init(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        self.register(CaptureTipsCollectionCell.self, forCellWithReuseIdentifier: CaptureTipsCollectionView.cellIdentifier)
        self.register(CaptureTipsCollectionHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: CaptureTipsCollectionView.headerIdentifier)
        
        if #available(iOS 9.0, *) {
            (self.collectionViewLayout as! UICollectionViewFlowLayout).sectionHeadersPinToVisibleBounds = true
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(frame:collectionViewLayout:) should be used instead")
    }
    
    func cellSize(ofSection section: Int = 0) -> CGSize{
        var height: CGFloat = (self.frame.height - headerHeight) / CGFloat(self.numberOfItems(inSection: 0))
        if height < minimunCellHeight {
            height = minimunCellHeight
        }
        return CGSize(width: UIScreen.main.bounds.width, height: height)
    }
    
    func headerSize() -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: headerHeight)
    }

}

final class CaptureTipsCollectionCell: UICollectionViewCell {
    
    var tipImage: UIImageView!
    var tipText: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCellViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(frame:) should be used instead")
    }
    
    private func setupCellViews() {
        tipImage = UIImageView()
        tipText = UILabel()
        self.addSubview(tipImage)
        self.addSubview(tipText)
        tipImage.translatesAutoresizingMaskIntoConstraints = false
        tipImage.contentMode = .scaleAspectFit
        tipText.translatesAutoresizingMaskIntoConstraints = false
        
        ConstraintUtils.addActiveConstraint(item: tipImage, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 16)
        ConstraintUtils.addActiveConstraint(item: tipImage, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: -16)
        ConstraintUtils.addActiveConstraint(item: tipImage, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 16)
        ConstraintUtils.addActiveConstraint(item: tipImage, attribute: .trailing, relatedBy: .equal, toItem: tipText, attribute: .leading, multiplier: 1.0, constant: -16)
        ConstraintUtils.addActiveConstraint(item: tipImage, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 85)
        
        ConstraintUtils.addActiveConstraint(item: tipText, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 16)
        ConstraintUtils.addActiveConstraint(item: tipText, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: -16)
        ConstraintUtils.addActiveConstraint(item: tipText, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: -16, priority: 999)
    }
}

final class CaptureTipsCollectionHeader: UICollectionReusableView {
    
    private var headerTitle: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        setupHeaderViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(frame:) should be used instead")
    }
    
    private func setupHeaderViews() {
        headerTitle = UILabel()
        headerTitle.translatesAutoresizingMaskIntoConstraints = false
        headerTitle.text = "Tipps für bessere Foto"
        headerTitle.numberOfLines = 0
        
        self.addSubview(headerTitle)
        ConstraintUtils.addActiveConstraint(item: headerTitle, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 16)
        ConstraintUtils.addActiveConstraint(item: headerTitle, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: -16)
        ConstraintUtils.addActiveConstraint(item: headerTitle, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 16)
        ConstraintUtils.addActiveConstraint(item: headerTitle, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: -16)
    }
}
