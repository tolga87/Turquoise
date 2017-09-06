#import "TQOverlay.h"

#import "TQOverlayBackgroundView.h"

@class TQOverlaySlidingMenu;

@interface TQOverlay ()

@property(nonatomic) TQOverlaySlidingMenu *slidingMenu;
@property(nonatomic) UIView *scrollingView;
@property(nonatomic, readonly) TQOverlayBackgroundView *overlayView;

@end
