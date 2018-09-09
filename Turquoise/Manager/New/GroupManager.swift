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

typealias GroupHeadersUpdateCallback = (_ progress: DownloadProgress?) -> Void

class GroupManager {
    let usenetClient: UsenetClientInterface
    let cacheManager: CacheManager
    let groupId: String
    private var firstArticleNo = 0
    private var lastArticleNo = 0
    private(set) var articleForest: [Article]? = nil

    private(set) var articles: [Article]? = nil
    private(set) var isLoading = true

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

            guard self.firstArticleNo <= self.lastArticleNo else {
                // There are no articles in this group.
                self.isLoading = false
                self.createForestAndNotify(withArticles: [], currentArticleNo: -1, finished: true)
                return
            }

            self.isLoading = true
            for articleNo in self.firstArticleNo...self.lastArticleNo {
                self.downloadHeaders(forArticleNo: articleNo, completion: { (articleHeaders) in
                    if let articleHeaders = articleHeaders {
                        let article = Article(articleNo: articleNo, headers: articleHeaders)
                        articles.append(article)
                    }

                    let finished = (articleNo == self.lastArticleNo)
                    self.isLoading = !finished
                    self.notifyProgress(currentArticleNo: articleNo)

                    if articleNo == self.lastArticleNo {
                        self.createForestAndNotify(withArticles: articles, currentArticleNo: articleNo, finished: true)
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

    private func notifyProgress(currentArticleNo: Int) {
        let downloadProgress = DownloadProgress(minItemId: self.firstArticleNo,
                                                maxItemId: self.lastArticleNo,
                                                currentItemId: currentArticleNo)
        DispatchQueue.main.async {
            self.groupHeadersUpdateCallback?(downloadProgress)
        }
    }

    private func createForestAndNotify(withArticles articles: [Article], currentArticleNo: Int, finished: Bool) {
        self.articles = articles

        let articleForestManager = ArticleForestManager(articles: articles)
        self.articleForest = articleForestManager.expandedForest()
        let downloadProgress: DownloadProgress? = finished ? nil : DownloadProgress(minItemId: self.firstArticleNo,
                                                                                    maxItemId: self.lastArticleNo,
                                                                                    currentItemId: currentArticleNo)
        DispatchQueue.main.async {
            self.groupHeadersUpdateCallback?(downloadProgress)
        }
    }
}

public struct DownloadProgress {
    let minItemId: Int
    let maxItemId: Int
    let currentItemId: Int

    init(minItemId: Int, maxItemId: Int, currentItemId: Int) {
        self.minItemId = minItemId
        self.maxItemId = maxItemId
        self.currentItemId = currentItemId
    }
}
