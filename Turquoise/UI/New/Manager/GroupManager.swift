//
//  GroupManager.swift
//  Turquoise
//
//  Created by tolga on 7/8/18.
//  Copyright © 2018 Tolga AKIN. All rights reserved.
//

import Foundation

typealias GroupHeaderDownloadCallback = (() -> Void)

class GroupManager {
    let usenetClient: UsenetClientInterface
    let groupId: String
    private var firstArticleId = 0
    private var lastArticleId = 0

//    var updateCallback: (() -> Void)?

    init(groupId: String, usenetClient: UsenetClientInterface) {
        self.groupId = groupId
        self.usenetClient = usenetClient
    }

//    func viewModel(for groupId: String) -> GroupViewModelInterface {
//
//    }

    func downloadHeaders(completion: GroupHeaderDownloadCallback?) {
        let request = NNTPRequest(string: "GROUP \(self.groupId)\r\n")
        self.usenetClient.makeRequest(request) { (response) in
            guard let response = response as? NNTPGroupResponse, response.ok() else {
                printError("Could not set the current group.")
                return
            }

            self.firstArticleId = response.firstArticleNo
            self.lastArticleId = response.lastArticleNo
            for articleId in self.firstArticleId...self.lastArticleId {
                self.downloadHeader(articleId: articleId) {
                    if articleId == self.lastArticleId {
                        completion?()
                    }
                }
            }
        }
    }

    func downloadHeader(articleId: Int, completion: GroupHeaderDownloadCallback?) {
        let request = NNTPRequest(string: "HEAD \(articleId)\r\n")
        self.usenetClient.makeRequest(request) { (response) in
            completion?()
//            if articleId == self.lastArticleId {
//                self.updateCallback?()
//            }
        }
    }

    


}
