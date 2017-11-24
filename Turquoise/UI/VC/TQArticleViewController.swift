import Foundation
import UIKit

public class TQArticleViewController : UIViewController {

  var article: TQNNTPArticle?
  var newsGroup: TQNNTPGroup?

  @IBOutlet var articleSubjectLabel: TQLabel!
  @IBOutlet var articleSenderLabel: TQLabel!
  @IBOutlet var articleDateLabel: TQLabel!
  @IBOutlet var articleBodyTextView: UITextView!
  @IBOutlet var deleteArticleButton: UIButton!
  @IBOutlet var deleteButtonHeight: NSLayoutConstraint!

  public override func viewDidLoad() {
    super.viewDidLoad()

    self.articleSubjectLabel.text = self.article?.decodedSubject
    self.articleSenderLabel.text = self.article?.decodedFrom
    self.articleDateLabel.text = self.article?.date
    self.articleBodyTextView.text = self.article?.body

    let shouldShowDeleteButton = self.canDeleteMessage()
    self.setDeleteMessageButtonHidden(!shouldShowDeleteButton)
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
        //~TA TODO: fix
        // TQLogInfo(@"Message canceled");
      } else {
        // TQLogError(@"Message could not be canceled: %@", error);
      }

      self.dismiss(animated: true, completion: nil)
    }
  }

  func canDeleteMessage() -> Bool {
    // TODO: make this method more robust
    // TODO: fix
    //  TQUserInfoManager *userInfoManager = [TQUserInfoManager sharedInstance];
    //  NSString *userFullName = userInfoManager.fullName;
    //  NSString *userEmail = userInfoManager.email;
    //
    //  return [_article.from containsString:userFullName] && [_article.from containsString:userEmail];
    return true
  }

  func setDeleteMessageButtonHidden(_ hidden: Bool) {
    self.deleteButtonHeight.constant = hidden ? 0 : 30
    self.deleteArticleButton.isHidden = hidden
  }

  // MARK: - Navigation

  // In a storyboard-based application, you will often want to do a little preparation before navigation
  public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let articleComposer = segue.destination as? TQArticleComposerViewController {
      articleComposer.newsGroup = self.newsGroup
      articleComposer.parentArticle = self.article
    }
  }
}
