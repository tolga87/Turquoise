import Foundation

class TQNNTPGroup : NSObject {
  static let headerDownloadProgressNotification = Notification.Name("headerDownloadProgressNotification")
  static let headerDownloadProgressAmountKey = "progressAmount"

  private(set) var groupId: String
  private(set) var minArticleNo = -1
  private(set) var maxArticleNo = -1
  private(set) var moderated = false
  private(set) var articles: [TQNNTPArticle]
  private(set) var articleForest: TQNNTPArticleForest?
  private(set) var headersDownloaded = false

  private var articlesNos: [Int : TQNNTPArticle] = [:]
  private var messageIds: [String : TQNNTPArticle] = [:]

  convenience init?(response: TQNNTPResponse?) {
    guard let response = response, let message = response.message else {
      return nil
    }

    var articleNo1 = 0
    var articleNo2 = 0
    let scanner = Scanner(string: message)
    scanner.scanInt(&articleNo1)
    scanner.scanInt(&articleNo1)  // ignore the first id. it is the number of articles in the group
    scanner.scanInt(&articleNo2)

    let minArticleNo = min(articleNo1, articleNo2)
    let maxArticleNo = max(articleNo1, articleNo2)

    var group: NSString? = ""
    scanner.scanUpTo("\r\n", into: &group)

    self.init(groupId: group! as String,
              minArticleNo: minArticleNo,
              maxArticleNo: maxArticleNo,
              moderated: false)
    // we don't know if this group is moderated at this point
  }

  init?(groupId: String,
        minArticleNo: Int,
        maxArticleNo: Int,
        moderated: Bool) {
    self.groupId = groupId
    self.minArticleNo = minArticleNo
    self.maxArticleNo = maxArticleNo
    self.moderated = moderated
    self.articles = []
    self.articlesNos = [:]
    self.messageIds = [:]
  }

  private func downloadHeader(currentArticle: Int,
                              completion: @escaping (() -> Void)) {
    var numArticles = self.maxArticleNo - self.minArticleNo
    if numArticles == 0 {
      numArticles = 1
    }

    let progress = Int(Double(currentArticle - self.minArticleNo) / Double(numArticles) * 100.0)
    printDebug("Downloading header \(currentArticle - self.minArticleNo) of \(numArticles) (\(progress)%)")

    let userInfo = [ TQNNTPGroup.headerDownloadProgressAmountKey : progress ]
    NotificationCenter.default.post(name: TQNNTPGroup.headerDownloadProgressNotification,
                                    object: self,
                                    userInfo: userInfo)

    let theManager = TQNNTPManager.sharedInstance
    let headRequest = "HEAD \(currentArticle)\r\n"

    theManager.sendRequest(headRequest) { (response, error) in
      if response == nil || !response!.isOk() {
        // this article could be deleted. keep fetching others.
        printInfo("Could not get headers of article #\(currentArticle)")
      }

      if let response = response {
        if let article = TQNNTPArticle(response: response) {
          self.articles.append(article)
          self.articlesNos[article.articleNo] = article
          self.messageIds[article.messageId] = article
        }
      }

      if currentArticle == self.maxArticleNo {
        completion()
      } else {
        self.downloadHeader(currentArticle: (currentArticle + 1), completion: completion)
      }
    }
  }

  private func setupDependencies() {
    for article in self.articles {
      if article.references.count > 0 {
        let lastReferenceMessageId = article.references.last!
        let parentArticle = self.messageIds[lastReferenceMessageId]
        article.parentArticle = parentArticle
        parentArticle?.addChildArticle(article)
      }
    }
  }

  func downloadHeaders(completion: @escaping () -> Void) {
    self.articles = []
    self.articleForest = nil
    self.headersDownloaded = false
    self.articlesNos = [:]
    self.messageIds = [:]

    guard self.minArticleNo >= 0 && self.maxArticleNo >= 0 else {
      completion()
      return
    }

    self.downloadHeader(currentArticle: self.minArticleNo) {
      // TODO: handle the case where this operation fails
      self.headersDownloaded = true
      self.setupDependencies()
      self.articleForest = TQNNTPArticleForest(articles: self.articles)
      completion()
    }
  }

  // MARK: - CustomDebugStringConvertible

  override var debugDescription: String {
    return "Group '\(self.groupId)' Articles: \(self.minArticleNo) -> \(self.maxArticleNo)"
  }

}
