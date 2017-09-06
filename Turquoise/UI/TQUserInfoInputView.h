
#import <UIKit/UIKit.h>

typedef void(^TQUserInfoInputViewCompletionBlock)(NSString *userFullName, NSString *userEmail);

@interface TQUserInfoInputView : UIView

@property(nonatomic, copy) TQUserInfoInputViewCompletionBlock completionBlock;

@end
