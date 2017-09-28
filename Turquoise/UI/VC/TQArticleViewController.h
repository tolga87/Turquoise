
#import <UIKit/UIKit.h>

#import "TQNNTPArticle.h"
#import "TQNNTPGroup.h"

@interface TQArticleViewController : UIViewController

@property(nonatomic) TQNNTPArticle *article;
@property(nonatomic) TQNNTPGroup *newsGroup;

@property(nonatomic) IBOutlet TQLabel *articleSubjectLabel;
@property(nonatomic) IBOutlet TQLabel *articleSenderLabel;
@property(nonatomic) IBOutlet TQLabel *articleDateLabel;
@property(nonatomic) IBOutlet UITextView *articleBodyTextView;
@property(nonatomic) IBOutlet UIButton *deleteArticleButton;
@property(nonatomic) IBOutlet NSLayoutConstraint *deleteButtonHeight;

@end
