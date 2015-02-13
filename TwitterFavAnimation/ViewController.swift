//
//  ViewController.swift
//  TwitterFavAnimation
//
//  Created by Ruslan Gumennyi on 12/02/15.
//  Copyright (c) 2015 Ruslan Gumennyi. All rights reserved.
//

import UIKit

@IBDesignable class FavButton : UIButton {
    
    private var _animationInProgress: Bool = false
    var animationInProgress: Bool { get { return _animationInProgress }}
   
    var checked: Bool { get { return selected }}
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        settupButton()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        settupButton()
    }
    
    func settupButton() {
        self.imageView?.contentMode = UIViewContentMode.Center
        self.setImage(UIImage(named: "icn_tweet_action_favorite_off"), forState: UIControlState.Normal)
        self.setImage(UIImage(named: "icn_tweet_action_favorite_on"), forState: UIControlState.Selected)
        self.addTarget(self, action: Selector("changeState"), forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func changeState() {
        if !self.animationInProgress {
            if checked {
                updateCheckedState(!checked, animated: true)
            } else {
                updateCheckedState(!checked, animated: false)
            }
        }
    }
    
    func updateCheckedState(checkedState :Bool, animated: Bool) {
        if !_animationInProgress {
            if selected {
                selected = false
                sendActionsForControlEvents(UIControlEvents.ValueChanged)
            } else {
                _animationInProgress = true
                imageView?.layer.addAnimation(self.favAnimation(), forKey: "favAnimation")
            }
        }
    }
    
    var imagesForAnimation: Array<CGImage> {
        get {
            struct Static {
                static var onceToken : dispatch_once_t = 0
                static var images = Array<CGImage>()
            }
            dispatch_once(&Static.onceToken) {
                let image = UIImage(named: "fav02l-sheet")
                for (var y = 0; y < 12; y++) {
                    for (var x = 0; x < 8; x++) {
                        var rect = CGRect(x: 64 * x, y: 64 * y, width: 64, height: 64)
                        let cropped = CGImageCreateWithImageInRect(image?.CGImage, rect)
                        Static.images.append(cropped!)
                    }
                }
            }
            return Static.images
        }
    }

    func favAnimation() -> CAKeyframeAnimation {
        let animation = CAKeyframeAnimation(keyPath: "contents")
        animation.calculationMode = kCAAnimationDiscrete
        animation.duration = 1.0
        animation.values = self.imagesForAnimation
        animation.repeatCount = 1
        animation.removedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        animation.delegate = self
        return animation
    }
    
    override func animationDidStop(anim: CAAnimation!, finished flag: Bool) {
        if flag {
            if let concreteAnimation = imageView!.layer.animationForKey("favAnimation") where anim == concreteAnimation {
                imageView!.layer.removeAnimationForKey("favAnimation")
                _animationInProgress = false
                selected = true
                sendActionsForControlEvents(UIControlEvents.ValueChanged)
            }
        }
    }
}

class ViewController: UIViewController {
    @IBOutlet weak var actionButton: FavButton!
    @IBOutlet weak var stateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLabel()
    }
    
    @IBAction func actionButtonTapped(sender: AnyObject) {
        updateLabel()
    }
    
    func updateLabel() {
        stateLabel.text = "Checked: \(actionButton.checked)"
    }

}

