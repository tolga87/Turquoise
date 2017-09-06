#import "TQOverlayBackgroundView.h"

@implementation TQOverlayBackgroundView

- (void)layoutSubviews {
  [super layoutSubviews];

  if (self.superview) {
    self.frame = self.superview.bounds;
  }

  if (!self.manualLayout) {
    UIView *contentView = [self.subviews firstObject];
    if (contentView) {

      CGFloat centerY = CGRectGetMaxY(self.bounds) * self.relativeVerticalPosition;
      CGPoint subviewCenter = CGPointMake(self.center.x, centerY);
      contentView.center = [self convertPoint:subviewCenter
                                     fromView:self.superview];
    }
  }
}

@end
