import Foundation
import UIKit

class TQLoginViewController : UIViewController {
  @IBOutlet var userNameField: TQTextField!
  @IBOutlet var passwordField: TQTextField!
  @IBOutlet var loginButton: UIButton!
  @IBOutlet var connectionStatusLabel: TQLabel!
  @IBOutlet var activityIndicator: UIActivityIndicatorView!
  @IBOutlet var versionNumberLabel: UILabel!

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    self.loginButton.isEnabled = true
    // TODO: separate this logic from view lifecycle methods
    if (TQNNTPManager.sharedInstance.networkReachable) {
      // don't attempt to connect if we appeared because of a network disconnection
      _ = self.loginWithSavedCredentialsIfPossible()
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    // Make sure the review manager is instantiated and listening for notifications.
    let _ = TQReviewManager.sharedInstance

    self.passwordField.isPassword = true

    self.loginButton.addTarget(self,
                               action: #selector(loginButtonDidTap(_:)),
                               for: .touchUpInside)
    self.activityIndicator.stopAnimating()

    if let appVersionString = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
      self.versionNumberLabel.text = "v\(appVersionString)"
    } else {
      self.versionNumberLabel.text = ""
    }

    NotificationCenter.default.addObserver(self,
                                           selector: #selector(userDidLogout(_:)),
                                           name: TQUserInfoManager.sharedInstance.userDidLogoutNotification,
                                           object: nil)
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(networkConnectionLost(_:)),
                                           name: TQNNTPManager.networkConnectionLostNotification,
                                           object: nil)
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(nntpManagerDidReset(_:)),
                                           name: TQNNTPManager.networkStreamDidResetNotification,
                                           object: nil)
  }

  func networkConnectionLost(_ notification: Notification) {
    printInfo("Disconnected from server!")
    self.dismiss(animated: true, completion: nil)
    self.connectionStatusLabel.text = "Disconnected from server, please login again."
  }

  func nntpManagerDidReset(_ notification: Notification) {
    printInfo("NNTP manager was reset")
    self.dismiss(animated: true, completion: nil)
  }

  func userDidLogout(_ notification: Notification) {
    self.userNameField.text = ""
    self.passwordField.text = ""
  }

  func loginButtonDidTap(_ sender: Any?) {
    let foundUserCredentials = self.loginWithSavedCredentialsIfPossible()
    if !foundUserCredentials {
      let userName = self.userNameField.text?.tq_whitespaceAndNewlineStrippedString ?? ""
      let password = self.passwordField.password?.tq_whitespaceAndNewlineStrippedString ?? ""

      if !userName.isEmpty && password.count > 1 {
        self.login(userName: userName, password: password, askUserInfo: true)
      }
    }
  }

  @IBAction func backgroundDidTap(sender: UIGestureRecognizer) {
    self.view.endEditing(true)
  }

  // returns YES if username and password are found in Keychain; NO otherwise
  func loginWithSavedCredentialsIfPossible() -> Bool {
    let userInfoManager = TQUserInfoManager.sharedInstance
    let userName = userInfoManager.userName ?? ""
    let password = userInfoManager.password ?? ""

    if !userName.isEmpty && password.count > 1 {
      printInfo("Logging in with credentials found in Keychain...")
      self.userNameField.text = userName
      self.passwordField.text = password
      self.login(userName: userName, password: password, askUserInfo: false)
      return true
    } else {
      printInfo("User credentials not found in Keychain; user must log in manually.")
      return false
    }
  }

  func login(userName: String, password: String, askUserInfo: Bool) {
    if userName.isEmpty || password.isEmpty {
      return
    }

    // dismiss keyboard if necessary
    self.view.endEditing(true)

    let manager = TQNNTPManager.sharedInstance
    if !manager.networkReachable {
      self.connectionStatusLabel.text = "No network connection"
      self.loginButton.isEnabled = true
      self.activityIndicator.stopAnimating()
      return
    }

    self.connectionStatusLabel.text = "Connecting..."
    self.loginButton.isEnabled = false
    self.activityIndicator.startAnimating()

    manager.login(userName: userName, password: password) { (response, error) in
      guard let response = response else {
        // TODO: error
        return
      }

      if response.isFailure() {
        printInfo("Login Failed!")
        self.connectionStatusLabel.text = "Invalid username/password"
        self.activityIndicator.stopAnimating()
        self.loginButton.isEnabled = true
        return
      } else if !response.isOk() {
        // not sure what happened here.
        self.loginButton.isEnabled = true
        return
      }

      // login successful.
      printInfo("Login Successful!")
      self.connectionStatusLabel.text = "Login successful!"

      if askUserInfo {
        let userInfoInputView = UIView.tq_load(from: "TQUserInfoInputView", owner: self) as! TQUserInfoInputView
        userInfoInputView.completionBlock = { (userFullName, userEmail) in
          let userInfoManager = TQUserInfoManager.sharedInstance
          userInfoManager.userName = userName
          userInfoManager.password = password
          userInfoManager.fullName = userFullName
          userInfoManager.email = userEmail
        }
        TQOverlay.sharedInstance.show(with: userInfoInputView,
                                      relativeVerticalPosition: 0.3,
                                      animated: true)
      }

      self.performSegue(withIdentifier: "ShowGroupSegueID", sender: self)
      self.connectionStatusLabel.text = nil
      self.loginButton.isEnabled = true
      self.activityIndicator.stopAnimating()
    }
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let segueId = segue.identifier, segueId == "ShowGroupSegueID" else {
      return
    }

    let groupViewController = segue.destination as! TQGroupViewController
    groupViewController.groupId = "metu.ceng.test"  // TODO: fix
  }
}
