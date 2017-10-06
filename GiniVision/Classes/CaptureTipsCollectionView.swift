//
//  CaptureTipsCollectionView.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 10/6/17.
//

import UIKit

final class CaptureTipsCollectionView: UICollectionView {
    
    fileprivate let cellIdentifier = "captureTipCellIdentifier"

    init(){
        super.init(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.register(CaptureTipsCollectionCell.self, forCellWithReuseIdentifier: cellIdentifier)
    }

}

final class CaptureTipsCollectionCell: UICollectionViewCell {
    
}
