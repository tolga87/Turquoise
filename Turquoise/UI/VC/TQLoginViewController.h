#import <UIKit/UIKit.h>

@class TQLabel;
@class TQTextField;

@interface TQLoginViewController : UIViewController

@property(nonatomic) IBOutlet TQTextField *userNameField;
@property(nonatomic) IBOutlet TQTextField *passwordField;
@property (nonatomic) IBOutlet UIButton *loginButton;
@property (nonatomic) IBOutlet TQLabel *connectionStatusLabel;
@property (nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

