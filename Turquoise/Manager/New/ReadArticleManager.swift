//
//  ReadArticleManager.swift
//  Turquoise
//
//  Created by tolga on 10/21/18.
//  Copyright © 2018 Tolga AKIN. All rights reserved.
//

import Foundation

protocol ArticleReadStatusChangeHandler: class {
    func articleDidMarkAsRead(_ messageId: String)
    func articleDidMarkAsUnread(_ messageId: String)
    func articlesDidUpdate()
}

class ReadArticleManager {
    static let sharedInstance = ReadArticleManager()
    weak var delegate: ArticleReadStatusChangeHandler?

    private init() {
        if let articlesDict = UserDefaults.standard.dictionary(forKey: Consts.userDefaultsReadArticlesKey) as? [String : Bool] {
            self.readArticles = articlesDict
        }
    }

    func markArticleAsRead(_ messageId: String) {
        self.readArticles[messageId] = true
        UserDefaults.standard.set(self.readArticles, forKey: Consts.userDefaultsReadArticlesKey)

        self.delegate?.articleDidMarkAsRead(messageId)
    }

    func markArticlesAsRead(_ messageIds: [String]) {
        for messageId in messageIds {
            self.readArticles[messageId] = true
        }
        UserDefaults.standard.set(self.readArticles, forKey: Consts.userDefaultsReadArticlesKey)

        self.delegate?.articlesDidUpdate()
    }

    func markArticleAsUnread(_ messageId: String) {
        self.readArticles.removeValue(forKey: messageId)
        UserDefaults.standard.set(self.readArticles, forKey: Consts.userDefaultsReadArticlesKey)

        self.delegate?.articleDidMarkAsUnread(messageId)
    }

    func isArticleRead(_ messageId: String) -> Bool {
        return self.readArticles[messageId] != nil
    }

    private var readArticles: [String : Bool] = [:]
}

private extension ReadArticleManager {
    struct Consts {
        static let userDefaultsReadArticlesKey = "UserDefaultsReadArticlesKey"
    }
}
