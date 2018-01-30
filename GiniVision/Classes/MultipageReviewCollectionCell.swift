//
//  MultipageReviewCollectionCell.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 1/30/18.
//

import Foundation

final class MultipageReviewCollectionCell: UICollectionViewCell {
    
    static let identifier = "MultipageReviewCollectionCellIdentifier"
    var shouldShowBorder: Bool = false
    
    lazy var documentImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override var isSelected: Bool {
        didSet {
            if shouldShowBorder {
                self.layer.borderColor = isSelected ? Colors.Gini.blue.cgColor : UIColor.black.cgColor
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(documentImage)
        self.layer.borderWidth = 2.0
        Contraints.clip(view: documentImage, toSuperView: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(frame:) has not been implemented")
    }
    
}
