
#import "TQArticleViewController.h"

#import "TQArticleComposerViewController.h"
#import "TQNNTPManager.h"
#import "TQUserInfoManager.h"

@implementation TQArticleViewController {
  TQNNTPManager *_nntpManager;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  _nntpManager = [TQNNTPManager sharedInstance];

  _articleSubjectLabel.text = _article.decodedSubject;
  _articleSenderLabel.text = _article.decodedFrom;
  _articleDateLabel.text = _article.date;
  _articleBodyTextView.text = _article.body;

  BOOL shouldShowDeleteButton = [self canDeleteMessage];
  [self setDeleteMessageButtonHidden:!shouldShowDeleteButton];
}

- (IBAction)dismiss:(id)sender {
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancelArticle:(id)sender {
  TQNNTPArticle *cancelArticle = [TQNNTPArticle cancelArticleFromArticle:_article];
  [_nntpManager postArticle:cancelArticle completion:^(TQNNTPResponse *response, NSError *error) {
    if ([response isOk]) {
      NSLog(@"Message canceled");
    } else {
      NSLog(@"Message could not be canceled: %@", error);
    }

    [self dismissViewControllerAnimated:YES completion:nil];
  }];
}

- (BOOL)canDeleteMessage {
  // TODO: make this method more robust
  TQUserInfoManager *userInfoManager = [TQUserInfoManager sharedInstance];
  NSString *userFullName = userInfoManager.fullName;
  NSString *userEmail = userInfoManager.email;

  return [_article.from containsString:userFullName] && [_article.from containsString:userEmail];
}

- (void)setDeleteMessageButtonHidden:(BOOL)hidden {
  _deleteButtonHeight.constant = (hidden ? 0 : 30);
  _deleteArticleButton.hidden = hidden;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  // Get the new view controller using [segue destinationViewController].
  // Pass the selected object to the new view controller.

  TQArticleComposerViewController *articleComposer = segue.destinationViewController;
  articleComposer.newsGroup = _newsGroup;
  articleComposer.parentArticle = _article;
}

@end
