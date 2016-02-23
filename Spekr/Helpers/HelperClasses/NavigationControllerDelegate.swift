//
//  NavigationControllerDelegate.swift
//  Spekr
//
//  Created by Arjun Kodur on 2/23/16.
//  Copyright © 2016 Arjun Kodur. All rights reserved.
//

import UIKit

class NavigationControllerDelegate: NSObject, UINavigationControllerDelegate {
    
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation:
        UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
            
            return FadeInAnimator()
    }
}
