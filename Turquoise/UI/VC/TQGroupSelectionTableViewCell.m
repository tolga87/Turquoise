#import "TQGroupSelectionTableViewCell.h"

#import "TQUserInfoManager.h"

@class TQNNTPGroup;

@implementation TQGroupSelectionTableViewCell

+ (UIColor *)evenColor {
  return [UIColor colorWithRed:8. / 255.
                         green:20. / 255.
                          blue:50. / 255.
                         alpha:1];
}

+ (UIColor *)oddColor {
  return [UIColor colorWithRed:8. / 255.
                         green:20. / 255.
                          blue:0. / 255.
                         alpha:1];
}

- (void)awakeFromNib {
  [super awakeFromNib];

  [self updateSubscriptionStatus];

  // TODO: make this notification system smarter.
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(userSubscriptionsDidUpdate:)
                                               name:kUserSubscriptionsDidChangeNotification
                                             object:nil];
}

- (void)updateSubscriptionStatus {
  BOOL subscribed = NO;
  if (_group) {
    subscribed = [[TQUserInfoManager sharedInstance] isSubscribedToGroup:_group];
  }
  _statusIconView.image = subscribed ? [UIImage imageNamed:@"check1.png"]
                                     : nil;
}

- (void)userSubscriptionsDidUpdate:(NSNotification *)notification {
  [self updateSubscriptionStatus];
}

- (void)setGroup:(TQNNTPGroup *)group {
  _group = group;

  [self updateSubscriptionStatus];
  if (!_group) {
    _groupNameLabel.attributedText = nil;
    return;
  }

  NSInteger numArticles = ABS(_group.maxArticleNo - _group.minArticleNo) + 1;
  NSString *numArticlesString = [NSString stringWithFormat:@"(%ld)", numArticles];
  NSString *moderatedString = nil;
  if (_group.moderated) {
    moderatedString = @" [moderated]";
  }

  NSString *text = [NSString stringWithFormat:@"%@ %@%@",
                    _group.groupId,
                    numArticlesString,
                    (moderatedString ?: @"")];

  NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:text];
  [attributedText addAttribute:NSForegroundColorAttributeName
                         value:[UIColor colorWithRed:0 green:.5 blue:0 alpha:1]
                         range:[text rangeOfString:numArticlesString]];
  if (moderatedString) {
    [attributedText addAttribute:NSForegroundColorAttributeName
                           value:[UIColor redColor]
                           range:[text rangeOfString:moderatedString]];
  }

  _groupNameLabel.attributedText = attributedText;
}

@end
