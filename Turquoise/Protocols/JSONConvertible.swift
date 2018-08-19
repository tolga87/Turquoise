//
//  JSONConvertible.swift
//  Turquoise
//
//  Created by tolga on 8/12/18.
//  Copyright © 2018 Tolga AKIN. All rights reserved.
//

import Foundation

typealias JSON = [String : Any]

protocol JSONConvertible {
    init?(json: JSON)
    func convertToJson() -> JSON?
}
