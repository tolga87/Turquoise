
#import "TQLabel.h"

static NSString *const kHorizontalInsetKey = @"horizontalInset";
static NSString *const kVerticalInsetKey = @"verticalInset";

@implementation TQLabel

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  if (self) {
    CGFloat fontSize = self.font.pointSize;
    self.font = [UIFont fontWithName:@"dungeon" size:fontSize];
  }

  return self;
}

- (void)setHorizontalInset:(CGFloat)horizontalInset {
  if (_horizontalInset != horizontalInset) {
    _horizontalInset = horizontalInset;
    [self setNeedsLayout];
  }
}

- (void)setVerticalInset:(CGFloat)verticalInset {
  if (_verticalInset != verticalInset) {
    _verticalInset = verticalInset;
    [self setNeedsLayout];
  }
}

#pragma mark - UILabel Overrides

- (void)drawTextInRect:(CGRect)rect {
  // top, left, bottom, right
  UIEdgeInsets insets = {_verticalInset, _horizontalInset, _verticalInset, _horizontalInset};
  [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}

@end
