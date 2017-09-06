
#import "TQNNTPArticle.h"

#import "TQNNTPGroup.h"
#import "TQUserInfoManager.h"
#import "NSString+TQEncoding.h"

@implementation TQNNTPArticle {
  NSMutableDictionary *_headers;
  NSMutableArray<TQNNTPArticle *> *_childArticles;
}

+ (instancetype)cancelArticleFromArticle:(TQNNTPArticle *)article {
  if (!article) {
    return nil;
  }

  TQNNTPArticle *cancelArticle = [[TQNNTPArticle alloc] init];
  if (cancelArticle) {
    cancelArticle.from = article.from;
    cancelArticle.newsgroups = article.newsgroups;
    cancelArticle.cancelingMessageId = article.messageId;
    cancelArticle.subject = [NSString stringWithFormat:@"cancel %@", article.messageId];
    cancelArticle.body = @"This message was canceled.";
  }
  return cancelArticle;
}

- (instancetype)initWithResponse:(TQNNTPResponse *)response {
  if (![response isOk]) {
    return nil;
  }

  self = [super init];
  if (self) {
    _headers = [NSMutableDictionary dictionary];
    NSArray<NSString *> *lines = [response.message componentsSeparatedByString:@"\r\n"];

    NSInteger articleNo = -1;
    if (lines.count > 1) {
      NSScanner *scanner = [NSScanner scannerWithString:lines[0]];
      [scanner scanInteger:&articleNo];
    }

    for (NSUInteger i = 1; i < lines.count; i++) {
      NSString *line = lines[i];
      NSScanner *scanner = [NSScanner scannerWithString:line];

      NSString *headerName;
      NSString *headerValue;
      BOOL headerScanned = [scanner scanUpToCharactersFromSet:[NSCharacterSet whitespaceCharacterSet]
                                                   intoString:&headerName];
      if (headerScanned && headerName.length > 1) {
        if ([headerName characterAtIndex:(headerName.length - 1)] == ':') {
          headerName = [headerName substringToIndex:(headerName.length - 1)];
        }

        [scanner scanUpToString:@"\r\n" intoString:&headerValue];

        _headers[headerName] = headerValue;
      } else {
        break;
      }
    }

    _articleNo = articleNo;
    _messageId = _headers[@"Message-ID"];

    _from = _headers[@"From"];
    NSArray *fromComponents = [_from componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSMutableString *mutDecodedFrom = [NSMutableString string];
    for (NSString *fromComponent in fromComponents) {
      [mutDecodedFrom appendFormat:@"%@ ", [fromComponent tq_decodedString]];
    }
    [mutDecodedFrom deleteCharactersInRange:NSMakeRange(mutDecodedFrom.length - 1, 1)];
    _decodedFrom = [mutDecodedFrom copy];

    _subject = _headers[@"Subject"];
    _decodedSubject = [_subject tq_decodedString];

    _date = [_headers[@"Date"] copy];
    _newsgroups = [[_headers[@"Newsgroups"] tq_newlineStrippedString]
                   componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    _references = [self parseReferences:_headers[@"References"]];
    _childArticles = [NSMutableArray array];
  }

  return self;
}

- (instancetype)initWithSubject:(NSString *)subject
                        message:(NSString *)message
                      newsGroup:(TQNNTPGroup *)newsGroup
                  parentArticle:(TQNNTPArticle *)parentArticle {
  if ([subject tq_isEmpty] || [message tq_isEmpty]) {
    return nil;
  }
  if (!newsGroup) {
    return nil;
  }

  self = [super init];
  if (self) {
    _subject = [subject copy];
    _body = [message copy];
    _newsgroups = [NSArray arrayWithObject:newsGroup.groupId];
    // TODO: handle multiple newsgroups.
    _parentArticle = parentArticle;

    TQUserInfoManager *userInfoManager = [TQUserInfoManager sharedInstance];
    _from = [NSString stringWithFormat:@"%@ <%@>", userInfoManager.fullName, userInfoManager.email];
    // TODO: we should probaby escape some stuff here

    if (_parentArticle) {
      NSMutableArray *mutReferences = [NSMutableArray array];
      [mutReferences addObjectsFromArray:_parentArticle.references];
      [mutReferences addObject:_parentArticle.messageId];
      _references = [mutReferences copy];
    }
  }

  return self;
}

- (NSUInteger)depth {
  if (_references.count > 0 && !_parentArticle) {
    // article was posted as a reply to some deleted article. treat this as a root.
    return 0;
  } else {
    return _references.count;
  }
}

- (void)addChildArticle:(TQNNTPArticle *)childArticle {
  if (!childArticle) {
    return;
  }

  [_childArticles addObject:childArticle];
  [_childArticles sortUsingComparator:^NSComparisonResult(TQNNTPArticle *_Nonnull obj1, TQNNTPArticle *_Nonnull obj2) {
    return [@(obj1.articleNo) compare:@(obj2.articleNo)];
  }];
}

- (instancetype)initWithArticleNo:(NSInteger)articleNo headers:(NSDictionary *)headers {
  if (!headers) {
    return nil;
  }

  self = [super init];
  if (self) {
  }

  return self;
}

- (NSArray<NSString *> *)parseReferences:(NSString *)string {
  if (string.length == 0) {
    return nil;
  }

  return [string componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (NSString *)buildPostRequest {
  if (_messageId.length == 0) {
    // TODO: generate random message-ID here.
  }

  NSMutableString *mutRequest = [NSMutableString string];
  [mutRequest appendFormat:@"Message-ID: %@\r\n", _messageId];

  // TODO: get user's real name and email address.
  //  NSString *userEmail = @"nobody@example.net";
  [mutRequest appendFormat:@"From: %@\r\n", _from];

  // TODO: accept multiple newsgroups.
  NSString *newsGroupId = _newsgroups.lastObject;
  [mutRequest appendFormat:@"Newsgroups: %@\r\n", newsGroupId];

  if (_references.count > 0) {
    [mutRequest appendFormat:@"References: %@\r\n", [_references componentsJoinedByString:@" "]];
  }

  if (_cancelingMessageId) {
    [mutRequest appendFormat:@"Control: cancel %@\r\n", _cancelingMessageId];
  }

  [mutRequest appendFormat:@"Subject: %@\r\n", _subject];
  [mutRequest appendString:@"\r\n"];
  [mutRequest appendFormat:@"%@\r\n", _body];

  // TODO: sanitize text (lines that start with "." should be handled properly).
  [mutRequest appendFormat:@".\r\n"];
  return mutRequest;
}

- (NSString *)description {
  NSMutableString *desc = [NSMutableString string];
  [desc appendFormat:@"Article #%ld '%@'\n", _articleNo, _messageId];

  [desc appendFormat:@"Subject: '%@'\n", _subject];
  [desc appendFormat:@"parent: '%@'\n", _parentArticle.messageId];
  for (NSString *headerName in _headers) {
    id headerValue = _headers[headerName];
    [desc appendFormat:@"'%@': '%@'\n", headerName, headerValue];
  }

  [desc deleteCharactersInRange:NSMakeRange(desc.length - 1, 1)];
  return [desc copy];
}

@end
