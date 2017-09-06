#import "TQOverlay+Extensions.h"

#import "TQOverlayBackgroundView.h"
#import "TQOverlaySlidingMenu.h"

const NSTimeInterval kAnimationDuration = .2;

@interface TQOverlay() <UIGestureRecognizerDelegate>
@end

@implementation TQOverlay {
  TQOverlayBackgroundView *_overlayView;

  UIView *_scrollingView;
}

+ (instancetype)sharedInstance {
  static TQOverlay *globalOverlay = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    globalOverlay = [[self alloc] init];
  });

  return globalOverlay;
}

+ (NSTimeInterval)animationDuration {
  return kAnimationDuration;
}

- (void)showWithView:(UIView *)contentView animated:(BOOL)animated {
  [self showWithView:contentView relativeVerticalPosition:.5 animated:animated];
}

- (void)showWithView:(UIView *)contentView
  relativeVerticalPosition:(CGFloat)relativeVerticalPosition
                  animated:(BOOL)animated {
    if (_overlayView) {
    [_overlayView removeFromSuperview];
  }

  UIWindow *window = [UIApplication sharedApplication].keyWindow;
  CGRect frame = CGRectMake(0, 0, CGRectGetWidth(window.frame), CGRectGetHeight(window.frame));
  _overlayView = [[TQOverlayBackgroundView alloc] initWithFrame:frame];
  _overlayView.relativeVerticalPosition = relativeVerticalPosition;
  _overlayView.translatesAutoresizingMaskIntoConstraints = NO;
  _overlayView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.7];
  contentView.translatesAutoresizingMaskIntoConstraints = NO;
  [_overlayView addSubview:contentView];

  UITapGestureRecognizer *overlayBackgroundTapRecognizer =
      [[UITapGestureRecognizer alloc] initWithTarget:self
                                              action:@selector(overlayViewDidTapBackground:)];
  overlayBackgroundTapRecognizer.delegate = self;
  [_overlayView addGestureRecognizer:overlayBackgroundTapRecognizer];

  if (animated) {
    _overlayView.alpha = 0;
    [UIView animateWithDuration:kAnimationDuration
                     animations:^{
                       _overlayView.alpha = 1;
                     }
                     completion:nil];
  }
  [window addSubview:_overlayView];
}


- (void)dismissAnimated:(BOOL)animated {
  void(^completion)(BOOL) = ^(BOOL finished) {
    [_overlayView removeFromSuperview];
    _overlayView = nil;
  };

  // prevent recognizing gestures during dismissal
  _overlayView.userInteractionEnabled = NO;

  if (animated) {
    [UIView animateWithDuration:kAnimationDuration
                     animations:^{
                       _overlayView.alpha = 0;
                     }
                     completion:completion];
  } else {
    completion(YES);
  }
}

- (void)overlayViewDidTapBackground:(UIGestureRecognizer *)gestureRecognizer {
  if (self.slidingMenu) {
    [TQOverlaySlidingMenu dismissSlidingMenuCompletion:nil];
  }
}


#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
       shouldReceiveTouch:(UITouch *)touch {
  return (touch.view == _overlayView);
}

@end












//~TA


