#import <UIKit/UIKit.h>

@interface UIView (NibLoader)

+ (UIView *)tq_loadFromNib:(NSString *)nibName owner:(id)owner;

@end
