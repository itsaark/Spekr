//
//  FadeInAnimationForSegue.swift
//  Spekr
//
//  Created by Arjun Kodur on 2/23/16.
//  Copyright © 2016 Arjun Kodur. All rights reserved.
//

import UIKit

class FadeInAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    struct ColorIndex {
        
        static var colorIndex = 0
    }
    
    func transitionDuration( transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        
        return 1
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView()
        let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
        let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
        
        containerView!.addSubview(toVC!.view)
        toVC!.view.alpha = 0.0
        
        let duration = transitionDuration(transitionContext)
        UIView.animateWithDuration(duration, animations: { toVC!.view.alpha = 1.0 }, completion: { finished in
            
                let cancelled = transitionContext.transitionWasCancelled()
                transitionContext.completeTransition(!cancelled)
        })
    }
}
