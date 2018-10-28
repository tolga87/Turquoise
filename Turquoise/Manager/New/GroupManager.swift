//
//  GroupManager.swift
//  Turquoise
//
//  Created by tolga on 7/8/18.
//  Copyright © 2018 Tolga AKIN. All rights reserved.
//

import Foundation

typealias ArticleHeadersDownloadCallback = (Int, ArticleHeaders?) -> Void
typealias ArticlePostingCompletionCallback = (Bool) -> Void

typealias GroupHeadersUpdateCallback = () -> Void
typealias GroupHeadersProgressUpdateCallback = () -> Void

class GroupManager {
    let usenetClient: UsenetClientInterface
    let cacheManager: CacheManager
    let groupId: String
    private var firstArticleNo = 0
    private var lastArticleNo = 0
    private(set) var articleForestManager: ArticleForestManager?
    private(set) var articleForest: [Article]?

    private(set) var articles: [Article]? = nil
    private(set) var isLoading = true
    private(set) var downloadProgress: DownloadProgress?

    var groupHeadersUpdateCallback: GroupHeadersUpdateCallback?
    var groupHeadersProgressUpdateCallback: GroupHeadersUpdateCallback?

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
                self.createForestAndNotify(withArticles: [])
                return
            }

            self.isLoading = true

            self.downloadHeaders(forArticleNo: self.firstArticleNo,
                                 maxArticleNo: self.lastArticleNo,
                                 articleHeadersCallback: { articleNo, articleHeaders in

                                    if let articleHeaders = articleHeaders {
                                        let article = Article(articleNo: articleNo, headers: articleHeaders)
                                        articles.append(article)
                                    }
                                    self.notifyProgress(currentArticleNo: articleNo)
            }, completionCallback: {
                self.isLoading = false
                self.createForestAndNotify(withArticles: articles)
            })
        }
    }

    private func downloadHeaders(forArticleNo articleNo: Int,
                                 maxArticleNo: Int,
                                 articleHeadersCallback: @escaping ArticleHeadersDownloadCallback,
                                 completionCallback: @escaping () -> Void) {

        func downloadNextArticle() {
            self.downloadHeaders(forArticleNo: articleNo + 1,
                                 maxArticleNo: maxArticleNo,
                                 articleHeadersCallback: articleHeadersCallback,
                                 completionCallback: completionCallback)
        }

        if articleNo > maxArticleNo {
            // Finished
            completionCallback()
            return
        }

        if let articleHeaders = cacheManager.loadArticleHeaders(withArticleNo: articleNo) {
            // Article headers found in cache.
            articleHeadersCallback(articleNo, articleHeaders)
            downloadNextArticle()
            return
        }

        // Article headers not in cache. Initiate request to the server.
        let request = NNTPRequest(string: "HEAD \(articleNo)\r\n")
        self.usenetClient.makeRequest(request) { (response) in

            if let response = response, let articleHeaders = ArticleHeaders(response: response) {
                self.cacheManager.save(articleHeaders: articleHeaders, articleNo: articleNo)
                articleHeadersCallback(articleNo, articleHeaders)
            } else {
                articleHeadersCallback(-1, nil)
            }
            downloadNextArticle()
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

    func removeMessage(withMessageId messageId: String) {
        guard let article = self.articleForestManager?.article(withMessageId: messageId) else { return }

        self.cacheManager.deleteArticleHeaders(withArticleNo: article.articleNo)
        self.cacheManager.deleteArticleBody(withMessageId: messageId)
        self.downloadGroupHeaders()
    }

    func markAllAsRead() {
        guard let articles = self.articles else {
            return
        }

        let messageIds = articles.map { $0.messageId }
        ReadArticleManager.sharedInstance.markArticlesAsRead(messageIds)
    }

    private func notifyProgress(currentArticleNo: Int) {
        self.downloadProgress = DownloadProgress(minItemId: self.firstArticleNo,
                                                 maxItemId: self.lastArticleNo,
                                                 currentItemId: currentArticleNo)
        DispatchQueue.main.async {
            self.groupHeadersUpdateCallback?()
        }
    }

    private func createForestAndNotify(withArticles articles: [Article]) {
        self.articles = articles

        self.articleForestManager = ArticleForestManager(articles: articles)
        self.articleForest = self.articleForestManager!.expandedForest()
        self.downloadProgress = nil
        DispatchQueue.main.async {
            self.groupHeadersProgressUpdateCallback?()
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
