import Foundation

@objc enum TQNNTPResponseCode : Int {
  case other              = 0
  case serverReady        = 200
  case groupSelected      = 211
  case informationFollows = 215
  case articleBodyFollows = 222
  case enterPassword      = 381
  case authSucceeded      = 281
  case noArticle          = 423
  case authFailed         = 481
  case alreadyAuth        = 502
}

@objc enum TQNNTPResponseType : Int {
  case informative = 1
  case OK          = 2
  case OKSoFar     = 3
  case failed      = 4
  case unavailable = 5
}

@objc enum TQNNTPResponseCategory : Int {
  case articleSelection = 2
}

//1xx - Informative message
//2xx - Command completed OK
//3xx - Command OK so far; send the rest of it
//4xx - Command was syntactically correct but failed for some reason
//5xx - Command unknown, unsupported, unavailable, or syntax error

@objc class TQNNTPResponse : NSObject {
  private(set) var responseCodeValue: Int = 0
  var responseCode: TQNNTPResponseCode? {
    get {
      return TQNNTPResponseCode(rawValue: self.responseCodeValue)
    }
  }
  private(set) var message: String?

  class func responseFor(value rawValue: Int) -> TQNNTPResponseCode {
    return TQNNTPResponseCode(rawValue: rawValue) ?? .other
  }

  class func isMultiLine(_ statusCode: Int) -> Bool {
    let firstDigit = statusCode / 100 % 10
    let secondDigit = statusCode / 10 % 10
    //  let thirdDigit = statusCode.rawValue % 10

    if self.responseFor(value: statusCode) == .informationFollows {
      return true
    }
    return (firstDigit == TQNNTPResponseType.OK.rawValue && secondDigit == TQNNTPResponseCategory.articleSelection.rawValue)
  }

  init?(string: String?) {
    guard let string = string, string.count > 0 else {
      return nil
    }

    let scanner = Scanner(string: string)
    var value: Int = 0
    scanner.scanInt(&value)
    self.responseCodeValue = value

    var responseMessage = ""
    var line: NSString?

    while true {
      let charsRead = scanner.scanUpTo("\r\n", into: &line)
      if charsRead {
        responseMessage += "\(line! as String)\r\n"
      } else {
        break
      }
    }

    self.message = responseMessage
  }

  func isOk() -> Bool {
    // TODO: reimplement these enums to make them more Swift-friendly
    return self.responseCodeValue / 100 == TQNNTPResponseType.OK.rawValue
  }

  func isOkSoFar() -> Bool {
    return self.responseCodeValue / 100 == TQNNTPResponseType.OKSoFar.rawValue
  }

  func isFailure() -> Bool {
    return self.responseCodeValue / 100 == TQNNTPResponseType.failed.rawValue
  }

  func getArticleBody() -> String? {
    if self.responseCode != .articleBodyFollows {
      return nil
    }

    // although technically "\r\n" is two bytes, Swift treats it as a single Character
    let newline = "\r\n"
    let terminator = "\r\n.\r\n"

    guard let message = self.message, message.hasSuffix(terminator) else {
      return nil
    }

    guard let newLineIndex = message.index(of: "\r\n") else {
      return nil
    }

    let messageStartIndex = message.index(newLineIndex, offsetBy: newline.count)
    let messageEndIndex = message.index(message.endIndex, offsetBy: -terminator.count)
    let messageRange = messageStartIndex..<messageEndIndex
    return message[messageRange]
  }

  // MARK: - CustomDebugStringConvertible

  override var debugDescription: String {
    return "\(self.responseCodeValue) \(self.message ?? "")"
  }
}
