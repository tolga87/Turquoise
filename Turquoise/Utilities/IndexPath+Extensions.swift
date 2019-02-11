//
//  IndexPath+Extensions.swift
//  Turquoise
//
//  Created by tolga on 2/10/19.
//  Copyright © 2019 Tolga AKIN. All rights reserved.
//

import Foundation

extension IndexPath {
    func isEven() -> Bool {
        return (self.row % 2 == 0)
    }
}
