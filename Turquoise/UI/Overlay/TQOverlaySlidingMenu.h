#import "TQOverlay+Extensions.h"

typedef void(^TQSlidingMenuCallback)(void);

typedef NS_ENUM(NSInteger, TQOverlaySlidingMenuPosition) {
  TQOverlaySlidingMenuPositionRight,
  TQOverlaySlidingMenuPositionLeft
};

@interface TQOverlaySlidingMenu : NSObject

+ (void)showSlidingMenuWithPosition:(TQOverlaySlidingMenuPosition)position
                     verticalOffset:(CGFloat)verticalOffset
                              texts:(NSArray<NSString *> *)texts
                          callbacks:(NSArray<TQSlidingMenuCallback> *)callbacks;

+ (void)dismissSlidingMenuCompletion:(void (^)(BOOL))completion;

@end
