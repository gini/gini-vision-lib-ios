//
//  MultipageReviewTransitionAnimator.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 1/26/18.
//

import UIKit

final class MultipageReviewTransitionAnimator: NSObject {
    
    let animationDuration = AnimationDuration.medium
    var operation: UINavigationControllerOperation = .push
    var originFrame: CGRect = .zero
    
}

// MARK: UIViewControllerAnimatedTransitioning

extension MultipageReviewTransitionAnimator: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromVC = transitionContext.viewController(forKey: .from)!
        let toVC = transitionContext.viewController(forKey: .to)!
        let toView = transitionContext.view(forKey: .to)!
        let finalFrame = toView.frame
        
        let yScaleFactor = originFrame.size.height / toVC.view.frame.height
        let xScaleFactor = originFrame.size.width / toVC.view.frame.width
        let scaleTransform = CGAffineTransform(scaleX: xScaleFactor,
                          y: yScaleFactor)
        transitionContext.containerView.addSubview(toView)

        toView.transform = scaleTransform
        toView.center = originFrame.center

        UIView.animate(withDuration: animationDuration, animations: {
            toView.transform = CGAffineTransform.identity
            toView.center = finalFrame.center
        }, completion: {_ in
            transitionContext.completeTransition(true)
        })
    }
}

