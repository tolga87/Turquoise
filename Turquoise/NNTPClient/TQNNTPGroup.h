
#import <Foundation/Foundation.h>

#import "TQNNTPArticle.h"
#import "TQNNTPArticleForest.h"
#import "TQNNTPManager.h"
#import "TQNNTPResponse.h"

@interface TQNNTPGroup : NSObject

@property(nonatomic, readonly) NSString *groupId;
@property(nonatomic, readonly) NSInteger minArticleNo;
@property(nonatomic, readonly) NSInteger maxArticleNo;
@property(nonatomic, readonly) BOOL moderated;
@property(nonatomic, readonly) NSArray<TQNNTPArticle *> *articles;
@property(nonatomic, readonly) TQNNTPArticleForest *articleForest;

@property(nonatomic, readonly) BOOL headersDownloaded;

- (instancetype)initWithResponse:(TQNNTPResponse *)response;

- (instancetype)initWithGroupId:(NSString *)groupId
                   minArticleNo:(NSInteger)minArticleNo
                   maxArticleNo:(NSInteger)maxArticleNo
                      moderated:(BOOL)moderated;

- (void)downloadHeadersWithCompletion:(void (^)(void))completion;

@end
