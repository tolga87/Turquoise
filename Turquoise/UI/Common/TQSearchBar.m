#import "TQSearchBar.h"

@implementation TQSearchBar {
  UITextField *_tq_textField;
}

- (UITextField *)tq_textField {
  if (!_tq_textField) {
    _tq_textField = [self findTextFieldRecursivelyStartingAtView:self];
  }
  return _tq_textField;
}

- (UITextField *)findTextFieldRecursivelyStartingAtView:(UIView *)view {
  if ([view isKindOfClass:[UITextField class]]) {
    return (UITextField *)view;
  }

  for (UIView *subview in view.subviews) {
    UITextField *textField = [self findTextFieldRecursivelyStartingAtView:subview];
    if (textField) {
      return textField;
    }
  }
  return nil;
}

@end
