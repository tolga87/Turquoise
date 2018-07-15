//
//  GroupManager.swift
//  Turquoise
//
//  Created by tolga on 7/8/18.
//  Copyright © 2018 Tolga AKIN. All rights reserved.
//

import Foundation

typealias ArticleHeadersDownloadCallback = (ArticleHeaders?) -> Void
typealias GroupHeadersDownloadCallback = ([ArticleHeaders]?) -> Void

typealias GroupHeadersUpdateCallback = (Bool) -> Void

class GroupManager {
    let usenetClient: UsenetClientInterface
    let groupId: String
    private var firstArticleNo = 0
    private var lastArticleNo = 0
    private(set) var articleForest: [Article]? = nil

//    private(set) var groupHeaders: [ArticleHeaders]? = nil
    private(set) var articles: [Article]? = nil

    var groupHeadersUpdateCallback: GroupHeadersUpdateCallback?

    init(groupId: String, usenetClient: UsenetClientInterface) {
        self.groupId = groupId
        self.usenetClient = usenetClient
    }

    func downloadGroupHeaders() {
        let request = NNTPRequest(string: "GROUP \(self.groupId)\r\n")
        self.usenetClient.makeRequest(request) { (response) in
            guard let response = response as? NNTPGroupResponse, response.ok() else {
                printError("Could not set the current group.")
                return
            }

            self.firstArticleNo = response.firstArticleNo
            self.lastArticleNo = response.lastArticleNo

//            var groupHeaders: [ArticleHeaders] = []
            var articles: [Article] = []

            for articleNo in self.firstArticleNo...self.lastArticleNo {
                self.downloadHeaders(forArticleNo: articleNo, completion: { (articleHeaders) in
                    if let articleHeaders = articleHeaders {
                        let article = Article(articleNo: articleNo, headers: articleHeaders)
                        articles.append(article)
                    }

                    if articleNo == self.lastArticleNo {
//                        self.groupHeaders = groupHeaders
                        self.articles = articles

                        let articleForestManager = ArticleForestManager(articles: articles)
                        self.articleForest = articleForestManager.expandedForest()

                        DispatchQueue.main.async {
                            self.groupHeadersUpdateCallback?(true)
                        }
                    }
                })
            }
        }
    }

    func downloadHeaders(forArticleNo articleNo: Int, completion: ArticleHeadersDownloadCallback?) {
        let request = NNTPRequest(string: "HEAD \(articleNo)\r\n")
        self.usenetClient.makeRequest(request) { (response) in

            guard
                let response = response,
                let articleHeaders = ArticleHeaders(response: response) else {
                    completion?(nil)
                    return
            }

            completion?(articleHeaders)
        }
    }

    


}
