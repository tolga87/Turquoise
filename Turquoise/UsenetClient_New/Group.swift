//
//  Group.swift
//  Turquoise
//
//  Created by tolga on 7/29/18.
//  Copyright © 2018 Tolga AKIN. All rights reserved.
//

import Foundation

class Group: NSObject {
    let numberOfArticles: Int
    let groupId: String
    let highestArticleNo: String
    let lowestArticleNo: String
    let flags: String

    init(groupId: String, highestArticleNo: String, lowestArticleNo: String, flags: String) {
        self.groupId = groupId
        self.highestArticleNo = highestArticleNo
        self.lowestArticleNo = lowestArticleNo
        self.flags = flags

        var numArticles = 0
        if let highestNumber = Int(highestArticleNo), let lowestNumber = Int(lowestArticleNo) {
            // If high < low, there are no articles.
            numArticles = max(0, highestNumber - lowestNumber + 1)
        }
        self.numberOfArticles = numArticles
    }

    override var description: String {
        return "\(super.description): \(self.groupId) \(self.highestArticleNo) \(self.lowestArticleNo) \(self.flags)"
    }
}

extension Group: Searchable {
    func matches(searchTerm: String) -> Bool {
        return self.groupId.contains(searchTerm)
    }

    func caseInsensitiveMatches(searchTerm: String) -> Bool {
        return self.groupId.lowercased().contains(searchTerm.lowercased())
    }
}
