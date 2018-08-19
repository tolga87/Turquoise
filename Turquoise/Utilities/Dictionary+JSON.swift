//
//  Dictionary+JSON.swift
//  Turquoise
//
//  Created by tolga on 8/12/18.
//  Copyright © 2018 Tolga AKIN. All rights reserved.
//

import Foundation

extension Dictionary where Key == String {
    func toString() -> String {
        guard
            let jsonData = try? JSONSerialization.data(withJSONObject: self, options: []),
            let jsonString = String(data: jsonData, encoding: .utf8) else {
                return ""
        }

        return jsonString
    }
}
