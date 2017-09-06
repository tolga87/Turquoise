
#import "TQNNTPResponse.h"

@implementation TQNNTPResponse

+ (BOOL)isMultiLine:(NSInteger)statusCode {
  NSInteger firstDigit = statusCode / 100 % 10;
  NSInteger secondDigit = statusCode / 10 % 10;
//  NSInteger thirdDigit = statusCode % 10;

  if (statusCode == TQNNTPResponseCodeInformationFollows) {
    return YES;
  }
  return (firstDigit == TQNNTPResponseTypeOK && secondDigit == TQNNTPResponseCategoryArticleSelection);
}

- (instancetype)initWithString:(NSString *)string {
  if (string.length == 0) {
    return nil;
  }

  self = [super init];
  if (self) {
    NSScanner *scanner = [NSScanner scannerWithString:string];
    [scanner scanInteger:&_responseCode];

    NSMutableString *responseMessage = [NSMutableString string];
    NSString *line;

    while (YES) {
      BOOL charsRead = [scanner scanUpToString:@"\r\n" intoString:&line];
      if (charsRead) {
        [responseMessage appendFormat:@"%@\r\n", line];
      } else {
        break;
      }
    }

    _message = [responseMessage copy];
  }

  return self;
}

- (NSString *)description {
  return [NSString stringWithFormat:@"%ld %@", _responseCode, _message];
}

- (BOOL)isOk {
  return (_responseCode / 100 == TQNNTPResponseTypeOK);
}

- (BOOL)isOkSoFar {
  return (_responseCode / 100 == TQNNTPResponseTypeOKSoFar);
}

- (BOOL)isFailure {
  return (_responseCode / 100 == TQNNTPResponseTypeFailed);
}

- (NSString *)getArticleBody {
  if (_responseCode != 222) {
    return nil;
  }
  if (_message.length == 0) {
    return nil;
  }
  if (![_message hasSuffix:@"\r\n.\r\n"]) {
    return nil;
  }

  NSString *message = _message;
  NSRange rangeNewLine = [message rangeOfString:@"\r\n"];
  if (rangeNewLine.location == NSNotFound) {
    return nil;
  }

  NSUInteger messageFirstIndex = rangeNewLine.location + 2;
  NSUInteger messageLastIndex = message.length - 5;
  NSUInteger messageLength = messageLastIndex - messageFirstIndex;
  return [message substringWithRange:NSMakeRange(messageFirstIndex, messageLength)];
}

@end
