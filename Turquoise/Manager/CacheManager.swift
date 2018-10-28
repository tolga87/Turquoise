import Foundation
import CoreData
import UIKit

protocol CacheManagerProtocol {
    func save(group: Group) -> Bool
    func loadGroup(withId id: String) -> Group?

    func save(articleHeaders: ArticleHeaders, articleNo: Int) -> Bool
    func loadArticleHeaders(withArticleNo articleNo: Int) -> ArticleHeaders?

    func save(articleBody: String, messageId: String) -> Bool
    func loadArticleBody(withMessageId messageId: String) -> String?
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
    func save(group: Group) -> Bool {
        assertionFailure("TODO: Implement")
        return false
    }

    func loadGroup(withId id: String) -> Group? {
        assertionFailure("TODO: Implement")
        return nil
    }

    @discardableResult
    func save(articleHeaders: ArticleHeaders, articleNo: Int) -> Bool {
        guard
            let jsonString = articleHeaders.convertToJson()?.toString(),
            let entity = NSEntityDescription.entity(forEntityName: "ArticleHeadersEntity", in: self.managedContext) else {
                return false
        }

        let managedArticleObject = NSManagedObject(entity: entity, insertInto: self.managedContext)
        managedArticleObject.setValue(articleNo, forKey: "articleNo")
        managedArticleObject.setValue(jsonString, forKey: "jsonString")

        do {
            try self.managedContext.save()
        } catch {
            printError("Could not save article object: \(error)")
            return false
        }

        return true
    }

    func loadArticleHeaders(withArticleNo articleNo: Int) -> ArticleHeaders? {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ArticleHeadersEntity")
        fetchRequest.predicate = NSPredicate(format: "articleNo == %d", articleNo)

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
                // Article headers does not exist in cache.
                return nil
        }

        return ArticleHeaders(json: json)
    }

    @discardableResult
    func deleteArticleHeaders(withArticleNo articleNo: Int) -> Bool {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ArticleHeadersEntity")
        fetchRequest.predicate = NSPredicate(format: "articleNo == %d", articleNo)

        var managedObjects: [NSManagedObject] = []
        do {
            managedObjects = try self.managedContext.fetch(fetchRequest)
        } catch {
            // Something bad happened.
            return false
        }

        for object in managedObjects {
            self.managedContext.delete(object)
        }

        do {
            try self.managedContext.save()
        } catch {
            printError("Could not delete article headers: \(error)")
            return false
        }

        return true
    }

    @discardableResult
    func deleteArticleBody(withMessageId messageId: String) -> Bool {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ArticleBodyEntity")
        fetchRequest.predicate = NSPredicate(format: "messageId == %d", messageId)

        var managedObjects: [NSManagedObject] = []
        do {
            managedObjects = try self.managedContext.fetch(fetchRequest)
        } catch {
            // Something bad happened.
            return false
        }

        for object in managedObjects {
            self.managedContext.delete(object)
        }

        do {
            try self.managedContext.save()
        } catch {
            printError("Could not delete article body: \(error)")
            return false
        }

        return true
    }

    @discardableResult
    func save(articleBody: String, messageId: String) -> Bool {
        guard let entity = NSEntityDescription.entity(forEntityName: "ArticleBodyEntity", in: self.managedContext) else {
            return false
        }

        let managedArticleObject = NSManagedObject(entity: entity, insertInto: self.managedContext)
        managedArticleObject.setValue(messageId, forKey: "messageId")
        managedArticleObject.setValue(articleBody, forKey: "body")

        do {
            try self.managedContext.save()
        } catch {
            printError("Could not save article object: \(error)")
            return false
        }

        return true
    }

    func loadArticleBody(withMessageId messageId: String) -> String? {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ArticleBodyEntity")
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
            let body = managedObject.value(forKey: "body") as? String else {
                // Article body does not exist in cache.
                return nil
        }

        return body
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
