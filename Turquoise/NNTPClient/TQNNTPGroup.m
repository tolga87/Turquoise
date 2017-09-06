
#import "TQNNTPGroup.h"

@implementation TQNNTPGroup {
  NSMutableArray *_articles;
  NSMutableDictionary *_articlesNos;
  NSMutableDictionary *_messageIds;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    _minArticleNo = -1;
    _maxArticleNo = -1;
  }
  return self;
}

- (instancetype)initWithResponse:(TQNNTPResponse *)response {
  if (!response) {
    return nil;
  }

  NSInteger minArticleNo;
  NSInteger maxArticleNo;
  NSScanner *scanner = [NSScanner scannerWithString:response.message];
  [scanner scanInteger:&minArticleNo];
  [scanner scanInteger:&minArticleNo];  // ignore the first id. it is the number of articles in the group
  [scanner scanInteger:&maxArticleNo];

  NSString *group;
  [scanner scanUpToString:@"\r\n" intoString:&group];

  self = [self initWithGroupId:group minArticleNo:minArticleNo maxArticleNo:maxArticleNo moderated:NO];
  // we don't know if this group is moderated at this point
  return self;
}

- (instancetype)initWithGroupId:(NSString *)groupId
                   minArticleNo:(NSInteger)minArticleNo
                   maxArticleNo:(NSInteger)maxArticleNo
                      moderated:(BOOL)moderated {
  if (groupId.length == 0) {
    return nil;
  }

  self = [super init];
  if (self) {
    _groupId = [groupId copy];
    _minArticleNo = minArticleNo;
    _maxArticleNo = maxArticleNo;
    _moderated = moderated;
    _articles = [NSMutableArray array];
    _articlesNos = [NSMutableDictionary dictionary];
    _messageIds = [NSMutableDictionary dictionary];
  }
  return self;
}


- (NSArray *)articles {
  return _articles;
}

- (NSString *)description {
  return [NSString stringWithFormat:@"Group '%@' Articles: %ld -> %ld", _groupId, _minArticleNo, _maxArticleNo];
}

- (void)downloadHeadersCurrentArticle:(NSInteger)articleNo completion:(void (^)(void))completion {
  NSLog(@"Requesting headers for article #%ld", articleNo);

  TQNNTPManager *theManager = [TQNNTPManager sharedInstance];
  NSString *headRequest = [NSString stringWithFormat:@"HEAD %ld\r\n", articleNo];
  [theManager sendRequest:headRequest completion:^(TQNNTPResponse *response, NSError *error) {
    if (![response isOk]) {
      // this article could be deleted. keep fetching others.
      NSLog(@"Could not get headers of article #%ld", articleNo);
    }

    TQNNTPArticle *article = [[TQNNTPArticle alloc] initWithResponse:response];
    if (article) {
      [_articles addObject:article];
      _articlesNos[@(article.articleNo)] = article;
      _messageIds[article.messageId] = article;
    }

    if (articleNo == _maxArticleNo) {
      BLOCK_SAFE_RUN(completion);
    } else {
      [self downloadHeadersCurrentArticle:(articleNo + 1) completion:completion];
    }
  }];
}

- (void)setupDependencies {
  for (TQNNTPArticle *article in _articles) {
    if (article.references.count > 0) {
      NSString *lastReferenceMessageId = [article.references lastObject];
      TQNNTPArticle *parentArticle = _messageIds[lastReferenceMessageId];
      article.parentArticle = parentArticle;
      [parentArticle addChildArticle:article];
    }
  }
}

- (void)downloadHeadersWithCompletion:(void (^)(void))completion {
  if (_minArticleNo < 0 || _maxArticleNo < 0) {
    BLOCK_SAFE_RUN(completion);
    return;
  }

  [self downloadHeadersCurrentArticle:_minArticleNo completion:^{
    // TODO: handle the case where this operation fails
    _headersDownloaded = YES;
    [self setupDependencies];
    _articleForest = [[TQNNTPArticleForest alloc] initWithArticles:_articles];
    BLOCK_SAFE_RUN(completion);
  }];
}

@end

























// TODO
