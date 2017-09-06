#import <UIKit/UIKit.h>

#import "TQLabel.h"
#import "TQTextField.h"

@interface TQLoginViewController : UIViewController

@property(nonatomic) IBOutlet TQTextField *userNameField;
@property(nonatomic) IBOutlet TQTextField *passwordField;
@property (nonatomic) IBOutlet UIButton *loginButton;
@property (nonatomic) IBOutlet TQLabel *connectionStatusLabel;
@property (nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

