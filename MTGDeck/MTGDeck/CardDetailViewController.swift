//
//  CardDetailViewController.swift
//  MTGDeck
//
//  Created by Mathew Cruz on 5/24/16.
//  Copyright © 2016 Mathew Cruz. All rights reserved.
//

import UIKit

class RoundedImageView: UIImageView {
    override func layoutSubviews() {
        super.layoutSubviews()
        let mask = CAShapeLayer()
        mask.frame = bounds
        let path = UIBezierPath(roundedRect: mask.frame, cornerRadius: 10.0)
        mask.path = path.CGPath
        layer.mask = mask
    }
}

class CardDetailViewController: UIViewController {
    @IBOutlet weak var nameLabel:UILabel?
    @IBOutlet weak var manaCostLabel:UILabel?
    @IBOutlet weak var typeLabel:UILabel?
    @IBOutlet weak var cardArtImageView:RoundedImageView?
    @IBOutlet weak var cardArtViewHolder:UIView?
    @IBOutlet weak var blurImageView:RoundedImageView?
    @IBOutlet weak var blurView:UIVisualEffectView?
    
    var card:MTGCard?

    override func viewDidLoad() {
        super.viewDidLoad()
        displayCard(card)
    }
    
    override func viewWillAppear(animated: Bool) {
        UIView.animateWithDuration(0.80, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: .CurveEaseIn, animations: {
//            self.cardArtViewHolder?.layer.shadowRadius = 20.0
            var transform = CATransform3DIdentity
            transform.m34 = -1.0/800.0
            transform = CATransform3DTranslate(transform, 0.0, 0.0, 70.0)
            self.cardArtViewHolder?.layer.transform = transform
            self.blurImageView?.transform = CGAffineTransformMakeScale(1.3, 1.3)
            self.blurImageView?.alpha = 0.3
            }, completion: { (finished) in
                

        })
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(790000000)), dispatch_get_main_queue()) {
            UIView.animateWithDuration(0.8, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [.BeginFromCurrentState, .CurveEaseOut], animations: {
                
    //            self.cardArtViewHolder?.layer.shadowRadius = 10.0
                var transform = CATransform3DIdentity
                transform.m34 = -1.0/800.0
                transform = CATransform3DTranslate(transform, 0.0, 0.0, 30.0)
                self.blurImageView?.transform = CGAffineTransformIdentity
                self.blurImageView?.alpha = 1.0
                self.cardArtViewHolder?.layer.transform = transform
                }, completion: nil)
        }
    }
}

extension CardDetailViewController {
    func displayCard(card:MTGCard?) {
        title = card?.name
        nameLabel?.text = card?.name
        manaCostLabel?.text = card?.manaCostString
        typeLabel?.text = card?.text
        if let image = card?.image {
            cardArtImageView?.image = image
            blurImageView?.image = image
            return
        }
        guard let cardToDisplay = card else { return }
        DataManager.sharedManager.artDownloader.artForCard(cardToDisplay, completion: { (image) in
            guard let image = image else { return }
            NSOperationQueue.mainQueue().addOperationWithBlock({ 
                self.cardArtImageView?.image = image
                self.blurImageView?.image = image
            })
        })
    }
}
