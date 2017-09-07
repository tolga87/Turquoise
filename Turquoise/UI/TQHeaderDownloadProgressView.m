#import "TQHeaderDownloadProgressView.h"

#import "TQNNTPGroup.h"

@implementation TQHeaderDownloadProgressView {
  NSString *_groupId;

  IBOutlet UIActivityIndicatorView *_progressIndicator;
  IBOutlet UILabel *_infoLabel;
  IBOutlet UILabel *_progressLabel;
}

- (instancetype)initWithGroupId:(NSString *)groupId {
  self = [self init];
  if (self) {
    _groupId = [groupId copy];
    _infoLabel.text = [NSString stringWithFormat:@"Downloading headers for group:\n'%@'...", _groupId];
    _progressLabel.text = @"0%";
    _progressIndicator.transform = CGAffineTransformMakeScale(1.5, 1.5);

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(progressDidUpdate:)
                                                 name:kHeaderDownloadProgressNotification
                                               object:nil];
  }
  return self;
}

- (instancetype)init {
  self = [[[NSBundle mainBundle] loadNibNamed:@"TQHeaderDownloadProgressView"
                                        owner:self
                                      options:nil] firstObject];
  return self;
}

- (void)progressDidUpdate:(NSNotification *)notification {
  NSNumber *progress = notification.userInfo[kHeaderDownloadProgressAmountKey];
  if (progress) {
    _progressLabel.text = [NSString stringWithFormat:@"%@%%", progress];
  }
}

@end
