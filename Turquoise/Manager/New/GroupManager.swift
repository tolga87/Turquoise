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
typealias ArticlePostingCompletionCallback = (Bool) -> Void

typealias GroupHeadersUpdateCallback = (Bool) -> Void

class GroupManager {
    let usenetClient: UsenetClientInterface
    let cacheManager: CacheManager
    let groupId: String
    private var firstArticleNo = 0
    private var lastArticleNo = 0
    private(set) var articleForest: [Article]? = nil

    private(set) var articles: [Article]? = nil

    var groupHeadersUpdateCallback: GroupHeadersUpdateCallback?

    init(groupId: String, usenetClient: UsenetClientInterface) {
        self.groupId = groupId
        self.usenetClient = usenetClient
        self.cacheManager = CacheManager.sharedInstance
    }

    func switchGroup(completion: ((NNTPGroupResponse?) -> Void)?) {
        let request = NNTPRequest(string: "GROUP \(self.groupId)\r\n")
        self.usenetClient.makeRequest(request) { (response) in
            guard let response = response as? NNTPGroupResponse, response.ok() else {
                printError("Could not set the current group.")
                completion?(nil)
                return
            }
            completion?(response)
        }
    }

    func downloadGroupHeaders() {
        self.switchGroup { (response) in
            guard let response = response else {
                return
            }

            self.firstArticleNo = response.firstArticleNo
            self.lastArticleNo = response.lastArticleNo
            var articles: [Article] = []

            func createForestAndNotify(articles: [Article]) {
                self.articles = articles

                let articleForestManager = ArticleForestManager(articles: articles)
                self.articleForest = articleForestManager.expandedForest()

                DispatchQueue.main.async {
                    self.groupHeadersUpdateCallback?(true)
                }
            }

            guard self.firstArticleNo <= self.lastArticleNo else {
                // There are no articles in this group.
                createForestAndNotify(articles: [])
                return
            }

            for articleNo in self.firstArticleNo...self.lastArticleNo {
                self.downloadHeaders(forArticleNo: articleNo, completion: { (articleHeaders) in
                    if let articleHeaders = articleHeaders {
                        let article = Article(articleNo: articleNo, headers: articleHeaders)
                        articles.append(article)
                    }

                    if articleNo == self.lastArticleNo {
                        createForestAndNotify(articles: articles)
                    }
                })
            }
        }
    }

    func downloadHeaders(forArticleNo articleNo: Int, completion: ArticleHeadersDownloadCallback?) {
        if let articleHeaders = cacheManager.loadArticleHeaders(withArticleNo: articleNo) {
            completion?(articleHeaders)
            return
        }

        let request = NNTPRequest(string: "HEAD \(articleNo)\r\n")
        self.usenetClient.makeRequest(request) { (response) in

            guard
                let response = response,
                let articleHeaders = ArticleHeaders(response: response) else {
                    completion?(nil)
                    return
            }

            self.cacheManager.save(articleHeaders: articleHeaders, articleNo: articleNo)
            completion?(articleHeaders)
        }
    }

    func postMessage(headers: [String : String], body: String, completion: ArticlePostingCompletionCallback?) {
        let request = NNTPRequest(string: "POST\r\n")
        self.usenetClient.makeRequest(request) { response in
            guard
                let response = response,
                response.okSoFar() else {
                    completion?(false)
                    return
            }

            let headersString = headers.compactMap { key, value in
                guard !key.isEmpty, !value.isEmpty else {
                    return nil
                }
                return "\(key): \(value)"
            }.joined(separator: "\r\n")

            let postPayload = "\(headersString)\r\n\r\n\(body)\r\n\r\n.\r\n"
            let postPayloadRequest = NNTPRequest(string: postPayload)

            self.usenetClient.makeRequest(postPayloadRequest) { response in
                guard let response = response else {
                    completion?(false)
                    return
                }

                let success = response.ok()
                completion?(success)
            }
        }
    }
}
