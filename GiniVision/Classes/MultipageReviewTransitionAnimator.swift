//
//  MultipageReviewTransitionAnimator.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 1/26/18.
//

import UIKit

final class MultipageReviewTransitionAnimator: NSObject {
    
    let animationDuration = 10.0
    var operation: UINavigationControllerOperation = .push
    var originFrame: CGRect = .zero
    weak var storedContext: UIViewControllerContextTransitioning?
    
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
        
        self.storedContext = transitionContext
        let scaleFactorY = originFrame.size.height / toVC.view.frame.height
        let scaleFactorX = originFrame.size.height / toVC.view.frame.width
        let scaleTransform = CGAffineTransform(scaleX: scaleFactorX,
                          y: scaleFactorY)
        transitionContext.containerView.addSubview(toView)

        toView.transform = scaleTransform
        toView.center = originFrame.center
        toView.clipsToBounds = true
        UIView.animate(withDuration: animationDuration, animations: {
            toView.transform = CGAffineTransform.identity
            toView.center = finalFrame.center
        }, completion: {_ in
            transitionContext.completeTransition(true)
        })
    }
}

