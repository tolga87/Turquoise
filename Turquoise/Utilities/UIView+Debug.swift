//
//  UIView+Debug.swift
//  Turquoise
//
//  Created by tolga on 7/28/18.
//  Copyright © 2018 Tolga AKIN. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func highlightBorders() {
        self.layer.borderColor = UIColor.red.cgColor
        self.layer.borderWidth = 1
//        self.layer.cornerRadius = 4

        self.subviews.forEach {
            $0.highlightBorders()
        }
    }
}
