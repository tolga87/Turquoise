
#import <Foundation/Foundation.h>

typedef enum : NSInteger {
  TQNNTPResponseCodeServerReady        = 200,
  TQNNTPResponseCodeInformationFollows = 215,
  TQNNTPResponseCodeEnterPassword      = 381,
  TQNNTPResponseCodeAuthSucceeded      = 281,
  TQNNTPResponseCodeNoArticle          = 423,
  TQNNTPResponseCodeAuthFailed         = 481,
  TQNNTPResponseCodeAlreadyAuth        = 502,
} TQNNTPResponseCode;

typedef enum : NSInteger {
  TQNNTPResponseTypeInformative = 1,
  TQNNTPResponseTypeOK          = 2,
  TQNNTPResponseTypeOKSoFar     = 3,
  TQNNTPResponseTypeFailed      = 4,
  TQNNTPResponseTypeUnavailable = 5,
} TQNNTPResponseType;

typedef enum : NSInteger {
  TQNNTPResponseCategoryArticleSelection = 2,
} TQNNTPResponseCategory;

//1xx - Informative message
//2xx - Command completed OK
//3xx - Command OK so far; send the rest of it
//4xx - Command was syntactically correct but failed for some reason
//5xx - Command unknown, unsupported, unavailable, or syntax error

@interface TQNNTPResponse : NSObject

@property(nonatomic, readonly) NSInteger responseCode;
@property(nonatomic, copy, readonly) NSString *message;

+ (BOOL)isMultiLine:(NSInteger)statusCode;

- (instancetype)initWithString:(NSString *)string;

- (BOOL)isOk;

- (BOOL)isOkSoFar;

- (BOOL)isFailure;

- (NSString *)getArticleBody;

@end
