//
//  CardTabBarController.swift
//  MTGDeck
//
//  Created by Mathew Cruz on 6/12/16.
//  Copyright © 2016 Mathew Cruz. All rights reserved.
//

import UIKit

class CardTabBarController: UITabBarController, UITabBarControllerDelegate {
    lazy var gradient:CAGradientLayer = {
        let color = UIColor(red: 1.000, green: 0.588, blue: 0.000, alpha: 1.000)
        let color2 = UIColor(red: 1.000, green: 0.770, blue: 0.443, alpha: 1.000)
        let layer = CAGradientLayer()
        layer.colors = [color2.CGColor, color.CGColor]
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 1, y: 1)
        return layer
    }()
        
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let layer = gradient
        layer.frame = view.frame
        view.layer.insertSublayer(layer, atIndex: 0)
    }
    
    func tabBarController(tabBarController: UITabBarController, animationControllerForTransitionFromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let direction:TransitionDirection = tabBarController.viewControllers?.indexOf(fromVC) < tabBarController.viewControllers?.indexOf(toVC) ? .Left : .Right
        
        return CardAnimationController(direction: direction)
    }
}


class CardNavController: UINavigationController, UINavigationControllerDelegate {
    lazy var gradient:CAGradientLayer = {
        let color = UIColor(red: 1.000, green: 0.588, blue: 0.000, alpha: 1.000)
        let color2 = UIColor(red: 1.000, green: 0.770, blue: 0.443, alpha: 1.000)
        let layer = CAGradientLayer()
        layer.colors = [color2.CGColor, color.CGColor]
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 1, y: 1)
        return layer
    }()
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let layer = gradient
        layer.frame = view.frame
        view.layer.insertSublayer(layer, atIndex: 0)
    }
    
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        let direction:TransitionDirection = operation == .Pop ? .Right : .Left
        
        return CardAnimationController(direction: direction)
    }
}