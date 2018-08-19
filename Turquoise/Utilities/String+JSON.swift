//
//  String+JSON.swift
//  Turquoise
//
//  Created by tolga on 8/12/18.
//  Copyright © 2018 Tolga AKIN. All rights reserved.
//

import Foundation

extension String {
    func convertToJson() -> JSON? {
        guard
            let data = self.data(using: .utf8),
            let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? JSON else {
                return nil
        }
        return json
    }
}
