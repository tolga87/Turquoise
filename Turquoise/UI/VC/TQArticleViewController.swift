import Foundation
import UIKit

class TQArticleViewController : UIViewController {

  var article: TQNNTPArticle?
  var newsGroup: TQNNTPGroup?

  @IBOutlet var articleSubjectLabel: TQLabel!
  @IBOutlet var articleSenderLabel: TQLabel!
  @IBOutlet var articleDateLabel: TQLabel!
  @IBOutlet var articleBodyTextView: UITextView!
  @IBOutlet var deleteArticleButton: UIButton!
  @IBOutlet var deleteButtonHeight: NSLayoutConstraint!

  override func viewDidLoad() {
    super.viewDidLoad()

    self.articleSubjectLabel.text = self.article?.decodedSubject
    self.articleSenderLabel.text = self.article?.decodedFrom
    self.articleDateLabel.text = self.article?.date
    self.articleBodyTextView.text = self.article?.body

    let shouldShowDeleteButton = self.canDeleteMessage()
    self.setDeleteMessageButtonHidden(!shouldShowDeleteButton)
    self.articleBodyTextView.contentOffset = .zero
  }

  @IBAction func dismiss(_ sender: Any?) {
    self.dismiss(animated: true, completion: nil)
  }

  @IBAction func cancelArticle(_ sender: Any?) {
    guard let article = self.article else {
      // TODO: error
      return
    }
    guard let cancelArticle = TQNNTPArticle.cancelArticle(from: article) else {
      // TODO: error
      return
    }

    TQNNTPManager.sharedInstance.post(article: cancelArticle) { (response, error) in
      if let response = response, response.isOk() {
        printInfo("Message canceled")
      } else {
        printError("Message could not be canceled: \(error != nil ? error.debugDescription : "")")
      }

      self.dismiss(animated: true, completion: nil)
    }
  }

  func canDeleteMessage() -> Bool {
    // TODO: make this method more robust
    let userInfoManager = TQUserInfoManager.sharedInstance
    guard let article = self.article, let userFullName = userInfoManager.fullName, let userEmail = userInfoManager.email else {
      return false
    }

    return article.from.contains(userFullName) && article.from.contains(userEmail)
  }

  func setDeleteMessageButtonHidden(_ hidden: Bool) {
    self.deleteButtonHeight.constant = hidden ? 0 : 30
    self.deleteArticleButton.isHidden = hidden
  }

  // MARK: - Navigation

  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let articleComposer = segue.destination as? TQArticleComposerViewController {
      articleComposer.newsGroup = self.newsGroup
      articleComposer.parentArticle = self.article
    }
  }
}
