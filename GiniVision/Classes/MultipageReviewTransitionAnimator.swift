//
//  MultipageReviewTransitionAnimator.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 1/26/18.
//

import UIKit

final class MultipageReviewTransitionAnimator: NSObject {
    
    let animationDuration = AnimationDuration.medium
    var operation: TransitionOperation  = .present
    var originFrame: CGRect = .zero
    
}

enum TransitionOperation {
    case present, dismiss
}

// MARK: UIViewControllerAnimatedTransitioning

extension MultipageReviewTransitionAnimator: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromView = transitionContext.view(forKey: .from)!
        let toView = transitionContext.view(forKey: .to)!
        let finalFrame: CGRect
        let yScaleFactor: CGFloat
        let xScaleFactor: CGFloat
        let scaleTransform: CGAffineTransform
        let animations: () -> Void
        
        switch operation {
        case .present:
            finalFrame = toView.frame
            yScaleFactor = originFrame.size.height / toView.frame.height
            xScaleFactor = originFrame.size.width / toView.frame.width
            scaleTransform = CGAffineTransform(scaleX: xScaleFactor,
                                               y: yScaleFactor)
            transitionContext.containerView.addSubview(toView)
            toView.transform = scaleTransform
            toView.center = originFrame.center
            animations = {
                toView.transform = CGAffineTransform.identity
                toView.center = finalFrame.center
            }

        case .dismiss:
            finalFrame = originFrame
            yScaleFactor = originFrame.size.height / fromView.frame.height
            xScaleFactor = originFrame.size.width / fromView.frame.width
            scaleTransform = CGAffineTransform(scaleX: xScaleFactor,
                                               y: yScaleFactor)
            transitionContext.containerView.addSubview(toView)
            transitionContext.containerView.bringSubview(toFront: fromView)
            animations = {
                fromView.transform = scaleTransform
                fromView.center = finalFrame.center
            }
        }
        
        UIView.animate(withDuration: animationDuration,
                       animations: animations,
                       completion: {_ in
            transitionContext.completeTransition(true)
        })
    }
}

