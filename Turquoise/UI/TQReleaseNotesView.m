#import "TQReleaseNotesView.h"

@class TQOverlay;

static NSString *const kReleaseNotesAddress = @"http://tolgaakin.com/Turquoise/release-notes.php";

// TODO: convert this to WKWebView when possible
@interface TQReleaseNotesView ()<UIWebViewDelegate>
@end

@implementation TQReleaseNotesView {
  IBOutlet UIWebView *_webView;
  IBOutlet UIActivityIndicatorView *_activityIndicator;
}

- (IBAction)closeButtonDidTap:(id)sender {
  _webView.delegate = nil;  // this is assign, not weak. (sigh)
  [[TQOverlay sharedInstance] dismissWithAnimated:YES];
}

- (instancetype)init {
  self = (TQReleaseNotesView *)[UIView tq_loadFrom:@"TQReleaseNotesView" owner:self];
  if (self) {
    _webView.delegate = self;
    _webView.scalesPageToFit = YES;
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

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView
    shouldStartLoadWithRequest:(NSURLRequest *)request
                navigationType:(UIWebViewNavigationType)navigationType {
  NSURL *url = request.URL;
  if ([url.absoluteString isEqualToString:kReleaseNotesAddress]) {
    return YES;
  } else {
    UIApplication *application = [UIApplication sharedApplication];
    if ([application canOpenURL:url]) {
      [application openURL:url options:@{} completionHandler:nil];
    }
    return NO;
  }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
  [_activityIndicator stopAnimating];
}

//#pragma mark - WKNavigationDelegate
//
//- (void)webView:(WKWebView *)webView
//    decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
//                    decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
//  NSURL *url = navigationAction.request.URL;
//  if ([url.absoluteString isEqualToString:kReleaseNotesAddress]) {
//    decisionHandler(WKNavigationActionPolicyAllow);
//  } else {
//    UIApplication *application = [UIApplication sharedApplication];
//    if ([application canOpenURL:url]) {
//      [application openURL:url options:@{} completionHandler:nil];
//    }
//    decisionHandler(WKNavigationActionPolicyCancel);
//  }
//}
//
//- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
//  [_activityIndicator stopAnimating];
//}

@end
