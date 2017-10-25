//
//  OpenWithTutorialCollectionFlowLayout.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 10/24/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import UIKit

final class OpenWithTutorialCollectionFlowLayout: UICollectionViewFlowLayout {
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        if let attrs = super.layoutAttributesForElements(in: rect) {
            var baseline: CGFloat = -2
            var sameLineElements = [UICollectionViewLayoutAttributes]()
            for element in attrs {
                if element.representedElementCategory == .cell {
                    let frame = element.frame
                    let centerY = frame.midY
                    if abs(centerY - baseline) > 1 {
                        baseline = centerY
                        OpenWithTutorialCollectionFlowLayout.alignToTopForSameLineElements(sameLineElements: sameLineElements)
                        sameLineElements.removeAll()
                    }
                    sameLineElements.append(element)
                }
            }
            OpenWithTutorialCollectionFlowLayout.alignToTopForSameLineElements(sameLineElements: sameLineElements)
            return attrs
        }
        return nil
    }
    
    private class func alignToTopForSameLineElements(sameLineElements: [UICollectionViewLayoutAttributes]) {
        if sameLineElements.count < 1 {
            return
        }
        
        let sorted = sameLineElements.sorted { (obj1: UICollectionViewLayoutAttributes, obj2: UICollectionViewLayoutAttributes) -> Bool in
            let height1 = obj1.frame.size.height
            let height2 = obj2.frame.size.height
            let delta = height1 - height2
            return delta <= 0
        }
        
        if let tallest = sorted.last {
            for obj in sameLineElements {
                obj.frame = obj.frame.offsetBy(dx: 0, dy: tallest.frame.origin.y - obj.frame.origin.y)
            }
        }
    }
}
