#import "TQReleaseNotesView.h"

#import <WebKit/WebKit.h>

#import "UIView+NibLoader.h"
#import "TQOverlay.h"

static NSString *const kReleaseNotesAddress = @"http://tolgaakin.com/Turquoise/release-notes.php";

@interface TQReleaseNotesView ()<WKNavigationDelegate>
@end

@implementation TQReleaseNotesView {
  IBOutlet WKWebView *_webView;
  IBOutlet UIActivityIndicatorView *_activityIndicator;
}

- (IBAction)closeButtonDidTap:(id)sender {
  [[TQOverlay sharedInstance] dismissAnimated:YES];
}

- (instancetype)init {
  self = (TQReleaseNotesView *)[UIView tq_loadFromNib:@"TQReleaseNotesView" owner:self];
  if (self) {
    _webView.navigationDelegate = self;
    _activityIndicator.hidesWhenStopped = YES;
    // make the spinner a little bigger
    _activityIndicator.transform = CGAffineTransformMakeScale(1.25, 1.25);
    [self loadWebView];
  }
  return self;
}

- (void)loadWebView {
  NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:kReleaseNotesAddress]];
  [_webView loadRequest:request];
  [_activityIndicator startAnimating];
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView
    decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
                    decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
  NSURL *url = navigationAction.request.URL;
  if ([url.absoluteString isEqualToString:kReleaseNotesAddress]) {
    decisionHandler(WKNavigationActionPolicyAllow);
  } else {
    UIApplication *application = [UIApplication sharedApplication];
    if ([application canOpenURL:url]) {
      [application openURL:url options:@{} completionHandler:nil];
    }
    decisionHandler(WKNavigationActionPolicyCancel);
  }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
  [_activityIndicator stopAnimating];
}

@end
