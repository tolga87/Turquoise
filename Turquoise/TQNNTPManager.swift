import Foundation
import UIKit

typealias TQNNTPRequestCallback = (_ response: TQNNTPResponse?, _ error: Error?) -> Void

class TQNNTPManager : NSObject {
  static let sharedInstance = TQNNTPManager()
  private let reachability: Reachability!

  static let networkConnectionLostNotification = Notification.Name("networkConnectionLostNotification")
  static let networkStreamDidResetNotification = Notification.Name("networkStreamDidResetNotification")
  static let NNTPGroupListDidUpdateNotification = Notification.Name("NNTPGroupListDidUpdateNotification")
  static let NNTPGroupDidReceiveHeadersNotification = Notification.Name("NNTPGroupDidReceiveHeadersNotification")
  static let didReceiveArticleBodyNotification = Notification.Name("didReceiveArticleBodyNotification")
  static let didPostArticleNotification = Notification.Name("didPostArticleNotification")

  // TODO: revamp these errors
  let TQNNTPManagerErrorDomain = "TQNNTPManagerErrorDomain"
  let newsServerHostName = "news.ceng.metu.edu.tr"
  let newsServerPort = 563
  let timeout: TimeInterval = 10

  var networkReachable: Bool {
    return self.reachability.connection != .none
  }
  private(set) var allGroups: [TQNNTPGroup] = []
  private(set) var currentGroup: TQNNTPGroup?

  private var streamTask: URLSessionStreamTask?
  private var dataBuffer: Data?
  private var allgroups: [TQNNTPGroup] = []

  private var streamResetTimer: Timer?

  override init() {
    self.reachability = Reachability(hostname: self.newsServerHostName)
    super.init()

    self.reachability.whenReachable = { (reachability) -> Void in
      self.reachabilityChanged(connection: reachability.connection)
    }
    self.reachability.whenUnreachable = { (reachability) -> Void in
      self.reachabilityChanged(connection: reachability.connection)
    }

    do {
      try self.reachability.startNotifier()
    } catch {
      printError("Could not start reachability notifier: \(error)")
    }


    let notificationCenter = NotificationCenter.default
    notificationCenter.addObserver(self,
                                   selector: #selector(appDidEnterBackground),
                                   name: UIApplication.didEnterBackgroundNotification,
                                   object: nil)
    notificationCenter.addObserver(self,
                                   selector: #selector(appDidBecomeActive),
                                   name: UIApplication.didBecomeActiveNotification,
                                   object: nil)
  }

  // TODO: Convert NSErrors to Errors
  func GetGenericError() -> NSError {
    return NSError(domain: self.TQNNTPManagerErrorDomain,
                   code: -1003,
                   userInfo: [ NSLocalizedDescriptionKey : "Something went wrong"])
  }

  func GetError(message: String?) -> NSError {
    let defaultErrorMessage = "Something went wrong"
    return NSError(domain: self.TQNNTPManagerErrorDomain,
                   code: 0,
                   userInfo: [ NSLocalizedDescriptionKey : (message ?? defaultErrorMessage) ])
  }

  func reachabilityChanged(connection: Reachability.Connection) {
    printInfo("Reachability changed: \(connection.description)")
    if connection == .none {
      self.streamTask?.stopSecureConnection()
      self.streamTask = nil
      NotificationCenter.default.post(name: TQNNTPManager.networkConnectionLostNotification, object: self)
    }
  }

  func setupStream() {
//  _streamTask = [[NSURLSession sharedSession] streamTaskWithHostName:kNewsServerHostName
//                                                                port:kNewsServerPort];
    // TODO: is this necessary?
    let session = URLSession(configuration: URLSessionConfiguration.default,
                             delegate: nil,
                             delegateQueue: OperationQueue.main)
    self.streamTask = session.streamTask(withHostName: self.newsServerHostName,
                                         port: self.newsServerPort)
    self.streamTask?.startSecureConnection()
  }

  @objc func appDidEnterBackground() {
    let timerTimeInterval = TimeInterval(5 * 60)  // reset after 5 minutes

    self.streamResetTimer?.invalidate()
    self.streamResetTimer =
      Timer.scheduledTimer(withTimeInterval: timerTimeInterval,
                           repeats: false,
                           block: { (timer: Timer) in
                            self.streamTask?.stopSecureConnection()
                            self.streamTask = nil
                            NotificationCenter.default.post(name: TQNNTPManager.networkStreamDidResetNotification,
                                                            object: self)

    })
  }

  func login(userName: String,
             password: String,
             completion loginCallback: @escaping TQNNTPRequestCallback) {
    if userName.isEmpty {
      let error = NSError(domain: self.TQNNTPManagerErrorDomain,
                          code: -1000,
                          userInfo: [ NSLocalizedDescriptionKey : "Invalid user name"] )
      loginCallback(nil, error)
      return
    } else if password.isEmpty {
      let error = NSError(domain: self.TQNNTPManagerErrorDomain,
                          code: -1001,
                          userInfo: [ NSLocalizedDescriptionKey : "Invalid password"] )
      loginCallback(nil, error)
      return
    }

    self.setupStream()

    guard let streamTask = self.streamTask else {
      return
    }

    let sendUserNameBlock = { (userName: String, callback: @escaping TQNNTPRequestCallback) -> Void in
      let command = "AUTHINFO USER \(userName)\r\n"

      self.sendRequest(command, completion: { (response, error) in
        // TODO: get rid of "responseCodeValue"
        if response != nil && response!.responseCodeValue == TQNNTPResponseCode.enterPassword.rawValue {
          callback(response, nil)
        } else {
          callback(nil, self.GetGenericError())
        }
      })
    }

    let sendPasswordBlock =  { (password: String, callback: @escaping TQNNTPRequestCallback) -> Void in
      let command = "AUTHINFO PASS \(password)\r\n"

      self.sendRequest(command, completion: { (response, error) in
        callback(response, error)
      })
    }

    streamTask.readData(ofMinLength: 0,
                        maxLength: 4096,
                        timeout: self.timeout) { (data, atEOF, error) in
                          var response: TQNNTPResponse?
                          if let data = data {
                            let responseString = String(data: data, encoding: .utf8)
                            response = TQNNTPResponse(string: responseString)
                          }

                          // TODO: fix
                          if response != nil && response!.responseCodeValue != TQNNTPResponseCode.serverReady.rawValue {
                            // something's wrong
                            let error = NSError(domain: self.TQNNTPManagerErrorDomain,
                                                code: -1002,
                                                userInfo: [ NSLocalizedDescriptionKey : "Server not ready" ])
                            loginCallback(nil, error)
                            return
                          }


                          sendUserNameBlock(userName, { (response, error) -> Void in
                            guard let _ = response else {
                              // sending user name failed.
                              loginCallback(nil, self.GetGenericError())
                              return
                            }

                            sendPasswordBlock(password, { (response, error) -> Void in
                              guard let _ = response else {
                                // sending password failed.
                                loginCallback(nil, self.GetGenericError())
                                return
                              }

                              // login successful, download list of groups.
                              self.listGroups(completion: { (response, error) in
                                loginCallback(response, error)
                              })
                            })
                          })
    }
    streamTask.resume()
  }

  func listGroups(completion: @escaping TQNNTPRequestCallback) {
    printInfo("Requesting list of all newsgroups...")

    self.sendRequest("LIST\r\n") { (response, error) in
      if let response = response, response.isOk() {
        self.allGroups = []

        if let message = response.message {
          let lines = message.components(separatedBy: "\r\n")
          for line in lines.dropFirst() {
            // skip the 0th line, it just contains information about the syntax.
            let lineComps = line.components(separatedBy: .whitespaces)

            if lineComps.count >= 4 {
              let groupId = lineComps[0]
              let articleNo1 = Int(lineComps[1]) ?? 0
              let articleNo2 = Int(lineComps[2]) ?? 0
              let minArticleNo = min(articleNo1, articleNo2)
              let maxArticleNo = max(articleNo1, articleNo2)
              let moderated = lineComps[3].lowercased() == "m"
              let group = TQNNTPGroup(groupId: groupId,
                                      minArticleNo: minArticleNo,
                                      maxArticleNo: maxArticleNo,
                                      moderated: moderated)
              self.allGroups.append(group)
            }
          }
        }
      }

      self.allGroups.sort {
        $0.groupId.localizedCaseInsensitiveCompare($1.groupId) == .orderedAscending
      }
      NotificationCenter.default.post(name: TQNNTPManager.NNTPGroupListDidUpdateNotification, object: self)
      completion(response, error)
    }
  }

  func setGroup(groupId: String, completion: @escaping TQNNTPRequestCallback) {
    printInfo("User selected new group: \(groupId)")

    let requestString = "GROUP \(groupId)\r\n"

    self.sendRequest(requestString) { (response, error) in
      if let response = response, response.isOk() {
        self.currentGroup = TQNNTPGroup(response: response)
        completion(response, error)
      }

//      self.currentGroup?.downloadHeaders(completion: {
//        printInfo("All headers are downloaded")
//        NotificationCenter.default.post(name: TQNNTPManager.NNTPGroupDidReceiveHeadersNotification,
//                                        object: self,
//                                        userInfo: nil)
//      })
    }
  }

  func refreshGroup() {
    guard let groupId = self.currentGroup?.groupId else {
      // TODO: error
      return
    }

    self.setGroup(groupId: groupId) { (_, _) in }
  }

  func requestBody(of article: TQNNTPArticle, completion: @escaping TQNNTPRequestCallback) {
    if let cachedArticle = TQCacheManager.sharedInstance.load(messageId: article.messageId) {
      for (key, value) in cachedArticle.dictionaryRepresentation() {
        article.setValue(value, forKey: key)
      }

      let response = TQNNTPResponse(responseCode: .articleBodyFollows)
      completion(response, nil)
      printInfo("Article \(article.messageId) was loaded from cache.")
      return
    }

    let requestString = "BODY \(article.messageId)\r\n"
    self.sendRequest(requestString) { (response, error) in
      if let response = response, response.isOk() {
        NotificationCenter.default.post(name: TQNNTPManager.didReceiveArticleBodyNotification,
                                        object: self,
                                        userInfo: nil)
        article.body = response.getArticleBody() ?? ""
        TQReadArticlesManager.sharedInstance.markAsRead(article)
        if TQCacheManager.sharedInstance.save(article: article) {
          printInfo("Article \(article.messageId) saved to cache.")
        }
      }
      completion(response, error)
    }
  }

  func post(article: TQNNTPArticle, completion: @escaping TQNNTPRequestCallback) {
    let requestString = "POST\r\n"
    self.sendRequest(requestString) { (response, error) in
      guard let response = response, let message = response.message else {
        // TODO: error
        return
      }

      guard response.isOkSoFar() else {
        completion(response, self.GetError(message: "Server does not accept message posting"))
        return
      }

      var messageId = ""
      if message.lowercased().contains("recommended message-id") {
        let messageComps = message.components(separatedBy: .whitespaces)

        for i in 0 ..< messageComps.count {
          if messageComps[i].lowercased() == "message-id" {
            messageId = messageComps[i + 1].tq_newlineStrippedString
            break
          }
        }
      } else {
        // TODO: handle this case (generate a random message-ID).
      }

      article.messageId = messageId
      let postRequestString = article.buildPostRequest()
      self.sendRequest(postRequestString, completion: { (response, error) in
        if let response = response, response.isOk() {
          // success
          NotificationCenter.default.post(name: TQNNTPManager.didPostArticleNotification, object: self)
          self.refreshGroup()
        } else {
          // failure
        }

        completion(response, error)
      })
    }

  }

  func bufferData(partNo: Int, completion: @escaping (_ data: Data?) -> Void) {
    guard let streamTask = self.streamTask else {
      return
    }

    streamTask.readData(ofMinLength: 0,
                        maxLength: 10000,
                        timeout: self.timeout) { (data: Data?, atEOF: Bool, error: Error?) in
                          guard let data = data else {
                            completion(nil)
                            return
                          }

                          var isMultiLine: Bool = true


                          if partNo == 0 {
                            self.dataBuffer = Data()
                            var statusCode = 0

                            if data.count >= 3 {
                              // first 3 bytes must contain the status code.
                              let responseCodeData = data.subdata(in: 0..<3)
                              let responseCodeString = String(data: responseCodeData, encoding: .utf8) ?? ""
                              statusCode = Int(responseCodeString) ?? 0
                              isMultiLine = TQNNTPResponse.isMultiLine(statusCode)
                            } else {
                              // TODO: we shouldn't receive fewer than 3 bytes in the first part.
                              //       if this happens, something's wrong. look into this.
                            }
                          } else {
                            printDebug("\t\t <<< received partial response: part \(partNo) >>>")
                          }


                          if !isMultiLine {
                            completion(data)
                            return
                          }

                          // here, we know we are dealing with a multi-line response.
                          self.dataBuffer?.append(data)

                          var isFinished = false
                          guard let dataBuffer = self.dataBuffer else {
                            return
                          }
                          if dataBuffer.count >= 5 {
                            let subData = dataBuffer[dataBuffer.count - 5 ..< dataBuffer.count]
                            let terminatingString = String(data: subData, encoding: .utf8)
                            if terminatingString == "\r\n.\r\n" {
                              isFinished = true
                            }
                          }

                          if isFinished {
                            completion(self.dataBuffer)
                          } else {
                            self.bufferData(partNo: (partNo + 1), completion: completion)
                          }
    }
}

  func sendRequest(_ requestString: String, completion: @escaping TQNNTPRequestCallback) {
    guard !requestString.isEmpty else {
      completion(nil, nil)  // TODO: error.
      return
    }
    guard let streamTask = self.streamTask else {
      completion(nil, nil)  // TODO: error.
      return
    }

    let requestData = requestString.data(using: .utf8)!

    streamTask.write(requestData,
                     timeout: self.timeout) { (error: Error?) in
                      if error != nil {
                        completion(nil, nil)  // TODO: error.
                        return
                      }

                      self.bufferData(partNo: 0, completion: { (data: Data?) in
                        guard let data = data else {
                          completion(nil, nil)  // TODO: error.
                          return
                        }

                        let responseString = String(data: data, encoding: .utf8)
                        let response = TQNNTPResponse(string: responseString)

                        let shouldTruncate = true
                        let maxLengthToDisplay = shouldTruncate ? 150 : Int.max
                        let responseLength = Int(responseString?.count ?? 0)

                        if let responseString = responseString {
                          if responseLength > maxLengthToDisplay {
                            let truncatedResponseStringEndIndex = responseString.index(responseString.startIndex,
                                                                                       offsetBy: maxLengthToDisplay)
                            let truncatedResponseString = responseString.substring(to: truncatedResponseStringEndIndex)
                            printDebug("S: \(truncatedResponseString) <TRUNCATED>")
                          } else {
                            printDebug("S: \(responseString)")
                          }
                        }

                        completion(response, nil)
                      })
    }
}

  @objc func appDidBecomeActive() {
    self.streamResetTimer?.invalidate()
    self.streamResetTimer = nil
  }
}
