//
//  UIView+addBorder.swift
//  Snacktacular
//
//  Created by Peter Song  on 11/19/18.
//  Copyright © 2018 John Gallaugher. All rights reserved.
//

import Foundation
import UIKit

extension UIView{
    func addBorder(width: CGFloat, radius: CGFloat, color:UIColor){
        self.layer.borderWidth = width
        self.layer.borderColor = color.cgColor
        self.layer.cornerRadius = radius
    }
    func noBoarder(){
        self.layer.borderWidth = 0.0
    }
}
