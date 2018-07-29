//
//  UIView+Border.swift
//  Turquoise
//
//  Created by tolga on 7/29/18.
//  Copyright © 2018 Tolga AKIN. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    var borderColor: UIColor? {
        get {
            if let color = self.layer.borderColor {
                return UIColor(cgColor: color)
            } else {
                return nil
            }
        }

        set {
            self.layer.borderColor = newValue?.cgColor
        }
    }

    var borderWidth: CGFloat {
        get { return self.layer.borderWidth }

        set { self.layer.borderWidth = newValue }
    }

    var cornerRadius: CGFloat {
        get { return self.layer.cornerRadius }

        set { self.layer.cornerRadius = newValue }
    }
}
