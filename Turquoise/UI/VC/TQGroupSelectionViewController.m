#import "TQGroupSelectionViewController.h"

#import "TQGroupSelectionTableViewCell.h"
#import "TQNNTPManager.h"
#import "TQUserInfoManager.h"

@class TQSearchBar;

@implementation TQGroupSelectionViewController {
  IBOutlet UITableView *_tableView;
  IBOutlet TQSearchBar *_searchBar;

  TQNNTPManager *_nntpManager;
  NSArray<TQNNTPGroup *> *_filteredGroups;
}

- (IBAction)doneButtonDidTap:(id)sender {
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
  [super viewDidLoad];

  _searchBar.tq_textField.font = [UIFont fontWithName:@"dungeon" size:12];
  _searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;

  _nntpManager = [TQNNTPManager sharedInstance];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(newsGroupsDidUpdate:)
                                               name:kNNTPGroupListDidUpdateNotification
                                             object:nil];
}

- (void)newsGroupsDidUpdate:(NSNotification *)notification {
  [_tableView reloadData];
}

- (NSArray<TQNNTPGroup *> *)groups {
  return _filteredGroups ?: _nntpManager.allGroups;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [self groups].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  TQGroupSelectionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GroupCell"
                                                                       forIndexPath:indexPath];
  cell.group = [self groups][indexPath.row];
  cell.contentView.backgroundColor = (indexPath.row % 2 == 0)
      ? [TQGroupSelectionTableViewCell evenColor]
      : [TQGroupSelectionTableViewCell oddColor];
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  TQNNTPGroup *group = [self groups][indexPath.row];
  TQUserInfoManager *userInfoManager = [TQUserInfoManager sharedInstance];
  if ([userInfoManager isSubscribedToGroup:group]) {
    [userInfoManager unsubscribeFromGroup:group];
  } else {
    [userInfoManager subscribeToGroup:group];
  }

  [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
  if (searchText.length == 0) {
    _filteredGroups = nil;
  } else {
    NSPredicate *predicate =
        [NSPredicate predicateWithBlock:^BOOL(TQNNTPGroup *_Nullable evaluatedGroup, NSDictionary *_Nullable bindings) {
          return [evaluatedGroup.groupId localizedCaseInsensitiveContainsString:searchText];
        }];
    _filteredGroups = [_nntpManager.allGroups filteredArrayUsingPredicate:predicate];
  }

  [_tableView reloadData];
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
