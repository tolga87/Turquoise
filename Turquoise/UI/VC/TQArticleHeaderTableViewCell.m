
#import "TQArticleHeaderTableViewCell.h"

@implementation TQArticleHeaderTableViewCell

+ (UIColor *)evenColor {
  return [UIColor colorWithRed:8. / 255.
                         green:20. / 255.
                          blue:50. / 255.
                         alpha:1];
}

+ (UIColor *)oddColor {
  return [UIColor colorWithRed:8. / 255.
                         green:20. / 255.
                          blue:0. / 255.
                         alpha:1];
}

- (void)awakeFromNib {
  [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];
}

- (void)setArticleLevel:(NSUInteger)articleLevel {
  _paddingViewWidthConstraint.constant = 4 * articleLevel;
}

@end
