//
//  TextField.swift
//  Turquoise
//
//  Created by tolga on 7/29/18.
//  Copyright © 2018 Tolga AKIN. All rights reserved.
//

import Foundation
import UIKit

class TextField: UITextField {
    var fontSize: CGFloat {
        get {
            return self.font?.pointSize ?? 8
        }
        set {
            self.font = UIFont(name: "dungeon", size: newValue)
        }
    }

    var horizontalInset: CGFloat? {
        didSet {
            self.setNeedsLayout()
        }
    }

    // MARK: - UITextField Overrides

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        guard let horizontalInset = self.horizontalInset else {
            return super.textRect(forBounds: bounds)
        }
        return bounds.insetBy(dx: horizontalInset, dy: 0)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        guard let horizontalInset = self.horizontalInset else {
            return super.editingRect(forBounds: bounds)
        }
        return bounds.insetBy(dx: horizontalInset, dy: 0)
    }
}
