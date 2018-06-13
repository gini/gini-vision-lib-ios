//
//  OpaqueViewFactory.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 6/13/18.
//

import UIKit

public enum OpaqueViewStyle {
    case blurred(style: UIBlurEffectStyle)
    case dimmed
}

final class OpaqueViewFactory {
    
    class func create(with style: OpaqueViewStyle) -> UIView {
        switch style {
        case .blurred(let blurStyle):
            return UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
        case .dimmed:
            let view = UIView()
            view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
            return view
        }
    }
}
