//
//  GINIPageControl.swift
//  GiniVision
//
//  Created by Peter Pult on 24/06/16.
//  Copyright © 2016 Gini GmbH. All rights reserved.
//

import UIKit

internal class GINIPageControl: UIPageControl {
    
    // Images
    private var indicatorImage: UIImage? {
        return UIImageNamedPreferred(named: "onboardingIndicator")
    }
    
    private var currentIndicatorImage: UIImage? {
        return UIImageNamedPreferred(named: "onboardingCurrentIndicator")
    }
    
    override var currentPage: Int {
        didSet {
            self.updateDots()
        }
    }
    
    override func awakeFromNib() {
        pageIndicatorTintColor = UIColor.clearColor()
        currentPageIndicatorTintColor = UIColor.clearColor()
    }
    
    // MARK: Private methods
    private func updateDots() {
        for view in subviews {
            let dot = UIImageView(frame: view.frame)
            dot.image = indicatorImage
            dot.highlightedImage = currentIndicatorImage
            dot.highlighted = subviews.indexOf(view) == currentPage
        }
    }
    
    // TODO: Remove?
//    private func imageViewForSubview(view: UIView) -> UIImageView? {
//        // Checking with `isKindOfClass:` because we want exact class type not member type
//        if view.isKindOfClass(UIView) {
//            let tag = 42 // Although it is not very nice, it's more performant than using `.filter` :(
//            if let subview = view.viewWithTag(tag) as? UIImageView {
//                return subview
//            }
//            let dot = UIImageView(frame: CGRectMake(0, 0, CGRectGetWidth(view.frame), CGRectGetHeight(view.frame)))
//            dot.tag = tag
//            view.addSubview(dot)
//            return dot
//        }
//        return view as? UIImageView
//    }
    
}
