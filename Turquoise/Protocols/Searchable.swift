//
//  Searchable.swift
//  Turquoise
//
//  Created by tolga on 7/29/18.
//  Copyright © 2018 Tolga AKIN. All rights reserved.
//

import Foundation

protocol Searchable {
    func caseInsensitiveMatches(searchTerm: String) -> Bool
    func matches(searchTerm: String) -> Bool
}
