import Foundation
import UIKit

class TQGroupViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
  @IBOutlet var tableView: UITableView!
  @IBOutlet var groupNameLabel: UILabel!

  var group: TQNNTPGroup? {
    didSet {
      if let group = self.group {
        self.expandedArticleForest = group.articleForest?.expandedForest()
        self.groupNameLabel.text = group.groupId
      } else {
        self.expandedArticleForest = nil
        self.groupNameLabel.text = nil
      }
    }
  }
  var expandedArticleForest: [TQNNTPArticle]?
  var selectedArticle: TQNNTPArticle?
  let nntpManager = TQNNTPManager.sharedInstance
  static let userDidChangeGroupNotification = Notification.Name("userDidChangeGroupNotification")

  override func viewDidLoad() {
    super.viewDidLoad()

    self.tableView.dataSource = self
    self.tableView.delegate = self

    self.group = self.nntpManager.currentGroup
    self.groupNameLabel.text = self.group?.groupId
    self.expandedArticleForest = self.group?.articleForest?.expandedForest()

    NotificationCenter.default.addObserver(self,
                                           selector: #selector(groupDidUpdate(_:)),
                                           name: TQNNTPManager.NNTPGroupDidUpdateNotification,
                                           object: nil)
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(userDidLogout(_:)),
                                           name: TQUserInfoManager.sharedInstance.userDidLogoutNotification,
                                           object: nil)
  }

  @IBAction func newsgroupsButtonDidTap(_ sender: UIButton) {
    let subscribedGroupIds: [String] = TQUserInfoManager.sharedInstance.sortedSubscribedGroupIds ?? []
    var callbacks: [() -> Void] = []

    for subscribedGroupId in subscribedGroupIds {
      callbacks.append {
        printInfo("User selected new group: \(subscribedGroupId)")
        if let progressView = TQHeaderDownloadProgressView.loadFromNib(groupId: subscribedGroupId) {
          TQOverlay.sharedInstance.show(with: progressView, relativeVerticalPosition: 0.35, animated: false)
          self.nntpManager.setGroup(groupId: subscribedGroupId,
                                    completion: { (response, error) in
                                      TQOverlay.sharedInstance.dismiss(animated: true)
                                      NotificationCenter.default.post(name: TQGroupViewController.userDidChangeGroupNotification, object: self)
          })
        }
      }
    }

    let settingsButton = sender
    var position = settingsButton.convert(settingsButton.frame.origin, to: nil)
    position.y += settingsButton.frame.height

    TQOverlaySlidingMenu.showSlidingMenu(position: .left,
                                         verticalOffset: position.y,
                                         title: "Select newsgroup to display",
                                         texts: subscribedGroupIds,
                                         callbacks: callbacks)
  }

  @IBAction func settingsButtonDidTap(_ sender: UIButton) {
    let options = [
      "Manage newsgroup subscriptions",
      "Logout",
      "Release notes",
      "View Source",
      "Rate Ayran\u{00A0}2.0 on the App Store",  // \u{00A0} is the nbsp chararacter
    ]
    let callbacks = [
      {
        self.performSegue(withIdentifier: "ManageSubscriptionsSegueId", sender: self)
      },
      {
        if let logoutView = TQLogoutConfirmationView.loadFromNib() {
          TQOverlay.sharedInstance.show(with: logoutView, relativeVerticalPosition: 0.35, animated: false)
        }
      },
      {
        if let releaseNotesView = TQReleaseNotesView.loadFromNib() {
          TQOverlay.sharedInstance.show(with: releaseNotesView, relativeVerticalPosition: 0.35, animated: true)
        }
      },
      {
        guard let url = URL(string: "https://github.com/tolga87/Turquoise") else {
          return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
      },
      {
        TQReviewManager.sharedInstance.showReviewPrompt()
      }
    ]

    let settingsButton = sender
    var position = settingsButton.convert(settingsButton.frame.origin, to: nil)
    position.y += settingsButton.frame.height
    TQOverlaySlidingMenu.showSlidingMenu(position: .right,
                                         verticalOffset: position.y,
                                         title: nil,
                                         texts: options,
                                         callbacks: callbacks)
  }


  @objc func groupDidUpdate(_ notification: Notification) {
    if let currentGroup = self.nntpManager.currentGroup {
      printInfo("Group info updated. Current group: '\(currentGroup)'")
    }
    self.group = self.nntpManager.currentGroup
    self.tableView.reloadData()
  }

  @objc func userDidLogout(_ notification: Notification) {
    self.dismiss(animated: true, completion: nil)
  }

  // MARK: - UITableViewDataSource

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let articleForest = self.group?.articleForest else {
      return 0
    }
    return articleForest.numArticles
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleSubjectCell",
                                             for: indexPath) as! TQArticleHeaderTableViewCell
    guard let article = self.expandedArticleForest?[indexPath.row] else {
      return cell
    }

    cell.updateWith(article: article)
    cell.contentView.backgroundColor = (indexPath.row % 2 == 0)
      ? TQArticleHeaderTableViewCell.evenColor
      : TQArticleHeaderTableViewCell.oddColor

    return cell
  }

  // MARK: - UITableViewDelegate

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    self.selectedArticle = self.expandedArticleForest![indexPath.row]
    guard let selectedArticle = self.selectedArticle else {
      // TODO: error
      tableView.deselectRow(at: indexPath, animated: true)
      return
    }

    self.nntpManager.requestBody(of: selectedArticle) { (response, error) in
      tableView.deselectRow(at: indexPath, animated: true)

      if let response = response, response.isOk() {
        self.performSegue(withIdentifier: "ShowBodySegueID", sender: self)
      } else {
        self.selectedArticle = nil
        // TODO: process error
      }
    }
  }

  // MARK: - Navigation

  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let segueId = segue.identifier else {
      return
    }

    switch segueId {
    case "ShowBodySegueID":
      let articleViewController = segue.destination as! TQArticleViewController
      articleViewController.newsGroup = self.group
      articleViewController.article = self.selectedArticle

    case "PostNewMessageSegueID":
      let articleComposerViewController = segue.destination as! TQArticleComposerViewController
      articleComposerViewController.newsGroup = self.group
    default:
      ()
    }
  }
}
