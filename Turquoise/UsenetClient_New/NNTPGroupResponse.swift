//
//  NNTPHeadersResponse.swift
//  Turquoise
//
//  Created by tolga on 7/8/18.
//  Copyright © 2018 Tolga AKIN. All rights reserved.
//

import Foundation

class NNTPGroupResponse : NNTPResponse {
    private(set) var estimatedCount = 0
    private(set) var firstArticleNo = 0
    private(set) var lastArticleNo = 0
    private(set) var groupId = ""

    override func parse() {
        super.parse()

        let bodyComponents = self.body.components(separatedBy: .whitespacesAndNewlines)
        guard
            bodyComponents.count >= 4,
            let estimatedCount = Int(bodyComponents[0]),
            let firstArticleNo = Int(bodyComponents[1]),
            let lastArticleNo = Int(bodyComponents[2]) else {
                assertionFailure("Could not convert string to NNTPHeadersResponse")
                return
        }

        self.estimatedCount = estimatedCount
        self.firstArticleNo = firstArticleNo
        self.lastArticleNo = lastArticleNo
        self.groupId = bodyComponents[3]
    }
}
