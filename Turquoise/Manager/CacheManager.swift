import Foundation
import CoreData
import UIKit

protocol CacheManagerProtocol {
    func loadGroup(withId id: String) -> Group?
    func save(group: Group) -> Bool

    func loadArticle(withMessageId messageId: String) -> Article?
    func save(article: Article) -> Bool
}

class CacheManager {
    static let sharedInstance = CacheManager()
    private var managedContext: NSManagedObjectContext

    init() {
        let appDelegate = UIApplication.shared.delegate as! TQAppDelegate
        self.managedContext = appDelegate.persistentContainer.viewContext
    }
}

extension CacheManager: CacheManagerProtocol {
    func loadGroup(withId id: String) -> Group? {
        return nil
    }

    func save(group: Group) -> Bool {
        return false
    }

    func loadArticle(withMessageId messageId: String) -> Article? {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ArticleEntity")
        fetchRequest.predicate = NSPredicate(format: "messageId == %@", messageId)

        var managedObjects: [NSManagedObject] = []
        do {
            managedObjects = try self.managedContext.fetch(fetchRequest)
        } catch {
            // Something bad happened.
            return nil
        }

        guard
            let managedObject = managedObjects.first,
            let jsonString = managedObject.value(forKey: "jsonString") as? String,
            let json = jsonString.convertToJson() else {
                // Article does not exist in cache.
                return nil
        }

        return Article(json: json)
    }

    func save(article: Article) -> Bool {
        guard
            let jsonString = article.convertToJson()?.toJSONString(),
            let entity = NSEntityDescription.entity(forEntityName: "ArticleEntity", in: self.managedContext) else {
                return false
        }

        let managedArticleObject = NSManagedObject(entity: entity, insertInto: self.managedContext)
        managedArticleObject.setValue(article.messageId, forKey: "messageId")
        managedArticleObject.setValue(jsonString, forKey: "jsonString")

        do {
          try self.managedContext.save()
        } catch {
          printError("Could not save article object: \(error)")
          return false
        }

        return true
    }
}

//class TQCacheManager : NSObject {
//  func getGroupWith(id: String) -> TQNNTPGroup? {
//    return nil
//  }
//
//  func save(group: TQNNTPGroup) -> Bool {
//    guard self.managedContext != nil else {
//      return false
//    }
//
//    guard let entity = NSEntityDescription.entity(forEntityName: "Group", in: self.managedContext) else {
//      return false
//    }
//
//    let managedGroupObject = NSManagedObject(entity: entity, insertInto: self.managedContext)
//    managedGroupObject.setValue(group.groupId, forKey: "groupId")
//
//    var messageIds: [String] = []
//    for article in group.articles {
//      messageIds.append(article.messageId)
//    }
//    managedGroupObject.setValue(messageIds, forKey: "messageIds")
//
//    do {
//      try self.managedContext.save()
//    } catch {
//      printError("Could not save group object: \(error)")
//      return false
//    }
//
//    return true
//  }
//
//  func load(groupId: String) -> TQNNTPGroup? {
//    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Group")
//    fetchRequest.predicate = NSPredicate(format: "groupId == %@", groupId)
//    var managedObjects: [NSManagedObject] = []
//    do {
//      managedObjects = try self.managedContext.fetch(fetchRequest)
//    } catch {
//      // something bad happened.
//      return nil
//    }
//
//    guard let managedObject = managedObjects.first else {
//      // article does not exist in cache.
//      return nil
//    }
//
//    let messageIds = managedObject.value(forKey: "messageIds") as! [String]
//    var articles: [TQNNTPArticle] = []
//
//    for messageId in messageIds {
//      if let article = self.load(messageId: messageId) {
//        articles.append(article)
//      }
//    }
//
//    return TQNNTPGroup(groupId: groupId, articles: articles)
//  }
//
