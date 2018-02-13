import Foundation
import UIKit

class TQGroupViewController : UIViewController, UITableViewDelegate {
  @IBOutlet var tableView: TQRefreshableTableView!
  @IBOutlet var groupNameLabel: UILabel!

  var dataSource: TQGroupTableViewDataSource!

  var selectedArticle: TQNNTPArticle?
  let nntpManager = TQNNTPManager.sharedInstance
  static let userDidChangeGroupNotification = Notification.Name("userDidChangeGroupNotification")

  override func viewDidLoad() {
    super.viewDidLoad()

    self.tableView.delegate = self

    self.dataSource = TQGroupTableViewDataSource(tableView: self.tableView,
                                                 group: self.nntpManager.currentGroup)
    self.dataSource.refreshCallback = {
      guard let groupId = self.dataSource.group?.groupId else {
        return
      }

      self.nntpManager.setGroup(groupId: groupId) { (response, error) in
        self.tableView?.reloadData()
      }
    }
    self.tableView.dataSource = self.dataSource
    self.dataSource.tableView = self.tableView

    self.tableView.beginRefreshing()

    self.groupNameLabel.text = self.nntpManager.currentGroup?.groupId

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
        self.nntpManager.setGroup(groupId: subscribedGroupId,
                                  completion: { (response, error) in
                                    if let response = response, response.isOk() {
                                      self.dataSource.group = self.nntpManager.currentGroup
                                      self.groupNameLabel.text = self.nntpManager.currentGroup?.groupId

                                      self.tableView.reloadData()
                                      self.tableView.beginRefreshing()
                                      NotificationCenter.default.post(name: TQGroupViewController.userDidChangeGroupNotification,
                                                                      object: self)
                                    }
        })
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


  func groupDidChange(_ notification: Notification) {
    if let currentGroup = self.nntpManager.currentGroup {
      printInfo("Group changed. Current group: '\(currentGroup)'")
    }

    self.dataSource = TQGroupTableViewDataSource(tableView: self.tableView,
                                                 group: self.nntpManager.currentGroup)
    self.tableView.reloadData()
    self.groupNameLabel.text = self.nntpManager.currentGroup?.groupId
  }

  func userDidLogout(_ notification: Notification) {
    self.dismiss(animated: true, completion: nil)
  }

  // MARK: - UITableViewDelegate

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let selectedArticle = self.dataSource.articleAt(indexPath: indexPath) else {
      // TODO: error
      tableView.deselectRow(at: indexPath, animated: true)
      return
    }

    self.selectedArticle = selectedArticle
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
      articleViewController.newsGroup = self.dataSource.group
      articleViewController.article = self.selectedArticle

    case "PostNewMessageSegueID":
      let articleComposerViewController = segue.destination as! TQArticleComposerViewController
      articleComposerViewController.newsGroup = self.dataSource.group
    default:
      ()
    }
  }
}
