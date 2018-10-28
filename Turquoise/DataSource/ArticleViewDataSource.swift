//
//  ArticleViewDataSource.swift
//  Turquoise
//
//  Created by tolga on 7/22/18.
//  Copyright © 2018 Tolga AKIN. All rights reserved.
//

import Foundation

typealias ArticleViewDataSourceUpdateCallback = () -> Void

protocol ArticleViewDataSourceInterface: NSObjectProtocol {
    var messageId: String { get }
    var newsgroupString: String { get }
    var titleString: String { get }
    var senderString: String { get }
    var bodyString: String? { get }
    var references: [String] { get }
    var updateCallback: ArticleViewDataSourceUpdateCallback? { get set }
    var allowsCancel: Bool { get set }
}

class ArticleViewDataSource: NSObject, ArticleViewDataSourceInterface {
    let articleHeaders: ArticleHeaders
    let articleManager: ArticleManager
    var articleBodyString: String?

    init(articleHeaders: ArticleHeaders, articleManager: ArticleManager, allowsCancel: Bool = false) {
        self.articleHeaders = articleHeaders
        self.articleManager = articleManager
        self.allowsCancel = allowsCancel
        super.init()

        self.articleManager.downloadArticleBody { [weak self] (articleBody) in
            guard let strongSelf = self, let articleBody = articleBody else {
                return
            }

            ReadArticleManager.sharedInstance.markArticleAsRead(strongSelf.messageId)
            strongSelf.articleBodyString = articleBody
            strongSelf.updateCallback?()
        }
    }

    // MARK: - ArticleViewDataSourceInterface
    var messageId: String {
        return self.articleHeaders.messageId
    }

    var newsgroupString: String {
        return "\(self.articleHeaders.newsgroup?.tq_decodedString ?? "(Unknown)")"
    }

    var titleString: String {
        return self.articleHeaders.subject.tq_decodedString
    }

    var senderString: String {
        return "\(self.articleHeaders.from?.tq_decodedString ?? "(Unknown)")"
    }

    var bodyString: String? {
        return self.articleBodyString
    }

    var references: [String] {
        return self.articleHeaders.references
    }

    var updateCallback: ArticleViewDataSourceUpdateCallback?

    var allowsCancel: Bool
}
