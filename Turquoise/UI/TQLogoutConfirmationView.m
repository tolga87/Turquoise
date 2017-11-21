#import "TQLogoutConfirmationView.h"

#import "TQUserInfoManager.h"

@implementation TQLogoutConfirmationView

- (instancetype)init {
  self = (TQLogoutConfirmationView *) [UIView tq_loadFrom:@"TQLogoutConfirmationView" owner:self];
  return self;
}

- (IBAction)cancelButtonDidTap:(id)sender {
  [[TQOverlay sharedInstance] dismissWithAnimated:YES];
}

- (IBAction)logoutButtonDidTap:(id)sender {
  [[TQUserInfoManager sharedInstance] resetUserCredentials];
  [[TQOverlay sharedInstance] dismissWithAnimated:YES];
}

@end
