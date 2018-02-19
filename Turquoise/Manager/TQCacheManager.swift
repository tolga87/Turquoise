import Foundation
import CoreData
import UIKit

class TQCacheManager : NSObject {
  static let sharedInstance = TQCacheManager()
  private var managedContext: NSManagedObjectContext!

  override private init() {
    guard let appDelegate = UIApplication.shared.delegate as? TQAppDelegate else {
      return
    }

    self.managedContext = appDelegate.persistentContainer.viewContext
  }

  func getGroupWith(id: String) -> TQNNTPGroup? {
    return nil
  }

  func save(article: TQNNTPArticle) -> Bool {
    guard self.managedContext != nil else {
      return false
    }

    let articleData = article.dictionaryRepresentation()
    guard let entity = NSEntityDescription.entity(forEntityName: "Article", in: self.managedContext) else {
      return false
    }

    let managedArticleObject = NSManagedObject(entity: entity, insertInto: self.managedContext)
    for (key, value) in articleData {
      managedArticleObject.setValue(value, forKey: key)
    }

    do {
      try self.managedContext.save()
    } catch {
      printError("Could not save article object: \(error)")
      return false
    }

    return true
  }

  func load(messageId: String) -> TQNNTPArticle? {
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Article")
    fetchRequest.predicate = NSPredicate(format: "messageId == %@", messageId)
    var managedObjects: [NSManagedObject] = []
    do {
      managedObjects = try self.managedContext.fetch(fetchRequest)
    } catch {
      // something bad happened.
      return nil
    }

    guard let managedObject = managedObjects.first else {
      // article does not exist in cache.
      return nil
    }

    return TQNNTPArticle(managedObject: managedObject)
  }


}
