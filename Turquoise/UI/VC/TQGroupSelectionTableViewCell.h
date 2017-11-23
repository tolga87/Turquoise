#import <UIKit/UIKit.h>

@interface TQGroupSelectionTableViewCell : UITableViewCell

@property(nonatomic) TQNNTPGroup *group;
@property(nonatomic) IBOutlet UIImageView *statusIconView;
@property(nonatomic) IBOutlet UILabel *groupNameLabel;

// TODO: eliminate duplicate code
+ (UIColor *)evenColor;

+ (UIColor *)oddColor;

@end
