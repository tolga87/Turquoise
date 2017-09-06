
#import <Foundation/Foundation.h>

#import "TQNNTPResponse.h"

@class TQNNTPGroup;

@interface TQNNTPArticle : NSObject

@property(nonatomic, readonly) NSInteger articleNo;
@property(nonatomic, copy) NSString *messageId;
@property(nonatomic, copy) NSString *cancelingMessageId;
@property(nonatomic, copy) NSString *from;
@property(nonatomic, copy, readonly) NSString *decodedFrom;
@property(nonatomic, copy) NSString *subject;
@property(nonatomic, copy, readonly) NSString *decodedSubject;
@property(nonatomic, copy) NSString *body;
@property(nonatomic, readonly) NSString *date;
@property(nonatomic) NSArray<NSString *> *newsgroups;
@property(nonatomic, readonly) NSArray<NSString *> *references;
@property(nonatomic, readonly) NSUInteger depth;

@property(nonatomic, weak) TQNNTPArticle *parentArticle;
@property(nonatomic, readonly) NSMutableArray<TQNNTPArticle *> *childArticles;

+ (instancetype)cancelArticleFromArticle:(TQNNTPArticle *)article;

- (instancetype)initWithArticleNo:(NSInteger)articleNo headers:(NSDictionary *)headers;

- (instancetype)initWithResponse:(TQNNTPResponse *)response;

//- (instancetype)initWithParentArticle:(TQNNTPArticle *)parentArticle
//                            newsGroup:(TQNNTPGroup *)newsGroup
//                              message:(NSString *)message;
- (instancetype)initWithSubject:(NSString *)subject
                        message:(NSString *)message
                      newsGroup:(TQNNTPGroup *)newsGroup
                  parentArticle:(TQNNTPArticle *)parentArticle;


- (void)addChildArticle:(TQNNTPArticle *)childArticle;

- (NSString *)buildPostRequest;

@end
