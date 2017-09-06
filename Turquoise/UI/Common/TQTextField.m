
#import "TQTextField.h"

@interface TQTextField ()<UITextFieldDelegate>
@end

@implementation TQTextField {
  NSMutableString *_password;
}

static NSString *const kAsteriskString = @"****************************************************************";
static const NSUInteger kMaxPasswordLength = 64;

+ (NSString *)hiddenStringForString:(NSString *)string {
  if (!string) {
    return nil;
  }

  NSUInteger length = MIN(kMaxPasswordLength, string.length);
  return [kAsteriskString substringToIndex:length];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  if (self) {
    self.delegate = self;
    self.autocorrectionType = UITextAutocorrectionTypeNo;
    [self addTarget:self
               action:@selector(textUpdated)
      forControlEvents:UIControlEventEditingChanged];
  }
  return self;
}

- (void)setIsPassword:(BOOL)isPassword {
  if (isPassword != _isPassword) {
    _isPassword = isPassword;
    self.text = @"";
    _password = [NSMutableString string];
  }
}

- (NSString *)password {
  return [_password copy];
}

- (void)textUpdated {
  if (_isPassword) {
    self.text = [[self class] hiddenStringForString:self.text];
  }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField
  shouldChangeCharactersInRange:(NSRange)range
              replacementString:(NSString *)string {
  if (_isPassword) {
    [_password replaceCharactersInRange:range withString:string];
  }
  return YES;
}

#pragma mark - UITextField Overrides

- (CGRect)textRectForBounds:(CGRect)bounds {
  return CGRectInset(bounds , 10, 0);
}
- (CGRect)editingRectForBounds:(CGRect)bounds {
  return CGRectInset(bounds , 10, 0);
}

@end
