#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TQOverlay : NSObject

+ (instancetype)sharedInstance;

+ (NSTimeInterval)animationDuration;

- (void)showWithView:(UIView *)contentView animated:(BOOL)animated;

- (void)showWithView:(UIView *)contentView
  relativeVerticalPosition:(CGFloat)relativeVerticalPosition
                  animated:(BOOL)animated;

- (void)dismissAnimated:(BOOL)animated;

@end
