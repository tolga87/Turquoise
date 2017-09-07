
#import "TQLoginViewController.h"

#import "NSString+TQEncoding.h"
#import "TQNNTPManager.h"
#import "TQNNTPResponse.h"
#import "TQOverlay.h"
#import "TQUserInfoInputView.h"
#import "TQUserInfoManager.h"

@implementation TQLoginViewController {
  TQUserInfoManager *_userInfoManager;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  _loginButton.enabled = YES;
  [self loginWithSavedCredentialsIfPossible];
}

- (void)viewDidLoad {
  [super viewDidLoad];

  _userInfoManager = [TQUserInfoManager sharedInstance];

  _passwordField.isPassword = YES;
  [_loginButton addTarget:self
                   action:@selector(loginButtonDidTap:)
         forControlEvents:UIControlEventTouchUpInside];
  [_activityIndicator stopAnimating];
}

- (void)loginButtonDidTap:(id)sender {
  NSString *userName = [_userNameField.text tq_whitespaceAndNewlineStrippedString];
  NSString *password = [_passwordField.password tq_whitespaceAndNewlineStrippedString];
  if (userName.length > 0 && password.length > 0) {
    [self loginWithUserName:userName password:password askUserInfo:YES];
  }
}

- (IBAction)backgroundDidTap:(id)sender {
  [self.view endEditing:YES];
}

- (void)loginWithSavedCredentialsIfPossible {
  NSString *userName = _userInfoManager.userName;
  NSString *password = _userInfoManager.password;

  if (userName.length > 0 && password.length > 0) {
    NSLog(@"Logging in with credentials found in Keychain...");
    _userNameField.text = userName;
    _passwordField.text = [[_passwordField class] hiddenStringForString:password];
    [self loginWithUserName:userName password:password askUserInfo:NO];
  } else {
    NSLog(@"User credentials not found in Keychain; user must log in manually.");
  }
}

- (void)loginWithUserName:(NSString *)userName
                 password:(NSString *)password
              askUserInfo:(BOOL)shouldAskUserInfo {
  if (userName.length == 0 || password.length == 0) {
    return;
  }

  // dismiss keyboard if necessary
  [self.view endEditing:YES];

  _connectionStatusLabel.text = @"Connecting...";
  _loginButton.enabled = NO;
  [_activityIndicator startAnimating];

  TQNNTPManager *manager = [TQNNTPManager sharedInstance];
  [manager loginWithUserName:userName password:password completion:^(TQNNTPResponse *response, NSError *error) {
    if ([response isFailure]) {
      NSLog(@"Login Failed!");
      _connectionStatusLabel.text = @"Invalid username/password";
      [_userInfoManager resetUserCredentials];
      [_activityIndicator stopAnimating];
      _loginButton.enabled = YES;
      return;
    } else if (![response isOk]) {
      // not sure what happened here.
      _loginButton.enabled = YES;
      return;
    }

    // login successful.
    NSLog(@"Login Successful!");
    _connectionStatusLabel.text = @"Login successful, downloading data from server...";

    if (shouldAskUserInfo) {
      TQUserInfoInputView *userInfoInputView =
          [[[NSBundle mainBundle] loadNibNamed:@"TQUserInfoInputView" owner:self options:nil] firstObject];
      userInfoInputView.completionBlock = ^(NSString *userFullName, NSString *userEmail) {
        _userInfoManager.userName = userName;
        _userInfoManager.password = password;
        _userInfoManager.fullName = userFullName;
        _userInfoManager.email = userEmail;

      };
      [[TQOverlay sharedInstance] showWithView:userInfoInputView
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
      } else {
        // TODO: what should we do here?..
      }
    }];
  }];
}

@end































