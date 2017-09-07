
#import "TQNNTPManager.h"

#import "NSString+TQEncoding.h"

typedef void(^TQNNTPRequestCallback)(TQNNTPResponse *response, NSError *error);

NSString *const TQNNTPManagerErrorDomain = @"TQNNTPManagerErrorDomain";
NSString *const kNewsServerHostName = @"news.ceng.metu.edu.tr";
const NSInteger kNewsServerPort = 563;

static NSError *_genericError;

@implementation TQNNTPManager {
  NSURLSessionStreamTask *_streamTask;
  NSMutableData *_dataBuffer;

  NSMutableArray<TQNNTPGroup *> *_allGroups;
}

+ (instancetype)sharedInstance {
  static TQNNTPManager *theManager = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    theManager = [[self alloc] init];
  });

  return theManager;
}

static NSError *GetGenericError() {
  if (!_genericError) {
    _genericError = [NSError errorWithDomain:TQNNTPManagerErrorDomain
                                        code:-1003
                                    userInfo:@{ NSLocalizedDescriptionKey : @"Something went wrong" }];
  }
  return _genericError;
}

static NSError *GetError(NSString *errorMessage) {
  if (!errorMessage) {
    errorMessage = @"Something went wrong";
  }
  return [NSError errorWithDomain:TQNNTPManagerErrorDomain
                             code:0
                         userInfo:@{ NSLocalizedDescriptionKey : errorMessage }];
}

#pragma mark - Properties

- (NSArray<TQNNTPGroup *> *)allGroups {
  return [_allGroups copy];
}

#pragma mark -

- (void)loginWithUserName:(NSString *)userName
                 password:(NSString *)password
               completion:(TQNNTPRequestCallback)loginCallback {
  if (userName.length == 0) {
    NSError *error = [NSError errorWithDomain:TQNNTPManagerErrorDomain
                                         code:-1000
                                     userInfo:@{ NSLocalizedDescriptionKey : @"Invalid user name" }];
    BLOCK_SAFE_RUN(loginCallback, nil, error);
    return;
  } else if (password.length == 0) {
    NSError *error = [NSError errorWithDomain:TQNNTPManagerErrorDomain
                                         code:-1001
                                     userInfo:@{ NSLocalizedDescriptionKey : @"Invalid password" }];
    BLOCK_SAFE_RUN(loginCallback, nil, error);
    return;
  }

//  _streamTask = [[NSURLSession sharedSession] streamTaskWithHostName:kNewsServerHostName
//                                                                port:kNewsServerPort];


  // TODO: is this necessary?
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                          delegate:nil
                                                     delegateQueue:[NSOperationQueue mainQueue]];
  _streamTask = [session streamTaskWithHostName:kNewsServerHostName port:kNewsServerPort];


  [_streamTask startSecureConnection];

  void(^sendUserNameBlock)(NSString *, TQNNTPRequestCallback) = ^(NSString *userName, TQNNTPRequestCallback callback) {
    NSString *command = [NSString stringWithFormat:@"AUTHINFO USER %@\r\n", userName];

    [self sendRequest:command completion:^(TQNNTPResponse *response, NSError *error) {
      if (response.responseCode == TQNNTPResponseCodeEnterPassword) {
        BLOCK_SAFE_RUN(callback, response, nil);
      } else {
        BLOCK_SAFE_RUN(callback, nil, GetGenericError());
      }
    }];
  };

  void(^sendPasswordBlock)(NSString *, TQNNTPRequestCallback) = ^(NSString *password, TQNNTPRequestCallback callback) {
    NSString *command = [NSString stringWithFormat:@"AUTHINFO PASS %@\r\n", password];

    [self sendRequest:command completion:^(TQNNTPResponse *response, NSError *error) {
      BLOCK_SAFE_RUN(callback, response, error);
    }];
  };


  [_streamTask readDataOfMinLength:0
                         maxLength:4096
                           timeout:100
                 completionHandler:^(NSData * _Nullable data, BOOL atEOF, NSError * _Nullable error) {
                   TQNNTPResponse *response;
                   if (data) {
                     NSString *responseString = [[NSString alloc] initWithData:data
                                                                      encoding:NSUTF8StringEncoding];
//                     NSLog(@"S: %@", responseString);
                     response = [[TQNNTPResponse alloc] initWithString:responseString];
                   }

                   if (response.responseCode != TQNNTPResponseCodeServerReady) {
                     // something's wrong
                     NSError *error = [NSError errorWithDomain:TQNNTPManagerErrorDomain
                                                          code:-1002
                                                      userInfo:@{ NSLocalizedDescriptionKey : @"Server not ready" }];
                     BLOCK_SAFE_RUN(loginCallback, nil, error);
                     return;
                   }

                   sendUserNameBlock(userName, ^(TQNNTPResponse *response, NSError *error) {
                     if (!response) {
                       // sending user name failed.
                       BLOCK_SAFE_RUN(loginCallback, nil, GetGenericError());
                       return;
                     }

                     sendPasswordBlock(password, ^(TQNNTPResponse *response, NSError *error) {
                       if (!response) {
                         // sending password failed.
                         BLOCK_SAFE_RUN(loginCallback, nil, GetGenericError());
                         return;
                       }
                       
                       // login successful, download list of groups.

                       [self listGroupsCompletion:^(TQNNTPResponse *listResponse, NSError *listError) {
                         BLOCK_SAFE_RUN(loginCallback, response, error);
                       }];
                     });
                   });
                 }];

    [_streamTask resume];
}

- (void)listGroupsCompletion:(TQNNTPRequestCallback)completion {
  NSLog(@"Requesting list of all newsgroups...");

  [self sendRequest:@"LIST\r\n" completion:^(TQNNTPResponse *response, NSError *error) {
    if ([response isOk]) {
      _allGroups = [NSMutableArray arrayWithCapacity:250];
      NSArray<NSString *> *lines = [response.message componentsSeparatedByString:@"\r\n"];
      for (NSUInteger i = 1; i < lines.count; i++) {
        // skip the 0th line, it just contains information about the syntax.
        NSString *line = lines[i];
        NSArray<NSString *> *lineComps =
            [line componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

        if (lineComps.count >= 4) {
          NSString *groupId = lineComps[0];
          NSInteger articleNo1 = [lineComps[1] integerValue];
          NSInteger articleNo2 = [lineComps[2] integerValue];
          NSInteger minArticleNo = MIN(articleNo1, articleNo2);
          NSInteger maxArticleNo = MAX(articleNo1, articleNo2);
          BOOL moderated = ([[lineComps[3] lowercaseString] isEqualToString:@"m"]);
          TQNNTPGroup *group = [[TQNNTPGroup alloc] initWithGroupId:groupId
                                                       minArticleNo:minArticleNo
                                                       maxArticleNo:maxArticleNo
                                                          moderated:moderated];
          if (group) {
            [_allGroups addObject:group];
          }
        }
      }
    }

    [_allGroups sortUsingComparator:^NSComparisonResult(TQNNTPGroup *_Nonnull group1, TQNNTPGroup *_Nonnull group2) {
      return [group1.groupId localizedCaseInsensitiveCompare:group2.groupId];
    }];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNNTPGroupListDidUpdateNotification
                                                        object:nil];
    BLOCK_SAFE_RUN(completion, response, error);
  }];
}

- (void)setGroup:(NSString *)groupId completion:(TQNNTPRequestCallback)completion {
  if (groupId.length == 0) {
    BLOCK_SAFE_RUN(completion, nil, nil);  // TODO: error.
    return;
  }

  NSString *requestString = [NSString stringWithFormat:@"GROUP %@\r\n", groupId];
  [self sendRequest:requestString completion:^(TQNNTPResponse *response, NSError *error) {
    if ([response isOk]) {
      _currentGroup = [[TQNNTPGroup alloc] initWithResponse:response];
    }

    [_currentGroup downloadHeadersWithCompletion:^() {
      NSLog(@"All headers are downloaded");
      [[NSNotificationCenter defaultCenter] postNotificationName:kNNTPGroupDidUpdateNotification
                                                          object:self
                                                        userInfo:nil];
      BLOCK_SAFE_RUN(completion, response, error);
    }];
  }];
}

- (void)refreshGroup {
  [self setGroup:_currentGroup.groupId completion:nil];
}

- (void)requestBodyOfArticle:(TQNNTPArticle *)article completion:(TQNNTPRequestCallback)completion {
  if (article.messageId.length == 0) {
    BLOCK_SAFE_RUN(completion, nil, nil);  // TODO: error
    return;
  }

  NSString *requestString = [NSString stringWithFormat:@"BODY %@\r\n", article.messageId];
  [self sendRequest:requestString completion:^(TQNNTPResponse *response, NSError *error) {
    if ([response isOk]) {
      article.body = [response getArticleBody];
    }
    BLOCK_SAFE_RUN(completion, response, error);
  }];
}

- (void)postArticle:(TQNNTPArticle *)article completion:(TQNNTPRequestCallback)completion {
  if (!article) {
    BLOCK_SAFE_RUN(completion, nil, nil);  // TODO: error
    return;
  }

  NSString *requestString = @"POST\r\n";
  [self sendRequest:requestString completion:^(TQNNTPResponse *response, NSError *error) {
    if ([response isOkSoFar]) {
      NSString *messageId;
      if ([response.message.lowercaseString containsString:@"recommended message-id"]) {
        NSArray *messageComps =
          [response.message componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

        for (NSUInteger i = 0; i < messageComps.count - 1; i++) {
          if ([[messageComps[i] lowercaseString] isEqualToString:@"message-id"]) {
            messageId = [messageComps[i + 1] tq_newlineStrippedString];
            break;
          }
        }
      } else {
        // TODO: handle this case (generate a random message-ID).
      }

      article.messageId = messageId;
      NSString *postRequestString = [article buildPostRequest];
      [self sendRequest:postRequestString completion:^(TQNNTPResponse *response, NSError *error) {
        if ([response isOk]) {
          // success
          [self refreshGroup];
        } else {
          // failure
        }

        BLOCK_SAFE_RUN(completion, response, error);
      }];
    } else {
      BLOCK_SAFE_RUN(completion, response, GetError(@"Server does not accept message posting"));
    }
  }];
}

- (void)bufferDataWithPartNo:(NSInteger)partNo completion:(void (^)(NSData *data))completion {
  [_streamTask readDataOfMinLength:0
                         maxLength:10000
                           timeout:100
                 completionHandler:^(NSData * _Nullable data, BOOL atEOF, NSError * _Nullable error) {
                   if (!data) {
                     BLOCK_SAFE_RUN(completion, nil);
                     return;
                   }

                   BOOL isMultiLine = YES;

                   if (partNo == 0) {
                     _dataBuffer = [NSMutableData data];
                     NSInteger statusCode = 0;

                     if (data.length >= 3) {
                       // first 3 bytes must contain the status code.
                       NSData *responseCodeData = [data subdataWithRange:NSMakeRange(0, 3)];
                       NSString *responseCodeString = [[NSString alloc] initWithData:responseCodeData
                                                                            encoding:NSUTF8StringEncoding];
                       statusCode = [responseCodeString integerValue];
                       isMultiLine = [TQNNTPResponse isMultiLine:statusCode];
                     } else {
                       // TODO: we shouldn't receive fewer than 3 bytes in the first part.
                       //       if this happens, something's wrong. look into this.
                     }
                   } else {
                     NSLog(@"\t\t <<< received partial response: part %ld >>>", partNo);
                   }

                   if (!isMultiLine) {
                     BLOCK_SAFE_RUN(completion, data);
                     return;
                   }

                   // here, we know we are dealing with a multi-line response.
                   [_dataBuffer appendData:data];

                   BOOL isFinished = NO;
                   if (_dataBuffer.length >= 5) {
                     char terminatingBytes[5];
                     [_dataBuffer getBytes:terminatingBytes
                                     range:NSMakeRange(_dataBuffer.length - 5, 5)];
                     if (terminatingBytes[0] == '\r' &&
                         terminatingBytes[1] == '\n' &&
                         terminatingBytes[2] == '.' &&
                         terminatingBytes[3] == '\r' &&
                         terminatingBytes[4] == '\n') {
                       isFinished = YES;
                     }
                   }

                   if (isFinished) {
                     BLOCK_SAFE_RUN(completion, _dataBuffer);
                   } else {
                     [self bufferDataWithPartNo:(partNo + 1) completion:completion];
                   }
                 }];
}

- (void)sendRequest:(NSString *)requestString completion:(TQNNTPRequestCallback)completion {
  if (requestString.length == 0) {
    BLOCK_SAFE_RUN(completion, nil, nil);  // TODO: error.
    return;
  }

  NSData *requestData = [requestString dataUsingEncoding:NSUTF8StringEncoding];
  [_streamTask writeData:requestData timeout:100 completionHandler:^(NSError * _Nullable error) {
    if (error) {
      BLOCK_SAFE_RUN(completion, nil, nil);  // TODO: error.
      return;
    }

    [self bufferDataWithPartNo:0 completion:^(NSData *data) {
      if (!data) {
        BLOCK_SAFE_RUN(completion, nil, nil);  // TODO: error.
        return;
      }

      NSString *responseString = [[NSString alloc] initWithData:data
                                                       encoding:NSUTF8StringEncoding];
      TQNNTPResponse *response = [[TQNNTPResponse alloc] initWithString:responseString];

      const NSUInteger kMaxLengthToDisplay = 150;
      if (responseString.length > kMaxLengthToDisplay) {
        NSLog(@"S: %@ <TRUNCATED>", [responseString substringToIndex:kMaxLengthToDisplay]);
      } else {
        NSLog(@"S: %@", responseString);
      }

      BLOCK_SAFE_RUN(completion, response, nil);
    }];

//    [_streamTask readDataOfMinLength:0
//                           maxLength:10000
//                             timeout:100
//                   completionHandler:^(NSData * _Nullable data, BOOL atEOF, NSError * _Nullable error) {
//
//                     if (!data) {
//                       BLOCK_SAFE_RUN(completion, nil, nil);  // TODO: error.
//                       return;
//                     }
//
//                     NSString *responseString = [[NSString alloc] initWithData:data
//                                                                      encoding:NSUTF8StringEncoding];
//                     TQNNTPResponse *response = [[TQNNTPResponse alloc] initWithString:responseString];
//
//                     NSLog(@"S: %@", responseString);
//
//
////                     NSArray<NSString *> *responseLines = [responseString componentsSeparatedByString:@"\r\n"];
////                     NSUInteger lineCount = responseLines.count;
////
////
////                     if (lineCount == 2 && [responseLines[1] isEqualToString:@""]) {
////                       lineCount = 1;
////                     }
////
////                     if (lineCount > 1) {
////                       NSLog(@"%@ [%ld MORE LINE%@]", responseLines[0], lineCount - 1, (lineCount == 2 ? @"" : @"S"));
////                     } else {
////                       NSLog(@"%@", responseString);
////                     }
//
//                     BLOCK_SAFE_RUN(completion, response, nil);
//                   }];
  }];
}

@end








