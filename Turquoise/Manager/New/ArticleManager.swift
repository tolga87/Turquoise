//
//  ArticleManager.swift
//  Turquoise
//
//  Created by tolga on 7/22/18.
//  Copyright © 2018 Tolga AKIN. All rights reserved.
//

import Foundation

typealias ArticleBodyDownloadCallback = (String?) -> Void

class ArticleManager {
    let articleHeaders: ArticleHeaders
    let groupManager: GroupManager
    let usenetClient: UsenetClientInterface

    init?(articleHeaders: ArticleHeaders, groupManager: GroupManager) {
        guard let _ = articleHeaders.newsgroup else {
            return nil
        }

        self.articleHeaders = articleHeaders
        self.groupManager = groupManager
        self.usenetClient = groupManager.usenetClient
    }

    func downloadArticleBody(completion: ArticleBodyDownloadCallback?) {
        guard let messageId = self.articleHeaders.messageId else {
            completion?(nil)
            return
        }

        self.groupManager.switchGroup { (response) in
            guard let _ = response else {
                completion?(nil)
                return
            }

            let request = NNTPRequest(string: "BODY \(messageId)\r\n")
            self.usenetClient.makeRequest(request) { (response) in
                guard let response = response as? NNTPBodyResponse, response.ok() else {
                    printError("Could not get the body for article `\(messageId)`.")
                    completion?(nil)
                    return
                }

                completion?(response.articleBody)
            }
        }
    }
}
