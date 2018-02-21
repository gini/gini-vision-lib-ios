//
//  MultipageReviewMainCollectionCell.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 1/30/18.
//

import Foundation

final class MultipageReviewMainCollectionCell: UICollectionViewCell {
    
    static let identifier = "MultipageReviewMainCollectionCellIdentifier"
    
    lazy var documentImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(documentImage)

        Constraints.pin(view: documentImage, toSuperView: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(frame:) has not been implemented")
    }
    
}
