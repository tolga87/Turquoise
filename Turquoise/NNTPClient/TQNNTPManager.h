
#import <Foundation/Foundation.h>

#import "TQNNTPArticle.h"
#import "TQNNTPGroup.h"
#import "TQNNTPResponse.h"

#define BLOCK_SAFE_RUN(block, ...) block ? block(__VA_ARGS__) : nil

@class TQNNTPGroup;

typedef void(^TQNNTPRequestCallback)(TQNNTPResponse *response, NSError *error);

extern NSString *const TQNNTPManagerErrorDomain;

extern NSString *const kNetworkConnectionLostNotification;
extern NSString *const kNetworkStreamDidResetNotification;
extern NSString *const kNNTPGroupListDidUpdateNotification;
extern NSString *const kNNTPGroupDidUpdateNotification;

@interface TQNNTPManager : NSObject

@property(nonatomic, readonly) BOOL networkReachable;
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
