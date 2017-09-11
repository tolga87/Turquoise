#import "TQLogoutConfirmationView.h"

#import "TQOverlay.h"
#import "TQUserInfoManager.h"
#import "UIView+NibLoader.h"

@implementation TQLogoutConfirmationView

- (instancetype)init {
  self = (TQLogoutConfirmationView *) [UIView tq_loadFromNib:@"TQLogoutConfirmationView" owner:self];
  return self;
}

- (IBAction)cancelButtonDidTap:(id)sender {
  [[TQOverlay sharedInstance] dismissAnimated:YES];
}

- (IBAction)logoutButtonDidTap:(id)sender {
  NSLog(@"~TA LOGOUT BUTTON TAPPED!");
  [[TQUserInfoManager sharedInstance] resetUserCredentials];
  [[TQOverlay sharedInstance] dismissAnimated:YES];
}

@end
