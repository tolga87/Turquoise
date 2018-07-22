//
//  ArticleForestManager.swift
//  Turquoise
//
//  Created by tolga on 7/15/18.
//  Copyright © 2018 Tolga AKIN. All rights reserved.
//

import Foundation

class ArticleForestManager {

    private var allArticles: [String : Article] = [:]
    private var rootArticles: [Article] = []

    init(articles: [Article]) {
        for article in articles {
            allArticles[article.messageId] = article
        }

        // Make parent/child connections.
        for article in articles {
            if let lastReferenceMessageId = article.references.last {
                let parent = self.allArticles[lastReferenceMessageId]
                article.parent = parent
                parent?.addChild(article)
            }
        }

        // Connect orphan articles to their closest ancestor.
        for article in articles {
            if article.parent == nil {
                for referenceMessageId in article.references.reversed() {
                    if let ancestorArticle = self.allArticles[referenceMessageId] {
                        article.parent = ancestorArticle
                        ancestorArticle.addChild(article)
                        // TODO: where exactly should we "insert" this new child into the ancestor's children?
                        break
                    }
                }
            }
            if article.parent == nil {
                self.rootArticles.append(article)
            }
        }

        self.rootArticles.sort { $1.articleNo < $0.articleNo }
    }

    func expandedForest() -> [Article] {
        var forest: [Article] = []
        for rootArticle in self.rootArticles {
            forest.append(contentsOf: self.expandedForest(from: rootArticle))
        }
        return forest
    }

    private func expandedForest(from node: Article) -> [Article] {
//        var forest = [node]
//        for child in node.children {
//            forest.append(contentsOf: self.expandedForest(from: child))
//        }

        var forest: [Article] = node.children.flatMap {
            self.expandedForest(from: $0)
        }
        forest.insert(node, at: 0)

        return forest
    }

// MARK: - Debug

    private func printForest() {
        for root in self.rootArticles {
            self.printTreeNode(root, level: 0)
        }
    }

    private func printTreeNode(_ article: Article, level: Int) {
        var string = ""
        if level == 0 {
            string += "*"
        } else {
            string += String(repeatElement("-", count: level))
        }
        string += "\(article.subject.tq_decodedString) (\(article.articleNo)"
        printDebug(string)

        for child in article.children {
            self.printTreeNode(child, level: (level + 1))
        }
    }
}

//private class ArticleNode {
//    let articleHeaders: ArticleHeaders
//    var children: [ArticleHeaders]
//    var parent: ArticleHeaders?
//
//    init(articleHeaders: ArticleHeaders) {
//        self.articleHeaders = articleHeaders
//        self.children = []
//        self.parent = nil
//    }
//}

//private class ArticleForest {
//    var rootArticleHeaders: ArticleHeaders?
//}
