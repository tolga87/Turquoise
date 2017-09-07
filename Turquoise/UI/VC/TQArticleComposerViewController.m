
#import "TQArticleComposerViewController.h"

#import "NSString+TQEncoding.h"
#import "TQNNTPManager.h"

@implementation TQArticleComposerViewController {
  TQNNTPManager *_nntpManager;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  _nntpManager = [TQNNTPManager sharedInstance];

  UIColor *placeholderTextColor = [UIColor colorWithWhite:.6 alpha:1];
  _articleSubjectField.attributedPlaceholder =
      [[NSAttributedString alloc] initWithString:@"Subject:"
                                      attributes:@{ NSForegroundColorAttributeName : placeholderTextColor }];

  NSString *subject = @"";
  if (_parentArticle) {
    subject = _parentArticle.decodedSubject;
    if (![subject hasPrefix:@"Re: "]) {
      subject = [NSString stringWithFormat:@"Re: %@", subject];
    }
  }

  _articleSubjectField.text = subject;
}

- (void)dismissArticleComposer {
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)dismiss:(id)sender {
  [self dismissArticleComposer];
}

- (IBAction)postArticle:(id)sender {
  if ([_articleSubjectField.text tq_isEmpty]) {
    // TODO: alert
    NSLog(@"Cannot post message with empty subject");
    return;
  } else if ([_articleBodyView.text tq_isEmpty]) {
    // TODO: alert
    NSLog(@"Cannot post message with empty body");
    return;
  }

  NSString *subject = [_articleSubjectField.text tq_whitespaceAndNewlineStrippedString];
  NSString *message = [_articleBodyView.text tq_whitespaceAndNewlineStrippedString];
  TQNNTPArticle *article = [[TQNNTPArticle alloc] initWithSubject:subject
                                                          message:message
                                                        newsGroup:_newsGroup
                                                    parentArticle:_parentArticle];
    if (!article) {
      // something went wrong. cannot post article.
      // TODO: show error.
      NSLog(@"Not implemented yet!");
      return;
    }

  [_nntpManager postArticle:article completion:^(TQNNTPResponse *response, NSError *error) {
    if ([response isOk]) {
      NSLog(@"Article posted");
    } else {
      NSLog(@"Could not post article: %@", error);
    }

    [self dismissArticleComposer];
  }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
