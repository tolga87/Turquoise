import Foundation
import UIKit

class LoginViewController : UIViewController {
    var autoLogin: Bool = false
    var navController: UINavigationController?

    private let contentView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = #colorLiteral(red: 0.3725490196, green: 0.6588235294, blue: 0.8117647059, alpha: 1)
        return view
    }()
    private let infoLabel: TQLabel = {
        let label = TQLabel(frame: .zero)
        label.fontSize = 12
        label.minimumScaleFactor = 0.8
        label.textColor = .white
        label.textAlignment = .center
        label.text = "Please enter your COW credentials below."
        return label
    }()
    private let userLabel: TQLabel = {
        let label = TQLabel(frame: .zero)
        label.fontSize = 12
        label.minimumScaleFactor = 0.8
        label.textColor = .black
        label.textAlignment = .left
        label.text = "User"
        return label
    }()
    private let passwordLabel: TQLabel = {
        let label = TQLabel(frame: .zero)
        label.fontSize = 12
        label.minimumScaleFactor = 0.8
        label.textColor = .black
        label.textAlignment = .left
        label.text = "Pass"
        return label
    }()

    private let userNameField: TextField = {
        let field = TextField()
        field.autocapitalizationType = .none
        field.horizontalInset = 10
        field.fontSize = 12
        field.layer.borderColor = UIColor.black.cgColor
        field.layer.borderWidth = 1
        return field
    }()
    private let passwordField: PasswordField = {
        let field = PasswordField()
        field.autocapitalizationType = .none
        field.horizontalInset = 10
        field.fontSize = 12
        field.layer.borderColor = UIColor.black.cgColor
        field.layer.borderWidth = 1
        return field
    }()

    private let loginButton: UIButton = {
        let button = UIButton(type: .custom)
        button.titleLabel?.font = UIFont(name: "dungeon", size: 14)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.01960784314, green: 0.1254901961, blue: 0.5647058824, alpha: 1)
        button.setTitle("Proceed", for: .normal)
        return button
    }()

    private let activityIndicator = UIActivityIndicatorView(style: .white)
    private let connectionStatusLabel: TQLabel = {
        let label = TQLabel(frame: .zero)
        label.fontSize = 12
        label.minimumScaleFactor = 0.8
        label.textColor = .white
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let versionNumberLabel: TQLabel = {
        let label = TQLabel(frame: .zero)
        label.fontSize = 12
        label.textColor = .darkGray
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let usenetClient: UsenetClientInterface = UsenetClient.sharedInstance
    private let subscriptionManager = SubscriptionManager()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)

        self.loginButton.isEnabled = true

        guard self.autoLogin else {
            return
        }

        // TODO: Fix.
        // Don't attempt to connect if we appeared because of a network disconnection

        self.autoLogin = false
        self.loginWithSavedCredentialsIfPossible()
    }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.navigationController?.setNavigationBarHidden(true, animated: false)
    self.view.backgroundColor = .black

    let contentXPadding: CGFloat = 8
    let contentYPadding: CGFloat = 4

    self.view.addSubview(self.contentView)
    self.contentView.translatesAutoresizingMaskIntoConstraints = false
    self.contentView.leadingAnchor.constraint(equalTo: self.view.safeLeadingAnchor, constant: 24).isActive = true
    self.contentView.trailingAnchor.constraint(equalTo: self.view.safeTrailingAnchor, constant: -24).isActive = true
    self.contentView.topAnchor.constraint(equalTo: self.view.safeTopAnchor, constant: 100).isActive = true
    self.contentView.heightAnchor.constraint(equalToConstant: 140).isActive = true

    for view in [ infoLabel, userLabel, userNameField, passwordLabel, passwordField, loginButton, activityIndicator ] {
        view.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(view)
    }

    // INFO

    self.infoLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor,
                                            constant: contentXPadding).isActive = true
    self.infoLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor,
                                             constant: -contentXPadding).isActive = true
    self.infoLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor,
                                        constant: contentYPadding).isActive = true
    self.infoLabel.heightAnchor.constraint(equalToConstant: 32).isActive = true

    // USER LABEL

    self.userLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor,
                                            constant: contentXPadding).isActive = true
    self.userLabel.trailingAnchor.constraint(equalTo: self.userNameField.leadingAnchor,
                                             constant: -contentXPadding).isActive = true
    self.userLabel.topAnchor.constraint(equalTo: self.userNameField.topAnchor).isActive = true
    self.userLabel.widthAnchor.constraint(equalToConstant: 48).isActive = true
    self.userLabel.heightAnchor.constraint(equalTo: self.userNameField.heightAnchor).isActive = true

    // USER NAME

    self.userNameField.leadingAnchor.constraint(equalTo: self.userLabel.trailingAnchor,
                                                constant: contentXPadding).isActive = true
    self.userNameField.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor,
                                                 constant: -contentXPadding).isActive = true
    self.userNameField.topAnchor.constraint(equalTo: self.infoLabel.bottomAnchor,
                                            constant: contentYPadding).isActive = true
    self.userNameField.bottomAnchor.constraint(equalTo: self.passwordField.topAnchor,
                                                constant: 0).isActive = true

    // PASSWORD LABEL

    self.passwordLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor,
                                                constant: contentXPadding).isActive = true
    self.passwordLabel.trailingAnchor.constraint(equalTo: self.passwordField.leadingAnchor,
                                                 constant: -contentXPadding).isActive = true
    self.passwordLabel.bottomAnchor.constraint(equalTo: self.passwordField.bottomAnchor).isActive = true
    self.passwordLabel.widthAnchor.constraint(equalTo: self.userLabel.widthAnchor).isActive = true
    self.passwordLabel.heightAnchor.constraint(equalTo: self.passwordField.heightAnchor).isActive = true

    // PASSWORD

    self.passwordField.leadingAnchor.constraint(equalTo: self.passwordLabel.trailingAnchor,
                                                constant: contentXPadding).isActive = true
    self.passwordField.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor,
                                                 constant: -contentXPadding).isActive = true
    self.passwordField.topAnchor.constraint(equalTo: self.userNameField.bottomAnchor,
                                            constant: 0).isActive = true
    self.passwordField.bottomAnchor.constraint(equalTo: self.loginButton.topAnchor,
                                               constant: -contentYPadding).isActive = true
    self.userNameField.heightAnchor.constraint(equalTo: self.passwordField.heightAnchor).isActive = true

    // LOGIN BUTTON

    self.loginButton.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor,
                                               constant: -contentXPadding).isActive = true
    self.loginButton.topAnchor.constraint(equalTo: self.passwordField.bottomAnchor,
                                          constant: contentYPadding).isActive = true
    self.loginButton.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor,
                                             constant: -contentYPadding).isActive = true
    self.loginButton.widthAnchor.constraint(equalToConstant: 120).isActive = true
    self.loginButton.heightAnchor.constraint(equalToConstant: 32).isActive = true

    // SPINNER

    self.activityIndicator.trailingAnchor.constraint(equalTo: self.loginButton.leadingAnchor,
                                                     constant: -contentXPadding).isActive = true
    self.activityIndicator.centerYAnchor.constraint(equalTo: self.loginButton.centerYAnchor).isActive = true

    // CONNECTION STATUS

    self.view.addSubview(self.connectionStatusLabel)
    self.connectionStatusLabel.topAnchor.constraint(equalTo: self.loginButton.bottomAnchor,
                                                    constant: 8).isActive = true
    self.connectionStatusLabel.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor).isActive = true
    self.connectionStatusLabel.widthAnchor.constraint(equalTo: self.contentView.widthAnchor).isActive = true
    self.connectionStatusLabel.heightAnchor.constraint(equalToConstant: 32).isActive = true

    // VERSION NUMBER LABEL

    self.view.addSubview(self.versionNumberLabel)
    self.versionNumberLabel.bottomAnchor.constraint(equalTo: self.view.safeBottomAnchor,
                                                    constant: -contentYPadding).isActive = true
    self.versionNumberLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
    self.versionNumberLabel.widthAnchor.constraint(equalToConstant: 80).isActive = true
    self.versionNumberLabel.heightAnchor.constraint(equalToConstant: 32).isActive = true

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
//    NotificationCenter.default.addObserver(self,
//                                           selector: #selector(networkConnectionLost(_:)),
//                                           name: TQNNTPManager.networkConnectionLostNotification,
//                                           object: nil)
//    NotificationCenter.default.addObserver(self,
//                                           selector: #selector(nntpManagerDidReset(_:)),
//                                           name: TQNNTPManager.networkStreamDidResetNotification,
//                                           object: nil)
  }

    @objc func networkConnectionLost(_ notification: Notification) {
    printInfo("Disconnected from server!")
    self.dismiss(animated: true, completion: nil)
    self.connectionStatusLabel.text = "Disconnected from server, please login again."
  }

    @objc func nntpManagerDidReset(_ notification: Notification) {
    printInfo("NNTP manager was reset")
    self.dismiss(animated: true, completion: nil)
  }

    @objc func userDidLogout(_ notification: Notification) {
    self.userNameField.text = ""
    self.passwordField.text = ""
  }

    @objc func loginButtonDidTap(_ sender: Any?) {
    let foundUserCredentials = self.loginWithSavedCredentialsIfPossible()
    if !foundUserCredentials {
      let userName = self.userNameField.text?.tq_whitespaceAndNewlineStrippedString ?? ""
      let password = self.passwordField.password.tq_whitespaceAndNewlineStrippedString

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

    // TODO: Handle network connectivity issues.
//    let manager = TQNNTPManager.sharedInstance
//    if !manager.networkReachable {
//      self.connectionStatusLabel.text = "No network connection"
//      self.loginButton.isEnabled = true
//      self.activityIndicator.stopAnimating()
//      return
//    }

    self.connectionStatusLabel.text = "Connecting..."
    self.loginButton.isEnabled = false
    self.activityIndicator.startAnimating()

    let loginManager = LoginManager(usenetClient: self.usenetClient)

    loginManager.loginFailureCallback = {
        printInfo("Login Failed!")
        self.connectionStatusLabel.text = "Invalid username/password"
        self.activityIndicator.stopAnimating()
        self.loginButton.isEnabled = true
    }

    loginManager.loginSuccessCallback = {
        printInfo("Login Successful!")
        self.connectionStatusLabel.text = "Login successful!"

        self.showGroupVC()

        if askUserInfo {
            self.showUserInfoInputDialog()
        }
    }

    loginManager.login(userName: userName, password: password)
  }

    private func showUserInfoInputDialog() {
        let alertMessage = "Please enter your name and email address. This info will be visible to other users of the news server."
        let alertController = UIAlertController(title: "",
                                                message: alertMessage,
                                                preferredStyle: .alert)
        alertController.addTextField(configurationHandler: { (nameField) in
            nameField.placeholder = "Name"
        })
        alertController.addTextField(configurationHandler: { (emailField) in
            emailField.placeholder = "Email"
        })
        alertController.addAction(UIAlertAction(title: "Proceed", style: .default, handler: { (action) in
            guard
                let textFields = alertController.textFields,
                textFields.count >= 2,
                let name = textFields[0].text?.tq_whitespaceAndNewlineStrippedString,
                let email = textFields[0].text?.tq_whitespaceAndNewlineStrippedString,
                !name.isEmpty,
                !email.isEmpty else {
                    return
            }

            //              let userInfoManager = TQUserInfoManager.sharedInstance
            //              userInfoManager.userName = userName
            //              userInfoManager.password = password
            //              userInfoManager.fullName = fullName
            //              userInfoManager.email = email
        }))

        let presentingController = self.navController ?? self
        presentingController.present(alertController, animated: true, completion: nil)
    }

    func showGroupVC() {
        let groupSelectorVC = GroupSelectorViewController(usenetClient: self.usenetClient,
                                                          subscriptionManager: self.subscriptionManager)

        let navController = UINavigationController(rootViewController: groupSelectorVC)
        navController.navigationBar.barTintColor = .clear
        navController.modalTransitionStyle = .crossDissolve
        self.present(navController, animated: true, completion: nil)
        self.navController = navController

        self.connectionStatusLabel.text = nil
        self.loginButton.isEnabled = true
        self.activityIndicator.stopAnimating()
    }
}
