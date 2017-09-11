#import "UIView+NibLoader.h"

@implementation UIView (NibLoader)

+ (UIView *)tq_loadFromNib:(NSString *)nibName owner:(id)owner {
  if (nibName.length == 0) {
    return nil;
  }
  UIView *view = [[NSBundle mainBundle] loadNibNamed:nibName owner:owner options:nil].firstObject;
  return view;
}

@end
