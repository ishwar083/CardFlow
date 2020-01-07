//
//  CardView.swift
//  Nerd
//
//  Created by Mac-00014 on 13/04/18.
//  Copyright © 2018 Mind. All rights reserved.
//

import UIKit

let ACTION_MARGIN = 120.0 //distance from center where the action applies. Higher = swipe further in order for the action to be called
let SCALE_STRENGTH = 4.0 //how quickly the card shrinks. Higher = slower shrinking
let SCALE_MAX = 0.93 //upper bar for how much the card shrinks. Higher = shrinks less
let ROTATION_MAX = 1.0 //the maximum rotation allowed in radians.  Higher = card can keep rotating longer
let ROTATION_STRENGTH = 320.0 //strength of rotation. Higher = weaker rotation
let ROTATION_ANGLE = Double.pi/8 //Higher = stronger rotation angle

enum CardViewType : Int {
    case top
    case middle
    case bottom
}
enum EmojiType : Int {
    case Like
    case DisLike
}

let CoverOriginalFlowWidth = 335/375*CScreenWidth
let CoverOriginalFlowHeight = 425/375*CScreenWidth

protocol DraggableViewDelegate: NSObjectProtocol {
    
    func cardSwipedLeft(_ card: UIView?)
    func cardSwipedRight(_ card: UIView?)
    func didChangeCenter(_ card: UIView?)
}

class CardView: UIView {
    @IBOutlet var imgVProfile : UIImageView!
    @IBOutlet var imgVEmoji : UIImageView!
    @IBOutlet var lblInfo : UILabel!
    
    var cardType : CardViewType!
    var lastCenter : CGPoint!
    var VController : UIViewController!
    var  xFromCenter : CGFloat!
    var  yFromCenter : CGFloat!
    var dictInfo : [String : Any]?
    
    var delegate: DraggableViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func cardViewWithData(_ data:[String : Any]?, cardViewType : CardViewType, target : Any?){
        dictInfo = data
        cardType = cardViewType
 
        if let VC = target as? UIViewController {
            VController = VC
            self.delegate = VC as? DraggableViewDelegate
        }
        
        self.updateCardFrame()
        self.CViewSetHeight(height: CoverOriginalFlowHeight)
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.pangGesturedAction(_:)))
        self.addGestureRecognizer(panGesture)
        self.configure()
    }
    
    func configure()  {
        if let data = dictInfo {
            self.imgVProfile.image = UIImage(named: (data["image"] as? String) ?? "")
            self.lblInfo.text = data["index"] as? String
        }
    }
    
    func updateCardFrame()  {
        
        switch cardType {
        case .top:
            self.CViewSetY(y: 109/375*CScreenWidth)
            self.CViewSetWidth(width: CoverOriginalFlowWidth)
            self.CViewSetX(x: 20/375*CScreenWidth)
        case .middle:
            self.CViewSetY(y: 121.5/375*CScreenWidth)
            self.CViewSetWidth(width: 305/375*CScreenWidth)
            self.CViewSetX(x: 35/375*CScreenWidth)
            break
        case .bottom:
            self.CViewSetY(y: 134/375*CScreenWidth)
            self.CViewSetWidth(width: 270/375*CScreenWidth)
            self.CViewSetX(x: 52.5/375*CScreenWidth)
            break
        default:
            break
        }
    }
    
    
    // MARK:-
    // MARK:- Card view Gesture
    
    @objc func pangGesturedAction(_ gestureRecognizer : UIPanGestureRecognizer)  {
        
        guard let card = gestureRecognizer.view as? CardView else {
            return
        }
        //this extracts the coordinate data from your swipe movement. (i.e. How much did you move?)
        
        xFromCenter = gestureRecognizer.translation(in: self).x //positive for right swipe, negative for left
        
        yFromCenter = gestureRecognizer.translation(in: self).y //positive for up, negative for down
        
        switch gestureRecognizer.state {
        case .began: //just started swiping
            self.lastCenter = self.center
            
        case .changed: //in the middle of a swipe
            //dictates rotation (see ROTATION_MAX and ROTATION_STRENGTH for details)
            let  rotationStrength = min(Double(xFromCenter) / ROTATION_STRENGTH, ROTATION_MAX)
            
            //degree change in radians
            let rotationAngel = ROTATION_ANGLE * rotationStrength;
            
            //amount the height changes when you move the card up to a certain point
            let scale = max(1 - fabs(rotationStrength) / SCALE_STRENGTH, SCALE_MAX)
            
            //move the object's center by center + gesture coordinate
            
            card.center = CGPoint(x: lastCenter.x + xFromCenter, y: lastCenter.y + yFromCenter)
            
            //rotate by certain amount
            
            let transform = CGAffineTransform(rotationAngle: CGFloat(rotationAngel))
            
            //scale by certain amount
            let scaleTransform = transform.scaledBy(x: CGFloat(scale), y: CGFloat(scale))
            
            //apply transformations
            self.transform = scaleTransform
            self.updateOverlay(xFromCenter)
            
            self.delegate?.didChangeCenter(self)
            
        case .ended:
            self.endSwipeAction()
        default:
            break
        }
        
    }
    
    //checks to see if you are moving right or left and applies the correct overlay image
    func updateOverlay(_ distance: CGFloat) {
        if distance > 0 {
            self.changeEmojiWithType(.DisLike)
        } else {
            self.changeEmojiWithType(.Like)
        }
        self.imgVEmoji.alpha = max(abs(distance) / 150, 0.3)
    }
    
    func changeEmojiWithType(_ type : EmojiType){
        
        if type == .Like {
            self.imgVEmoji.image = #imageLiteral(resourceName: "like_large")
        } else {
            self.imgVEmoji.image = #imageLiteral(resourceName: "sad_large")
        }
    }
    
    //called when the card is let go
    func endSwipeAction() {
        
        if Double(xFromCenter) > ACTION_MARGIN {
            rightSwipe()
        } else if Double(xFromCenter) < -ACTION_MARGIN {
            leftSwipe()
        } else {
            //resets the card
            UIView.animate(withDuration: 0.3, animations: {() -> Void in
                self.center = self.lastCenter
                self.transform = CGAffineTransform(rotationAngle: 0)
                self.imgVEmoji.alpha = 0
            })
        }
    }
    
    // MARK:-
    // MARK:- Swipe
    
    //called when a swipe exceeds the ACTION_MARGIN to the right
    func rightSwipe() {
        let finishPoint = CGPoint(x: 500, y: 2 * yFromCenter + lastCenter.y)
        UIView.animate(withDuration: 0.3, animations: {() -> Void in
            self.center = finishPoint
        }, completion: {(_ complete: Bool) -> Void in
            self.removeFromSuperview()
        })
        
        self.delegate?.cardSwipedRight(self)
        print("DisLiked")
    }
    
    //called when a swip exceeds the ACTION_MARGIN to the left
    func leftSwipe() {
        
        let finishPoint = CGPoint(x: -500, y: 2 * yFromCenter + lastCenter.y)
        UIView.animate(withDuration: 0.3, animations: {() -> Void in
            self.center = finishPoint
        }, completion: {(_ complete: Bool) -> Void in
            self.removeFromSuperview()
        })
        self.delegate?.cardSwipedLeft(self)
        print("Liked")
    }
    
    
    
    // MARK:-
    // MARK:- Action Event
    
    func rightAction() {
        let finishPoint = CGPoint(x: 600, y: self.center.y)
        UIView.animate(withDuration: 0.5, animations: {() -> Void in
            self.center = finishPoint
            self.transform = CGAffineTransform(rotationAngle: 1)
        }, completion: {(_ complete: Bool) -> Void in
            self.removeFromSuperview()
        })
        
        self.delegate?.cardSwipedRight(self)
        print("DisLiked")
    }
    
    
    
    func leftAction() {
        
        let finishPoint = CGPoint(x: -600, y: self.center.y)
        UIView.animate(withDuration: 0.5, animations: {() -> Void in
            self.center = finishPoint
            self.transform = CGAffineTransform(rotationAngle: -1)
        }, completion: {(_ complete: Bool) -> Void in
            self.removeFromSuperview()
        })
        self.delegate?.cardSwipedLeft(self)
        print("Liked")
    }
}
