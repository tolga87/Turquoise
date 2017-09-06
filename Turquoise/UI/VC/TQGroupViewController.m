
#import "TQGroupViewController.h"

#import "TQArticleComposerViewController.h"
#import "TQArticleHeaderTableViewCell.h"
#import "TQArticleViewController.h"
#import "TQNNTPArticle.h"
#import "TQNNTPGroup.h"
#import "TQNNTPManager.h"
#import "TQOverlaySlidingMenu.h"

@interface TQGroupViewController ()

@property(nonatomic) TQNNTPGroup *group;
@property(nonatomic) NSArray<TQNNTPArticle *> *expandedArticleForest;
@property(nonatomic) TQNNTPArticle *selectedArticle;

@end

@implementation TQGroupViewController {
  IBOutlet UILabel *_groupNameLabel;

  TQNNTPManager *_nntpManager;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  _tableView.dataSource = self;
  _tableView.delegate = self;

  _nntpManager = [TQNNTPManager sharedInstance];
  _group = _nntpManager.currentGroup;
  _groupNameLabel.text = _group.groupId;
  _expandedArticleForest = [_group.articleForest expandedForest];

  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(groupDidUpdate:)
                                               name:kNNTPGroupDidUpdateNotification
                                             object:nil];
}

- (void)setGroup:(TQNNTPGroup *)group {
  _group = group;
  _expandedArticleForest = [_group.articleForest expandedForest];
}

- (IBAction)settingsButtonDidTap:(id)sender {
  NSArray *options = @[
    @"Manage newsgroup subscriptions",
    @"Settings",
    @"Release notes"
  ];
  NSArray *callbacks = @[
    ^{
      [self performSegueWithIdentifier:@"ManageSubscriptionsSegueId" sender:self];
    },
    ^{
      NSLog(@"Will show Settings");
    },
    ^{
      NSLog(@"Will show Release notes");
    },
  ];

  UIButton *settingsButton = sender;
  CGPoint position =
      [settingsButton convertPoint:settingsButton.frame.origin
                            toView:nil];
  position.y += CGRectGetHeight(settingsButton.frame);
  [TQOverlaySlidingMenu showSlidingMenuWithVerticalOffset:position.y
                                                    texts:options
                                                callbacks:callbacks];
}

- (void)groupDidUpdate:(NSNotification *)notification {
  NSString *groupId = notification.userInfo[kNNTPGroupDidUpdateNotificationGroupIdKey];
  if ([groupId isEqualToString:_group.groupId]) {
    NSLog(@"Group info updated!");

    self.group = _nntpManager.currentGroup;
    [self.tableView reloadData];
  }
}

//- (void)reloadData {
//  [_nntpManager refreshGroup];
//}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return _group.articleForest.numArticles;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  TQArticleHeaderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ArticleSubjectCell"
                                                                       forIndexPath:indexPath];
  TQNNTPArticle *article = _expandedArticleForest[indexPath.row];

  cell.articleTitleLabel.text = article.decodedSubject;
  cell.articleSenderLabel.text = article.decodedFrom;
  cell.articleLevel = article.depth;

  cell.contentView.backgroundColor = (indexPath.row % 2 == 0)
    ? [TQArticleHeaderTableViewCell evenColor]
    : [TQArticleHeaderTableViewCell oddColor];

  return cell;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([segue.identifier isEqualToString:@"ShowBodySegueID"]) {
    TQArticleViewController *articleViewController = segue.destinationViewController;
    articleViewController.newsGroup = _group;
    articleViewController.article = _selectedArticle;
  } else if ([segue.identifier isEqualToString:@"PostNewMessageSegueID"]) {
    TQArticleComposerViewController *articleComposerViewController = segue.destinationViewController;
    articleComposerViewController.newsGroup = _group;
  }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  _selectedArticle = _expandedArticleForest[indexPath.row];
  [_nntpManager requestBodyOfArticle:_selectedArticle completion:^(TQNNTPResponse *response, NSError *error) {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if ([response isOk]) {
      [self performSegueWithIdentifier:@"ShowBodySegueID" sender:self];
    } else {
      _selectedArticle = nil;
      // TODO: process error
    }
  }];
}

@end














//~TA

