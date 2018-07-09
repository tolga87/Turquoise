//
//  NNTPRequest.swift
//  Turquoise
//
//  Created by tolga on 7/8/18.
//  Copyright © 2018 Tolga AKIN. All rights reserved.
//

import Foundation

class NNTPRequest : NSObject {
    var string: String

    init(string: String) {
        self.string = string
    }

    override var description: String {
        return "\(super.description) `\(self.string)`"
    }
}
