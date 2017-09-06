
#import "TQNNTPArticleForest.h"

#import "NSString+TQEncoding.h"

@implementation TQNNTPArticleForest {
  NSMutableDictionary<NSString *, TQNNTPArticle *> *_messageIds;
  NSMutableArray<TQNNTPArticle *> *_rootArticles;
}

- (instancetype)initWithArticles:(NSArray<TQNNTPArticle *> *)articles {
  if (!articles) {
    return nil;
  }

  self = [super init];
  if (self) {
    _rootArticles = [NSMutableArray array];
    _messageIds = [NSMutableDictionary dictionary];

    for (TQNNTPArticle *article in articles) {
      if (article.messageId) {
        _messageIds[article.messageId] = article;
      }

      if (!article.parentArticle) {
        // the parent article may have been deleted. if so, try to find the next available ancestor.
        for (NSString *referenceMessageId in article.references.reverseObjectEnumerator) {
          TQNNTPArticle *ancestorArticle = _messageIds[referenceMessageId];
          if (ancestorArticle) {
            article.parentArticle = ancestorArticle;
            [ancestorArticle.childArticles addObject:article];
            // TODO: where exactly should we "insert" this new child into the ancestor's children?
            break;
          }
        }
      }
      if (!article.parentArticle) {
        [_rootArticles addObject:article];
      }
    }

    [_rootArticles sortUsingComparator:^NSComparisonResult(TQNNTPArticle *_Nonnull obj1, TQNNTPArticle *_Nonnull obj2) {
      return [@(obj2.articleNo) compare:@(obj1.articleNo)];
    }];
  }

  return self;
}

- (NSUInteger)numArticles {
  return _messageIds.allKeys.count;
}

- (NSArray *)trees {
  return _rootArticles;
}

- (NSArray<TQNNTPArticle *> *)expandedForest {
  NSMutableArray *forest = [NSMutableArray array];
  for (TQNNTPArticle *rootArticle in _rootArticles) {
    [forest addObjectsFromArray:[self expandedForestFromNode:rootArticle]];
  }

  return forest;
}

- (NSMutableArray<TQNNTPArticle *> *)expandedForestFromNode:(TQNNTPArticle *)startingNode {
  if (!startingNode) {
    return nil;
  }

  NSMutableArray *forest = [NSMutableArray arrayWithObject:startingNode];
  for (TQNNTPArticle *child in startingNode.childArticles) {
    [forest addObjectsFromArray:[self expandedForestFromNode:child]];
  }

  return forest;
}

#pragma mark - Debug

- (void)printForest {
  for (TQNNTPArticle *root in _rootArticles) {
    [self printTreeNode:root level:0];
  }
}

- (void)printTreeNode:(TQNNTPArticle *)article level:(NSInteger)level {
  NSMutableString *mutString = [NSMutableString string];
  if (level == 0) {
    [mutString appendString:@"*"];
  } else {
    for (NSInteger i = 0; i < level; i++) {
      [mutString appendString:@"-"];
    }
  }
  [mutString appendFormat:@"%@ (%ld)", [article.subject tq_decodedString] , article.articleNo];

  NSLog(@"%@", mutString);

  for (TQNNTPArticle *child in article.childArticles) {
    [self printTreeNode:child level:(level + 1)];
  }
}

@end
