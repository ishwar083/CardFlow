//
//  ExtensionView.swift
//  CardFlow
//
//  Created by mac-00014 on 06/01/20.
//  Copyright © 2020 Mi. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    func CViewSetSize(width:CGFloat , height:CGFloat) {
        CViewSetWidth(width: width)
        CViewSetHeight(height: height)
    }
    
    func CViewSetOrigin(x:CGFloat , y:CGFloat) {
        CViewSetX(x: x)
        CViewSetY(y: y)
    }
    
    func CViewSetWidth(width:CGFloat) {
        self.frame.size.width = width
    }
    
    func CViewSetHeight(height:CGFloat) {
        self.frame.size.height = height
    }
    
    func CViewSetX(x:CGFloat) {
        self.frame.origin.x = x
    }
    
    func CViewSetY(y:CGFloat) {
        self.frame.origin.y = y
    }
    
    func CViewSetCenter(x:CGFloat , y:CGFloat) {
        CViewSetCenterX(x: x)
        CViewSetCenterY(y: y)
    }
    
    func CViewSetCenterX(x:CGFloat) {
        self.center.x = x
    }
    
    func CViewSetCenterY(y:CGFloat) {
        self.center.y = y
    }
    
}

// MARK: - Extension of UIView For getting any UIView from XIB.
extension UIView {
    
    /// This static Computed property is used to getting any UIView from XIB. This Computed property returns UIView? , it means this method return nil value also , while using this method please use if let. If you are not using if let and if this method returns nil and when you are trying to unwrapped this value("UIView!") then application will crash.
    static var viewFromXib:UIView? {
        return self.viewWithNibName(strViewName: "\(self)")
    }
    
    /// This static method is used to getting any UIView with specific name.
    ///
    /// - Parameter strViewName: A String Value of UIView.
    /// - Returns: This Method returns UIView? , it means this method return nil value also , while using this method please use if let. If you are not using if let and if this method returns nil and when you are trying to unwrapped this value("UIView!") then application will crash.
    static func viewWithNibName(strViewName:String) -> UIView? {
        
        guard let view = CMainBundle.loadNibNamed(strViewName, owner: self, options: nil)?[0] as? UIView else { return nil }
        
        return view
    }
    
}
