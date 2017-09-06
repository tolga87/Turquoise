#import <Foundation/Foundation.h>

#import "TQNNTPGroup.h"

static NSString *const kUserSubscriptionsChangedNotification =
    @"kUserSubscriptionsChangedNotification";

@interface TQUserInfoManager : NSObject

@property(nonatomic, copy) NSString *userName;
@property(nonatomic, copy) NSString *password;
@property(nonatomic, copy) NSString *fullName;
@property(nonatomic, copy) NSString *email;
@property(nonatomic, readonly) NSArray<NSString *> *sortedSubscribedGroupIds;

+ (instancetype)sharedInstance;

- (void)resetUserCredentials;

- (BOOL)isSubscribedToGroup:(TQNNTPGroup *)group;
- (void)subscribeToGroup:(TQNNTPGroup *)group;
- (void)unsubscribeFromGroup:(TQNNTPGroup *)group;

@end
