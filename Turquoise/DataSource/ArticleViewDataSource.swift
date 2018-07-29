//
//  ArticleViewDataSource.swift
//  Turquoise
//
//  Created by tolga on 7/22/18.
//  Copyright © 2018 Tolga AKIN. All rights reserved.
//

import Foundation

typealias ArticleViewDataSourceUpdateCallback = () -> Void

protocol ArticleViewDataSourceInterface {
    var titleString: String { get }
    var newsgroupString: String { get }
    var senderString: String { get }
    var bodyString: String? { get }
}

class ArticleViewDataSource: ArticleViewDataSourceInterface {
    let articleHeaders: ArticleHeaders
    let articleManager: ArticleManager
    var updateCallback: ArticleViewDataSourceUpdateCallback?
    var articleBodyString: String?

    init(articleHeaders: ArticleHeaders, articleManager: ArticleManager) {
        self.articleHeaders = articleHeaders
        self.articleManager = articleManager

        self.articleManager.downloadArticleBody { [weak self] (articleBody) in
            guard let strongSelf = self, let articleBody = articleBody else {
                return
            }

            strongSelf.articleBodyString = articleBody
            strongSelf.updateCallback?()
        }
    }

    // MARK: - ArticleViewDataSourceInterface
    var titleString: String {
        return self.articleHeaders.subject.tq_decodedString
    }

    var newsgroupString: String {
        return "\(self.articleHeaders.newsgroup?.tq_decodedString ?? "(Unknown)")"
    }

    var senderString: String {
        return "\(self.articleHeaders.from?.tq_decodedString ?? "(Unknown)")"
    }

    var bodyString: String? {
        return self.articleBodyString
    }
}