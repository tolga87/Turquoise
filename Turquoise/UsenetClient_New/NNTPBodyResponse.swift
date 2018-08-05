//
//  NNTPBodyResponse.swift
//  Turquoise
//
//  Created by tolga on 7/22/18.
//  Copyright © 2018 Tolga AKIN. All rights reserved.
//

import Foundation

class NNTPBodyResponse : NNTPResponse {
    private(set) var articleBody: String?

    override func parse() {
        super.parse()

        let bodySeparator = "body\r\n"
        let bodyTerminator = "\r\n.\r\n"

        guard self.string.contains(bodySeparator) else {
            return
        }

        guard let separatorRange = self.string.range(of: bodySeparator) else {
            return
        }

        let bodyStartIndex = separatorRange.upperBound
        var bodyEndIndex = self.string.endIndex
        if self.string.hasSuffix(bodyTerminator) {
            bodyEndIndex = self.string.index(bodyEndIndex, offsetBy: -bodyTerminator.count)
        }

        guard bodyStartIndex <= bodyEndIndex else {
            self.articleBody = ""
            return
        }

        self.articleBody = String(self.string[bodyStartIndex..<bodyEndIndex])
    }
}
