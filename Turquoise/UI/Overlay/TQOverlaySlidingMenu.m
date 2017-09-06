#import "TQOverlaySlidingMenu.h"

@interface TQOverlaySlidingMenu() <UITableViewDataSource, UITableViewDelegate>
@end

@implementation TQOverlaySlidingMenu {
  TQOverlaySlidingMenuPosition _menuPosition;
  UIView *_scrollingView;
  NSArray<NSString *> *_texts;
  NSArray<TQSlidingMenuCallback> *_callbacks;
}

+ (void)showSlidingMenuWithPosition:(TQOverlaySlidingMenuPosition)position
                     verticalOffset:(CGFloat)verticalOffset
                              texts:(NSArray<NSString *> *)texts
                          callbacks:(NSArray<TQSlidingMenuCallback> *)callbacks {
  if (texts.count == 0 || callbacks.count == 0 || callbacks.count < texts.count) {
    return;
  }

  TQOverlaySlidingMenu *menu = [[TQOverlaySlidingMenu alloc] init];
  if (!menu) {
    return;
  }

  menu->_menuPosition = position;
  menu->_texts = [texts copy];
  menu->_callbacks = [callbacks copy];

  TQOverlay *overlay = [TQOverlay sharedInstance];
  [overlay showWithView:nil animated:NO];
  overlay.slidingMenu = menu;
  overlay.overlayView.manualLayout = YES;

  const CGFloat menuWidth = 180;
  CGFloat menuOriginX = [menu calculateOriginXWithPosition:menu->_menuPosition
                                                     width:menuWidth
                                                    hidden:YES];
  CGFloat menuOriginY = verticalOffset;

  CGFloat maxMenuHeight = CGRectGetMaxY(overlay.overlayView.bounds) - menuOriginY;
  const CGFloat kMenuCellHeight = 45;
  CGFloat menuHeight = kMenuCellHeight * menu->_texts.count;

  BOOL tableShouldScroll = NO;
  if (menuHeight > maxMenuHeight) {
    menuHeight = maxMenuHeight;
    tableShouldScroll = YES;
  }

  menu->_scrollingView = [[UIView alloc] initWithFrame:CGRectMake(menuOriginX,
                                                                  menuOriginY,
                                                                  menuWidth,
                                                                  menuHeight)];
  menu->_scrollingView.backgroundColor = [UIColor orangeColor];

  UITableView *tableView = [[UITableView alloc] initWithFrame:menu->_scrollingView.bounds];
  [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"SettingsSliderCell"];
  tableView.backgroundColor = [UIColor blackColor];
  tableView.separatorColor = [UIColor colorWithWhite:.2 alpha:1];
  tableView.separatorInset = UIEdgeInsetsZero;
  tableView.layoutMargins = UIEdgeInsetsZero;
  tableView.dataSource = menu;
  tableView.delegate = menu;
  tableView.scrollEnabled = tableShouldScroll;
  [menu->_scrollingView addSubview:tableView];

  [overlay.overlayView addSubview:menu->_scrollingView];
  [UIView animateWithDuration:[[overlay class] animationDuration]
                   animations:^{
                     CGRect newFrame = menu->_scrollingView.frame;
                     newFrame.origin.x = [menu calculateOriginXWithPosition:menu->_menuPosition
                                                                      width:menuWidth
                                                                     hidden:NO];
                     menu->_scrollingView.frame = newFrame;
                   }];
}

+ (void)dismissSlidingMenuCompletion:(void (^)(BOOL))completion {
  TQOverlay *overlay = [TQOverlay sharedInstance];
  TQOverlaySlidingMenu *slidingMenu = overlay.slidingMenu;
  if (!overlay || !slidingMenu) {
    return;
  }

  [UIView animateWithDuration:[[overlay class] animationDuration]
                   animations:^{
                     CGRect scrollingViewFrame = slidingMenu->_scrollingView.frame;
                     scrollingViewFrame.origin.x =
                         [slidingMenu calculateOriginXWithPosition:slidingMenu->_menuPosition
                                                             width:CGRectGetWidth(overlay.scrollingView.frame)
                                                            hidden:NO];
                     slidingMenu->_scrollingView.frame = scrollingViewFrame;
                   }
                   completion:^(BOOL finished) {
                     slidingMenu->_texts = nil;
                     slidingMenu->_callbacks = nil;
                     [slidingMenu->_scrollingView removeFromSuperview];
                     overlay.slidingMenu = nil;
                     [overlay dismissAnimated:NO];
                     if (completion) {
                       completion(finished);
                     }
                   }];
}

- (CGFloat)calculateOriginXWithPosition:(TQOverlaySlidingMenuPosition)position
                                  width:(CGFloat)width
                                 hidden:(BOOL)hidden {
  TQOverlay *overlay = [TQOverlay sharedInstance];
  CGRect overlayBounds = overlay.overlayView.bounds;

  switch (position) {
    case TQOverlaySlidingMenuPositionRight:
      return (hidden ? CGRectGetMaxX(overlayBounds) : CGRectGetMaxX(overlayBounds) - width);
    case TQOverlaySlidingMenuPositionLeft:
      return (hidden ? CGRectGetMinX(overlayBounds) - width :  CGRectGetMinX(overlayBounds));
  }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return _texts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsSliderCell"
                                                          forIndexPath:indexPath];

  cell.textLabel.numberOfLines = 2;
  cell.textLabel.backgroundColor = [UIColor clearColor];
  cell.textLabel.textColor = [UIColor whiteColor];
  cell.textLabel.font = [UIFont fontWithName:@"dungeon" size:12];
  cell.textLabel.text = _texts[indexPath.row];
  cell.contentView.backgroundColor = (indexPath.row % 2 == 0)
  ? [UIColor colorWithRed:0 green:0 blue:.5 alpha:1]
  : [UIColor colorWithRed:0 green:0 blue:1 alpha:1];
  return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:NO];
  TQSlidingMenuCallback callback = [_callbacks[indexPath.row] copy];
  [[self class] dismissSlidingMenuCompletion:^(BOOL finished) {
    callback();
  }];
}


@end





























//~TA

