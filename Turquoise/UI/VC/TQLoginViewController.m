
#import "TQLoginViewController.h"

#import "NSString+TQEncoding.h"
#import "TQNNTPManager.h"
#import "TQNNTPResponse.h"
#import "TQUserInfoInputView.h"
#import "TQUserInfoManager.h"

@implementation TQLoginViewController {
  TQUserInfoManager *_userInfoManager;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  _loginButton.enabled = YES;

  // TODO: separate this logic from view lifecycle methods
  if ([TQNNTPManager sharedInstance].networkReachable) {
    // don't attempt to connect if we appeared because of a network disconnection
    [self loginWithSavedCredentialsIfPossible];
  }
}

- (void)viewDidLoad {
  [super viewDidLoad];

  _userInfoManager = [TQUserInfoManager sharedInstance];

  _passwordField.isPassword = YES;
  [_loginButton addTarget:self
                   action:@selector(loginButtonDidTap:)
         forControlEvents:UIControlEventTouchUpInside];
  [_activityIndicator stopAnimating];

  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(userDidLogout)
                                               name:kUserDidLogoutNotification
                                             object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(networkConnectionLost)
                                               name:kNetworkConnectionLostNotification
                                             object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(nntpManagerDidReset)
                                               name:kNetworkStreamDidResetNotification
                                             object:nil];
}

- (void)networkConnectionLost {
  TQLogInfo(@"Disconnected from server!");
  [self dismissViewControllerAnimated:YES completion:nil];
  _connectionStatusLabel.text = @"Disconnected from server, please login again.";
}

- (void)nntpManagerDidReset {
  TQLogInfo(@"NNTP manager was reset");
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)userDidLogout {
  _userNameField.text = @"";
  _passwordField.text = @"";
}

- (void)loginButtonDidTap:(id)sender {
  BOOL foundUserCredentials = [self loginWithSavedCredentialsIfPossible];
  if (!foundUserCredentials) {
    NSString *userName = [_userNameField.text tq_whitespaceAndNewlineStrippedString];
    NSString *password = [_passwordField.password tq_whitespaceAndNewlineStrippedString];
    if (userName.length > 0 && password.length > 1) {
      [self loginWithUserName:userName password:password askUserInfo:YES];
    }
  }
}

- (IBAction)backgroundDidTap:(id)sender {
  [self.view endEditing:YES];
}

// returns YES if username and password are found in Keychain; NO otherwise
- (BOOL)loginWithSavedCredentialsIfPossible {
  NSString *userName = _userInfoManager.userName;
  NSString *password = _userInfoManager.password;

  if (userName.length > 0 && password.length > 1) {
    TQLogInfo(@"Logging in with credentials found in Keychain...");
    _userNameField.text = userName;
    _passwordField.text = password;
    [self loginWithUserName:userName password:password askUserInfo:NO];
    return YES;
  } else {
    TQLogInfo(@"User credentials not found in Keychain; user must log in manually.");
    return NO;
  }
}

- (void)loginWithUserName:(NSString *)userName
                 password:(NSString *)password
              askUserInfo:(BOOL)shouldAskUserInfo {
  if (userName.length == 0 || password.length < 1) {
    return;
  }

  // dismiss keyboard if necessary
  [self.view endEditing:YES];

  TQNNTPManager *manager = [TQNNTPManager sharedInstance];
  if (!manager.networkReachable) {
    _connectionStatusLabel.text = @"No network connection";
    _loginButton.enabled = YES;
    [_activityIndicator stopAnimating];
    return;
  }

  _connectionStatusLabel.text = @"Connecting...";
  _loginButton.enabled = NO;
  [_activityIndicator startAnimating];

  [manager loginWithUserName:userName password:password completion:^(TQNNTPResponse *response, NSError *error) {
    if ([response isFailure]) {
      TQLogInfo(@"Login Failed!");
      _connectionStatusLabel.text = @"Invalid username/password";
      [_activityIndicator stopAnimating];
      _loginButton.enabled = YES;
      return;
    } else if (![response isOk]) {
      // not sure what happened here.
      _loginButton.enabled = YES;
      return;
    }

    // login successful.
    TQLogInfo(@"Login Successful!");
    _connectionStatusLabel.text = @"Login successful, downloading data from server...";

    if (shouldAskUserInfo) {
      TQUserInfoInputView *userInfoInputView =
      (TQUserInfoInputView *)[UIView tq_loadFrom:@"TQUserInfoInputView" owner:self];
      userInfoInputView.completionBlock = ^(NSString *userFullName, NSString *userEmail) {
        _userInfoManager.userName = userName;
        _userInfoManager.password = password;
        _userInfoManager.fullName = userFullName;
        _userInfoManager.email = userEmail;

      };
      [[TQOverlay sharedInstance] showWith:userInfoInputView
                  relativeVerticalPosition:.3
                                  animated:YES];
    }

    //    NSString *groupId = @"metu.ceng.ses";
    NSString *groupId = @"metu.ceng.test";
    //    NSString *groupId = @"metu.ceng.announce.jobs";
    //      NSString *groupId = @"metu.ceng.announce.sales";
    //    NSString *groupId = @"metu.ceng.kult.kitap";
    //    NSString *groupId = @"metu.ceng.course.465";
    //    NSString *groupId = @"metu.ceng.course.140";
    //      NSString *groupId = @"metu.ceng.course.316";

    [manager setGroup:groupId completion:^(TQNNTPResponse *response, NSError *error) {
      if ([response isOk]) {
        [self performSegueWithIdentifier:@"ShowGroupSegueID" sender:self];
        _connectionStatusLabel.text = nil;
        _loginButton.enabled = YES;
        [_activityIndicator stopAnimating];
      } else {
        // TODO: what should we do here?..
      }
    }];
  }];
}

@end































