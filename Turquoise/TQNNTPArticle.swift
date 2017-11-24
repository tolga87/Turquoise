import Foundation

public class TQNNTPArticle : NSObject {
  public private(set) var articleNo = -1
  public var messageId = ""
  public private(set) var cancelingMessageId: String?
  public private(set) var from = ""
  public private(set) var decodedFrom = ""
  public private(set) var subject = ""
  public private(set) var decodedSubject = ""
  public var body = ""
  public private(set) var date = ""
  public private(set) var newsgroups = [String]()
  public private(set) var references = [String]()
  public var depth: Int {
    get {
      if self.references.count > 0 && self.parentArticle == nil {
        // article was posted as a reply to some deleted article. treat this as a root.
        return 0;
      } else {
        return self.references.count
      }
    }
  }
  weak var parentArticle: TQNNTPArticle?
  private(set) var childArticles = [TQNNTPArticle]()

  private var headers = [String : String]()

  public class func cancelArticle(from article: TQNNTPArticle) -> TQNNTPArticle? {
    guard let cancelArticle = TQNNTPArticle(subject: "cancel \(article.messageId)",
                                            message: "This message was canceled.",
                                            newsGroup: nil,
                                            parentArticle: nil) else {
                                              return nil
    }

    cancelArticle.from = article.from
    cancelArticle.newsgroups = article.newsgroups
    cancelArticle.cancelingMessageId = article.messageId
    return cancelArticle
  }

  public init?(response: TQNNTPResponse) {
    super.init()

    guard response.isOk() else {
      return nil
    }
    guard let message = response.message else {
      return nil
    }

    self.headers = [:]
    let lines = message.components(separatedBy: "\r\n")

    var articleNo = -1
    if lines.count > 1 {
      let scanner = Scanner(string: lines[0])
      scanner.scanInt(&articleNo)
    }

    for line in lines {
      let scanner = Scanner(string: line)

      var headerName: NSString?
      var headerValue: NSString?
      let headerScanned = scanner.scanUpToCharacters(from: CharacterSet.whitespaces,
                                                     into: &headerName)
      if headerScanned && headerName!.length > 1 {
        if UnicodeScalar(headerName!.character(at: headerName!.length - 1)) == ":" {
          headerName = headerName!.substring(to: headerName!.length - 1) as NSString
        }

        // TODO: sometimes, the subject field is broken into multiple lines.
        //       I've seen this with subjects containing Emoji characters.
        //       fix this.

        scanner.scanUpTo("\r\n", into: &headerValue)
        self.headers[headerName! as String] = (headerValue as String?)
      } else {
        break
      }
    }

    self.articleNo = articleNo
    self.messageId = (self.headers["Message-ID"] ?? "?") as String
    self.from = (self.headers["From"] ?? "?") as String

    let fromComponents = self.from.components(separatedBy: CharacterSet.whitespaces)
    let mutDecodedFrom = NSMutableString(string: "")
    for fromComponent in fromComponents {
      mutDecodedFrom.append("\(fromComponent.tq_decodedString) ")
    }
    mutDecodedFrom.deleteCharacters(in: NSRange(location: mutDecodedFrom.length - 1, length: 1))
    self.decodedFrom = mutDecodedFrom as String

    self.subject = self.headers["Subject"] ?? "?"
    self.decodedSubject = self.subject.tq_decodedString

    self.date = self.headers["Date"] ?? "?"
    if let groups = self.headers["Newsgroups"] {
      self.newsgroups = groups.tq_newlineStrippedString.components(separatedBy: CharacterSet.whitespaces)
    } else {
      self.newsgroups = []
    }
    self.references = self.parseReferences(self.headers["References"])
    self.childArticles = []
  }

  public init?(subject: String,
        message: String,
        newsGroup: TQNNTPGroup?,
        parentArticle: TQNNTPArticle?) {
    guard !subject.tq_isEmpty && !message.tq_isEmpty else {
      return nil
    }

    self.subject = subject
    self.body = message
    self.newsgroups = newsGroup != nil ? [newsGroup!.groupId] : []

    // TODO: handle multiple newsgroups.
    self.parentArticle = parentArticle

    //~TA TODO: fix
//    let userInfoManager = TQUserInfoManager.sharedInstance
//    self.from = "\(userInfoManager.fullName) <\(userInfoManager.email)>"
    self.from = "tolga <tolga.ceng@gmail.com>"
    // TODO: we should probaby escape some stuff here

    if let parentArticle = self.parentArticle {
      self.references.append(contentsOf: parentArticle.references)
      self.references.append(parentArticle.messageId)
    }
  }

  func addChildArticle(_ childArticle: TQNNTPArticle) {
    self.childArticles.append(childArticle)
    self.childArticles.sort { $0.articleNo < $1.articleNo }
  }

  private func parseReferences(_ string: String?) -> [String] {
    guard let string = string, string.count > 0 else {
      return []
    }

    return string.components(separatedBy: CharacterSet.whitespaces)
  }

  func buildPostRequest() -> String {
    if self.messageId.isEmpty {
      // TODO: generate random message-ID here.
    }

    var request = "Message-ID: \(self.messageId)\r\n"

    // TODO: get user's real name and email address.
    //  let userEmail = "nobody@example.net"
    request += "From: \(self.from)\r\n"

    // TODO: accept multiple newsgroups.
    if let newsGroupId = self.newsgroups.last {
      request += "Newsgroups: \(newsGroupId)\r\n"
    }

    if !self.references.isEmpty {
      request += "References: \(self.references.joined(separator: " "))\r\n"
    }

    if let cancelingMessageId = self.cancelingMessageId {
      request += "Control: cancel \(cancelingMessageId)\r\n"
    }

    request += "Subject: \(self.subject)\r\n"
    request += "\r\n"
    request += "\(self.body)\r\n"

    // TODO: sanitize text (lines that start with "." should be handled properly).
    request += ".\r\n"
    return request
  }

  // MARK: - CustomDebugStringConvertible

  public override var debugDescription: String {
    let desc = NSMutableString()
    desc.append("Article #\(self.articleNo) '\(self.messageId)'\n")
    desc.append("Subject: '\(self.subject)'\n")
    if let parentArticle = self.parentArticle {
      desc.append("parent: '\(parentArticle.messageId)'\n")
    }
    for (headerName, headerValue) in self.headers {
      desc.append("'\(headerName)': '\(headerValue)'\n")
    }

    desc.deleteCharacters(in: NSRange(location: desc.length - 1, length: 1))
    return desc as String
  }
}
