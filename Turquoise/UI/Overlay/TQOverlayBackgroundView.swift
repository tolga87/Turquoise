import Foundation
import UIKit

class TQOverlayBackgroundView : UIView {
  var manualLayout: Bool = false
  var relativeVerticalPosition: CGFloat = 0

  override func layoutSubviews() {
//      [super layoutSubviews];
    super.layoutSubviews()
//
//      if (self.superview) {
//        self.frame = self.superview.bounds;
//      }
    if let superview = self.superview {
      self.frame = superview.bounds
    }
//
//      if (!self.manualLayout) {
//        UIView *contentView = [self.subviews firstObject];
//        if (contentView) {
//
//          CGFloat centerY = CGRectGetMaxY(self.bounds) * self.relativeVerticalPosition;
//          CGPoint subviewCenter = CGPointMake(self.center.x, centerY);
//          contentView.center = [self convertPoint:subviewCenter
//            fromView:self.superview];
//        }
//      }

    if !self.manualLayout {
      if let contentView = self.subviews.first {
        let centerY = self.bounds.maxY * self.relativeVerticalPosition
        let subviewCenter = CGPoint(x: self.center.x, y: centerY)
        contentView.center = self.convert(subviewCenter, from: self.superview)
      }
    }
  }
}
