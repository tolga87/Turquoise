
#import <UIKit/UIKit.h>

@interface TQTextField : UITextField

@property(nonatomic) BOOL isPassword;
@property(nonatomic, readonly, copy) NSString *password;

+ (NSString *)hiddenStringForString:(NSString *)string;

@end