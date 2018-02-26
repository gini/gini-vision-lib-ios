//
//  GiniImagePickerViewController.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 2/26/18.
//

import Foundation

final class GiniImagePickerViewController: UIViewController {
    
    lazy var collectionView: UICollectionView = {
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = .red
        return collectionView
    }()
    
    override func loadView() {
        super.loadView()
        view.addSubview(collectionView)
        
        Constraints.pin(view: collectionView, toSuperView: view)
    }
}
