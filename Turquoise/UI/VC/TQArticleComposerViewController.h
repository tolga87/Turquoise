
#import <UIKit/UIKit.h>

#import "TQNNTPArticle.h"
#import "TQNNTPGroup.h"

@class TQArticleComposerViewController;

@interface TQArticleComposerViewController : UIViewController

@property(nonatomic) IBOutlet UITextField *articleSubjectField;
@property(nonatomic) IBOutlet UITextView *articleBodyView;

@property(nonatomic) TQNNTPGroup *newsGroup;
@property(nonatomic) TQNNTPArticle *parentArticle;

@end