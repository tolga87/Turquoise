//
//  NewsgroupTitlePresentable.swift
//  Turquoise
//
//  Created by tolga on 2/3/19.
//  Copyright © 2019 Tolga AKIN. All rights reserved.
//

import Foundation

struct NewsgroupTitlePresentable {
    public let groupId: String
    public let numberOfMessages: Int?
    public let isChecked: Bool

    public init(groupId: String, numberOfMessages: Int? = nil, isChecked: Bool = false) {
        self.groupId = groupId
        self.numberOfMessages = numberOfMessages
        self.isChecked = isChecked
    }
}
