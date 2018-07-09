//
//  UICollection.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 6/20/18.
//

import Foundation

extension UICollectionView {
    func performBatchUpdates(animated: Bool, updates: (() -> Void)?, completion: ((Bool) -> Void)?) {
        if animated {
            performBatchUpdates(updates, completion: completion)
        } else {
            UIView.performWithoutAnimation {
                performBatchUpdates(updates, completion: completion)
            }
        }
    }
}
