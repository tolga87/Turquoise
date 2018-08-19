//
//  UIView+Traversal.swift
//  Turquoise
//
//  Created by tolga on 8/19/18.
//  Copyright © 2018 Tolga AKIN. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func traverseSubviews(withBlock block: (UIView) -> Void) {
        block(self)
        self.subviews.forEach { (subview) in
            subview.traverseSubviews(withBlock: block)
        }
    }
}
