//
//  ArticleCancelManager.swift
//  Turquoise
//
//  Created by tolga on 10/28/18.
//  Copyright © 2018 Tolga AKIN. All rights reserved.
//

import Foundation

typealias ArticleCancelCallback = (Bool) -> Void

class ArticleCancelManager {
    private let groupManager: GroupManager
    private let messageId: String

    init(usenetClient: UsenetClientInterface, messageId: String) {
        self.groupManager = GroupManager(groupId: "control.cancel", usenetClient: usenetClient)
        self.messageId = messageId
    }

    func cancelMessage(completion: @escaping ArticleCancelCallback) {
        let headers = [
            "From": TQUserInfoManager.sharedInstance.userInfoString,
            "Newsgroups": self.groupManager.groupId,
            "Subject": "This is a cancel message",
            "Control": "cancel \(self.messageId)"
        ]
        let body = "This message was canceled."

        self.groupManager.postMessage(headers: headers, body: body) { messagePosted in
            print("Message canceled: \(messagePosted)")

            completion(messagePosted)
        }
    }
}
