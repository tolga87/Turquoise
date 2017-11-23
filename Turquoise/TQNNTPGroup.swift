import Foundation

public class TQNNTPGroup : NSObject {
  public static let headerDownloadProgressNotification = Notification.Name("headerDownloadProgressNotification")
  public static let headerDownloadProgressAmountKey = "progressAmount"

  public private(set) var groupId: String
  public private(set) var minArticleNo = -1
  public private(set) var maxArticleNo = -1
  public private(set) var moderated = false
  public private(set) var articles: [TQNNTPArticle]
  public private(set) var articleForest: TQNNTPArticleForest?
  public private(set) var headersDownloaded = false

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
    //  TQLogInfo(@"Downloading header %ld of %ld (%ld%%)", (articleNo - _minArticleNo), numArticles, progress);

    let userInfo = [ TQNNTPGroup.headerDownloadProgressAmountKey : progress ]
    NotificationCenter.default.post(name: TQNNTPGroup.headerDownloadProgressNotification,
                                    object: self,
                                    userInfo: userInfo)

    let theManager = TQNNTPManager.sharedInstance
    let headRequest = "HEAD \(currentArticle)\r\n"

    theManager.sendRequest(headRequest) { (response, error) in
      if response == nil || !response!.isOk() {
        // this article could be deleted. keep fetching others.
        // TQLogInfo(@"Could not get headers of article #%ld", articleNo);
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

  public override var debugDescription: String {
    return "Group '\(self.groupId)' Articles: \(self.minArticleNo) -> \(self.maxArticleNo)"
  }

}
