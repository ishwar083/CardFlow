//
//  ViewController.swift
//  CardFlow
//
//  Created by mac-00014 on 06/01/20.
//  Copyright © 2020 Mi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var arrInfo : [[String : Any]] = []
    var upcomingIndex :Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = .black
        self.refreshData()
        self.initialCardSetUp()
    }
    
    fileprivate func refreshData(){
        arrInfo = []
        
        for (index) in 1...18 {
            let data = ["index":"\(index)",
                "image":"\(index).jpg"]
            arrInfo.append(data)
        }
    }
    
    fileprivate func initialCardSetUp(){
        
        //.. add three card for first time
        var card1 : UIView!
        var card2 : UIView!
        if let card = CardView.viewFromXib as? CardView {
            card.cardViewWithData(arrInfo[upcomingIndex], cardViewType: .top, target: self)
            card1 = card
            upcomingIndex += 1
            self.view.addSubview(card)
        }
        if let card = CardView.viewFromXib as? CardView {
            card.cardViewWithData(arrInfo[upcomingIndex], cardViewType: .middle, target: self)
            card2 = card
            upcomingIndex += 1
            self.view.insertSubview(card, belowSubview: card1)
        }
        if let card = CardView.viewFromXib as? CardView {
            card.cardViewWithData(arrInfo[upcomingIndex], cardViewType: .bottom, target: self)
            upcomingIndex += 1
            self.view.insertSubview(card, belowSubview: card2)
        }
    }
    
    fileprivate func updateCardView(_ view : UIView?)  {
    
        //.. find all card from subviews from self view
        let arrCards = self.view.subviews.filter({ $0 .isKind(of: CardView.classForCoder())}) as? [CardView]
        
        if arrCards?.count ?? 0 > 0 {
            for cardView in arrCards! {
                //.. second top most card
                if cardView.cardType == .middle {
                    //.. Change to top most card
                    cardView.cardType = .top
                    cardView.updateCardFrame()
                } else if cardView.cardType == .bottom { //.. last third card
                    //.. Change to second top most card
                    cardView.cardType = .middle
                    cardView.updateCardFrame()
                    if let card = CardView.viewFromXib as? CardView {
                        //.. Add new Card add bottom of the third card
                        
                        if upcomingIndex >= arrInfo.count {
                            upcomingIndex = 0
                        }
                        card.cardViewWithData(arrInfo[upcomingIndex], cardViewType: .bottom, target: self)
                        upcomingIndex += 1
                        self.view.insertSubview(card, belowSubview: cardView)
                    }
                }
            }
        }
    }
}


// MARK:-
// MARK:- Action Event

extension ViewController {
    
    @IBAction private func btnLikeClicked(_ sender : UIButton) {
        
        
        //.. find all card from subviews from self view
        let arrCards = self.view.subviews.filter({ $0 .isKind(of: CardView.classForCoder())}) as? [CardView]
        if arrCards?.count ?? 0 > 0 {
            for cardView in arrCards! {
                
                //.. top most visible card
                if cardView.cardType == .top {
                    cardView.imgVEmoji.alpha = 1
                    cardView.changeEmojiWithType(.Like)
                    UIApplication.shared.beginIgnoringInteractionEvents()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        cardView.leftAction()
                        DispatchQueue.main.asyncAfter(deadline:.now() + 0.5, execute: {
                            UIApplication.shared.endIgnoringInteractionEvents()
                        })
                    })
                }
            }
        }
    }
    
    @IBAction private func btnDisLikeClicked(_ sender : UIButton) {
        
        //.. find all card from subviews from self view
        let arrCards = self.view.subviews.filter({ $0 .isKind(of: CardView.classForCoder())}) as? [CardView]
        
        if arrCards?.count ?? 0 > 0 {
            for cardView in arrCards! {
                
                //.. top most visible card
                if cardView.cardType == .top {
                    cardView.imgVEmoji.alpha = 1
                    cardView.changeEmojiWithType(.DisLike)
                    UIApplication.shared.beginIgnoringInteractionEvents()
                    DispatchQueue.main.asyncAfter(deadline:.now() + 0.5, execute: {
                        cardView.rightAction()
                        DispatchQueue.main.asyncAfter(deadline:.now() + 0.5, execute: {
                            UIApplication.shared.endIgnoringInteractionEvents()
                        })
                    })
                }
            }
        }
    }
}

// MARK:-
// MARK:- Swipe card view delegate

extension ViewController : DraggableViewDelegate {
    
    //... update center possion of card
    func didChangeCenter(_ card: UIView?) {
    }
  
    //... card remove using left swipe gesture
    func cardSwipedLeft(_ card: UIView?) {
        self.updateCardView(card)
    }
    
    //... card remove using right swipe gesture
    func cardSwipedRight(_ card: UIView?) {
        self.updateCardView(card)
    }
}



















































