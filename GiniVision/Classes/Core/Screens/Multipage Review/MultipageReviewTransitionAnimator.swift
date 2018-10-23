//
//  MultipageReviewTransitionAnimator.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 1/26/18.
//

import UIKit

final class MultipageReviewTransitionAnimator: NSObject {
    
    let animationDuration = AnimationDuration.fast
    var operation: UINavigationController.Operation = .push
    var originFrame: CGRect = .zero
    var popImage: UIImage?
    var popImageFrame: CGRect = .zero
    fileprivate var popImageView: UIImageView?
    
}

// MARK: UIViewControllerAnimatedTransitioning

extension MultipageReviewTransitionAnimator: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let toView = transitionContext.view(forKey: .to)!
        let finalFrame: CGRect
        let yScaleFactor: CGFloat
        let xScaleFactor: CGFloat
        let scaleTransform: CGAffineTransform
        var animations: () -> Void = {}
        
        if operation == .push {
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
        } else if operation == .pop {
            popImageView = UIImageView(image: popImage)
            
            if let popImageView = popImageView {
                popImageView.frame = popImageFrame

                finalFrame = originFrame
                yScaleFactor = originFrame.size.height / popImageView.frame.height
                xScaleFactor = originFrame.size.width / popImageView.frame.width
                scaleTransform = CGAffineTransform(scaleX: xScaleFactor,
                                                   y: yScaleFactor)
                transitionContext.containerView.addSubview(toView)
                transitionContext.containerView.addSubview(popImageView)
                
                animations = {
                    popImageView.transform = scaleTransform
                    popImageView.center = finalFrame.center
                }
            }

        }
        
        UIView.animate(withDuration: animationDuration,
                       animations: animations,
                       completion: {_ in
            self.popImage = nil
            self.popImageView?.removeFromSuperview()
            transitionContext.completeTransition(true)
        })
    }
}

