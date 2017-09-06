#import "TQOverlay+Extensions.h"

typedef void(^TQSlidingMenuCallback)(void);

@interface TQOverlaySlidingMenu : NSObject

+ (void)showSlidingMenuWithVerticalOffset:(CGFloat)verticalOffset
                                    texts:(NSArray<NSString *> *)texts
                                callbacks:(NSArray<TQSlidingMenuCallback> *)callbacks;

+ (void)dismissSlidingMenuCompletion:(void (^)(BOOL))completion;

@end
