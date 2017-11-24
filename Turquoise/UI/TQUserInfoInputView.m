
#import "TQUserInfoInputView.h"

@implementation TQUserInfoInputView {
  IBOutlet TQTextField *_userFullNameTextField;
  IBOutlet TQTextField *_userEmailTextField;
}

- (IBAction)proceedButtonDidTap:(id)sender {
  //~TA TODO: fix
//  NSString *userFullName = [_userFullNameTextField.text tq_whitespaceAndNewlineStrippedString];
//  NSString *userEmail = [_userEmailTextField.text tq_whitespaceAndNewlineStrippedString];
  NSString *userFullName = _userFullNameTextField.text;
  NSString *userEmail = _userEmailTextField.text;

  if (userFullName.length > 0 && userEmail.length > 0) {
    // TODO: verify email format
    if (_completionBlock) {
      _completionBlock(userFullName, userEmail);
    }
    [[TQOverlay sharedInstance] dismissWithAnimated:YES];
  }
}

@end
