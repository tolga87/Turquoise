
#import <Foundation/Foundation.h>

#import "TQNNTPArticle.h"
#import "TQNNTPGroup.h"
#import "TQNNTPResponse.h"

#define BLOCK_SAFE_RUN(block, ...) block ? block(__VA_ARGS__) : nil

@class TQNNTPGroup;

typedef void(^TQNNTPRequestCallback)(TQNNTPResponse *response, NSError *error);

extern NSString *const TQNNTPManagerErrorDomain;

static NSString *const kNNTPGroupListDidUpdateNotification = @"NNTPGroupListDidUpdate";
static NSString *const kNNTPGroupDidUpdateNotification = @"NNTPGroupDidUpdate";

@interface TQNNTPManager : NSObject

@property(nonatomic, readonly) BOOL connected;
@property(nonatomic, copy, readonly) NSArray<TQNNTPGroup *> *allGroups;
@property(nonatomic, readonly) TQNNTPGroup *currentGroup;

+ (instancetype)sharedInstance;

- (void)loginWithUserName:(NSString *)userName
                 password:(NSString *)password
               completion:(TQNNTPRequestCallback)loginCallback;

- (void)listGroupsCompletion:(TQNNTPRequestCallback)completion;

- (void)setGroup:(NSString *)groupId completion:(TQNNTPRequestCallback)completion;

- (void)requestBodyOfArticle:(TQNNTPArticle *)article completion:(TQNNTPRequestCallback)completion;

- (void)postArticle:(TQNNTPArticle *)article completion:(TQNNTPRequestCallback)completion;

- (void)sendRequest:(NSString *)requestString completion:(TQNNTPRequestCallback)completion;

@end
