import Foundation
import UIKit

class TQArticleComposerViewController : UIViewController {
  @IBOutlet var articleSubjectField: UITextField!
  @IBOutlet var articleBodyView: UITextView!

  var newsGroup: TQNNTPGroup?
  var parentArticle: TQNNTPArticle?

  override func viewDidLoad() {
    super.viewDidLoad()

    let placeholderTextColor = UIColor(white: 0.6, alpha: 1)
    self.articleSubjectField.attributedPlaceholder =
      NSAttributedString(string: "Subject:",
                         attributes: [ NSForegroundColorAttributeName : placeholderTextColor ])
    var subject = ""
    if let parentArticle = self.parentArticle {
      subject = parentArticle.decodedSubject
      if !subject.hasPrefix("Re: ") {
        subject = "Re: \(subject)"
      }
    }

    self.articleSubjectField.text = subject
  }

  func dismissArticleComposer() {
    self.dismiss(animated: true, completion: nil)
  }

  @IBAction func dismiss(_ sender: Any?) {
    self.dismissArticleComposer()
  }

  @IBAction func postArticle(_ sender: Any?) {
    guard let articleSubjectText = self.articleSubjectField.text, !articleSubjectText.tq_isEmpty else {
      // TODO: alert
      printError("Cannot post message with empty subject")
      return
    }
    guard let articleBodyText = self.articleBodyView.text, !articleBodyText.tq_isEmpty else {
      // TODO: alert
      printError("Cannot post message with empty body")
      return
    }

    let subject = articleSubjectText.tq_whitespaceAndNewlineStrippedString
    let message = articleBodyText.tq_whitespaceAndNewlineStrippedString
    guard let article = TQNNTPArticle(subject: subject,
                                message: message,
                                newsGroup: self.newsGroup,
                                parentArticle: self.parentArticle) else {
                                  // something went wrong. cannot post article.
                                  // TODO: show error.
                                  printError("Not implemented yet!")
                                  return
    }

    TQNNTPManager.sharedInstance.post(article: article) { (response, error) in
      if let response = response, response.isOk() {
        printInfo("Article posted")
      } else {
        printError("Could not post article: \(error != nil ? error.debugDescription : "")")
      }

      self.dismissArticleComposer()
    }
  }
}
