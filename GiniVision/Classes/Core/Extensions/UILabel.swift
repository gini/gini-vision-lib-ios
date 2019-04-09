//
//  UILabel.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 10/30/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import Foundation

extension UILabel {
    
    func textHeight(forWidth width: CGFloat) -> CGFloat {
        guard let text = self.text, let font = font else {
            return 0
        }
        
        let maxSize = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        return text.boundingRect(with: maxSize,
                                 options: .usesLineFragmentOrigin,
                                 attributes: [NSAttributedString.Key.font: font],
                                 context: nil).size.height
    }
}
