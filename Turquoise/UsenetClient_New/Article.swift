//
//  Article.swift
//  Turquoise
//
//  Created by tolga on 7/15/18.
//  Copyright © 2018 Tolga AKIN. All rights reserved.
//

import Foundation

class Article {
    let articleNo: Int
    let headers: ArticleHeaders
    private(set) var body: String?

    // TODO: Rethink this.
    var parent: Article?
    var children: [Article] = []
    var depth: Int {
        if self.references.count > 0 && self.parent == nil {
            // Article was posted as a reply to some deleted article. Treat this as a root.
            return 0
        } else {
            return self.references.count
        }
    }

    var messageId: String {
        return self.headers.messageId
    }

    var subject: String {
        return self.headers.subject
    }

    var references: [String] {
        return self.headers.references
    }

    init(articleNo: Int, headers: ArticleHeaders) {
        self.articleNo = articleNo
        self.headers = headers
    }

    func addChild(_ article: Article) {
        self.children.append(article)
    }

}
