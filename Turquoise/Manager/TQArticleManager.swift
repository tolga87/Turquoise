import Foundation

typealias TQGroupFetchCallback = (TQNNTPGroup?) -> ()

class TQArticleManager: NSObject {
  private var nntpManager: TQNNTPManager
  private var cacheManager: TQCacheManager

  private var groups: [String : TQNNTPGroup] = [:]

  let groupDidUpdateNotification = Notification.Name("groupDidUpdateNotification")
  let updatedGroupKey = "updatedGroup"

  init(nntpManager: TQNNTPManager, cacheManager: TQCacheManager) {
    self.nntpManager = nntpManager
    self.cacheManager = cacheManager
  }

  func getGroup(id: String) -> TQNNTPGroup? {
    return self.cacheManager.load(groupId: id)
  }

  func refreshGroupHeaders(groupId: String) {
    let headersDownloadBlock = { (group: TQNNTPGroup) -> Void in
      group.downloadHeaders {
        printInfo("Headers downloaded for group `\(group.groupId)`")

        for article in group.articles {
          self.cacheManager.save(article: article)
        }
        self.cacheManager.save(group: group)

        NotificationCenter.default.post(name: self.groupDidUpdateNotification,
                                        object: self,
                                        userInfo: [self.updatedGroupKey : group])
      }
    }

    if let currentGroup = self.nntpManager.currentGroup, currentGroup.groupId == groupId {
      headersDownloadBlock(currentGroup)
    } else {
      self.nntpManager.setGroup(groupId: groupId) { (response, error) in
        if let currentGroup = self.nntpManager.currentGroup, currentGroup.groupId == groupId {
          headersDownloadBlock(currentGroup)
        }
      }
    }
  }
}
