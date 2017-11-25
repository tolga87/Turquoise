import Foundation

@objc class TQNNTPArticleForest : NSObject {
  var trees: [TQNNTPArticle] {
    get {
      return self.rootArticles
    }
  }
  var numArticles: Int {
    get {
      return self.messageIds.count
    }
  }
  private var messageIds: [String : TQNNTPArticle]
  private var rootArticles: [TQNNTPArticle]

  init(articles: [TQNNTPArticle]) {
    self.rootArticles = []
    self.messageIds = [:]

    for article in articles {
      self.messageIds[article.messageId] = article

      if article.parentArticle == nil {
        // the parent article may have been deleted. if so, try to find the next available ancestor.
        for referenceMessageId in article.references.reversed() {
          if let ancestorArticle = self.messageIds[referenceMessageId] {
            article.parentArticle = ancestorArticle
            ancestorArticle.addChildArticle(article)
            // TODO: where exactly should we "insert" this new child into the ancestor's children?
            break
          }
        }
      }
      if article.parentArticle == nil {
        self.rootArticles.append(article)
      }
    }

    self.rootArticles.sort { $1.articleNo < $0.articleNo }
  }

  func expandedForest() -> [TQNNTPArticle] {
    var forest: [TQNNTPArticle] = []
    for rootArticle in self.rootArticles {
      forest.append(contentsOf: self.expandedForest(from: rootArticle))
    }
    return forest
  }

  private func expandedForest(from node: TQNNTPArticle?) -> [TQNNTPArticle] {
    guard let node = node else {
      return []
    }

    var forest = [node]
    for child in node.childArticles {
      forest.append(contentsOf: self.expandedForest(from: child))
    }
    return forest
  }

  // MARK: - Debug
  func printForest() {
    for root in self.rootArticles {
      self.printTreeNode(root, level: 0)
    }
  }

  func printTreeNode(_ article: TQNNTPArticle, level: Int) {
    var string = ""
    if level == 0 {
      string += "*"
    } else {
      string += String(repeatElement("-", count: level))
    }
    string += "\(article.subject.tq_decodedString) (\(article.articleNo)"
    printDebug(string)

    for child in article.childArticles {
      self.printTreeNode(child, level: (level + 1))
    }
  }
}
