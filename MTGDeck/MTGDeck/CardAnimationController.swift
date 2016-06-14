//
//  CardAnimationController.swift
//  MTGDeck
//
//  Created by Mathew Cruz on 6/12/16.
//  Copyright © 2016 Mathew Cruz. All rights reserved.
//

import UIKit

enum TransitionDirection {
    case Left, Right
}

class CardAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    let direction:TransitionDirection
    
    init(direction:TransitionDirection) {
        self.direction = direction
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.45
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let toView = toVC.view
        let fromView = fromVC.view
        let containerView = transitionContext.containerView()!
        containerView.addSubview(toView)
        
        let initialFrame = transitionContext.initialFrameForViewController(fromVC)
        
        fromView.frame = initialFrame
        fromView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        toView.frame = initialFrame
        toView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)

        let directionChanger:CGFloat = direction == .Left ? 1.0 : -1.0
        
        var transform = CATransform3DIdentity
        transform.m34 = 1.0 / -800.0
        transform = CATransform3DTranslate(transform, 0.0, 0.0, -initialFrame.width)
        transform = CATransform3DRotate(transform, directionChanger * CGFloat(60.0 * (M_PI / 180.0)), 0.0, 1.0, 0.0)
        transform = CATransform3DTranslate(transform, 0.0, 0.0, initialFrame.width)
        transform = CATransform3DScale(transform, 0.85, 0.85, 0.85)
        toView.layer.transform = transform
        
        UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0.0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.0, options: .CurveEaseInOut, animations: {
            
            toView.layer.transform = CATransform3DIdentity
            var fromTransform = CATransform3DIdentity
            fromTransform.m34 = 1.0 / -800.0
            fromTransform = CATransform3DTranslate(fromTransform, 0.0, 0.0, -initialFrame.width)
            fromTransform = CATransform3DRotate(fromTransform, directionChanger * -CGFloat(60.0 * (M_PI / 180.0)), 0.0, 1.0, 0.0)
            fromTransform = CATransform3DTranslate(fromTransform, 0.0, 0.0, initialFrame.width)
            fromTransform = CATransform3DScale(fromTransform, 0.85, 0.85, 0.85)
            fromView.layer.transform = fromTransform
            
            
        }) { (complete) in
            fromView.layer.transform = CATransform3DIdentity
            transitionContext.completeTransition(true)
        }
    }
}
