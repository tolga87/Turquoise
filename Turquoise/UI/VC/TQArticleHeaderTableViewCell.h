
#import <UIKit/UIKit.h>

@interface TQArticleHeaderTableViewCell : UITableViewCell

@property(nonatomic) IBOutlet UIView *paddingView;
@property(nonatomic) IBOutlet UILabel *articleTitleLabel;
@property(nonatomic) IBOutlet UILabel *articleSenderLabel;
@property(nonatomic) IBOutlet NSLayoutConstraint *paddingViewWidthConstraint;

@property(nonatomic) NSUInteger articleLevel;

+ (UIColor *)evenColor;

+ (UIColor *)oddColor;

@end
