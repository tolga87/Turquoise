
#import <Foundation/Foundation.h>

#import "TQNNTPArticle.h"

@interface TQNNTPArticleForest : NSObject

@property(nonatomic, readonly) NSArray<TQNNTPArticle *> *trees;
@property(nonatomic, readonly) NSUInteger numArticles;

- (instancetype)initWithArticles:(NSArray<TQNNTPArticle *> *)articles;

- (NSArray<TQNNTPArticle *> *)expandedForest;

@end
