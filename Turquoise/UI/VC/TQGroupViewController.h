#import <UIKit/UIKit.h>

@interface TQGroupViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property(nonatomic) IBOutlet UITableView *tableView;

//- (void)reloadData;

@end
