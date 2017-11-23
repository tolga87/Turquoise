import Foundation
import UIKit

// TODO: convert this to WKWebView when possible
public class TQReleaseNotesView : UIView, UIWebViewDelegate {
  let releaseNotesAddress = "http://tolgaakin.com/Turquoise/release-notes.php"

  @IBOutlet var webView: UIWebView!
  @IBOutlet var activityIndicator: UIActivityIndicatorView!

  @IBAction func closeButtonDidTap(_ sender: Any?) {
    self.webView.delegate = nil  // this is assign, not weak. (sigh)
    TQOverlay.sharedInstance.dismiss(animated: true)
  }

  public class func loadFromNib() -> TQReleaseNotesView? {
    let view = UIView.tq_load(from: "TQReleaseNotesView", owner: self) as? TQReleaseNotesView
    if let view = view {
      view.webView.delegate = view
      view.webView.scalesPageToFit = true
      view.activityIndicator.hidesWhenStopped = true
      // make the spinner a little bigger
      view.activityIndicator.transform = CGAffineTransform.init(scaleX: 1.25, y: 1.25)
      view.loadWebView()
    }
    return view
  }

  func loadWebView() {
    let url = URL(string: self.releaseNotesAddress)!
    let request = URLRequest(url: url)
    self.webView.loadRequest(request)
    self.activityIndicator.startAnimating()
  }

  // MARK: - UIWebViewDelegate

  public func webView(_ webView: UIWebView,
                      shouldStartLoadWith request: URLRequest,
                      navigationType: UIWebViewNavigationType) -> Bool {
    guard let url = request.url else {
      return false
    }

    if url.absoluteString == self.releaseNotesAddress {
      return true
    } else {
      let application = UIApplication.shared
      if application.canOpenURL(url) {
        application.open(url, options: [:], completionHandler: nil)
      }
      return false
    }
  }

  public func webViewDidFinishLoad(_ webView: UIWebView) {
    self.activityIndicator.stopAnimating()
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
}
