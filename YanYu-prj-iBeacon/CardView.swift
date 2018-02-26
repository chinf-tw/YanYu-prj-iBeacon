//
//  CardView.swift
//  CardApp
//
//  Created by 洪權甫 on 2018/1/29.
//  Copyright © 2018年 洪權甫. All rights reserved.
//

import UIKit

@IBDesignable class CardView: UIView {

    @IBInspectable var corenerradius : CGFloat = 5
    
    @IBInspectable var shadowOffSetWidth : CGFloat = 0
    
    @IBInspectable var shadowOffSetHeight : CGFloat = 5
    
    @IBInspectable var shadowColor : UIColor = UIColor.lightGray
    
    @IBInspectable var shadowOpacity : CGFloat = 5
    
    override func layoutSubviews() {
        layer.cornerRadius = corenerradius // 圓角的弧度
        
        layer.shadowColor = shadowColor.cgColor
        
        layer.shadowOffset = CGSize(width: shadowOffSetWidth, height: shadowOffSetHeight)
        
        let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: corenerradius)
        
        layer.shadowPath = shadowPath.cgPath
        
        layer.shadowOpacity = Float(shadowOpacity)
        
    }
    

}
