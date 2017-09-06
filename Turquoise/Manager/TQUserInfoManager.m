
#import "TQUserInfoManager.h"

#import "KeychainWrapper.h"

#define kUserNameKey ((NSString *)kSecAttrAccount)
#define kPasswordKey ((NSString *)kSecValueData)
#define kFullNameKey ((NSString *)kSecAttrLabel)
#define kEmailKey ((NSString *)kSecAttrService)

static NSString *const kGroupsKey = @"userInfo.groups";

@interface TQUserInfoManager ()

// this actually should be an NSSet, but NSUserDefaults can't store NSSets.
//@property(nonatomic, copy, readonly) NSMutableDictionary<NSString *, NSNumber *> *subscribedGroups;

@end

@implementation TQUserInfoManager {
  KeychainWrapper *_keychain;
  NSMutableDictionary<NSString *, NSNumber *> *_subscribedGroups;
}

+ (instancetype)sharedInstance {
  static TQUserInfoManager *theManager = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    theManager = [[self alloc] init];
    theManager->_keychain = [[KeychainWrapper alloc] init];

    theManager->_subscribedGroups =
        [[[NSUserDefaults standardUserDefaults] objectForKey:kGroupsKey] mutableCopy];
    if (!theManager->_subscribedGroups) {
      theManager->_subscribedGroups = [@{ @"metu.ceng.test" : @1 } mutableCopy];
      [[NSUserDefaults standardUserDefaults] setObject:theManager->_subscribedGroups
                                                forKey:kGroupsKey];
    }
  });

  return theManager;
}

#pragma mark - Properties

- (NSString *)userName {
  return [self userInfoValueForKey:kUserNameKey];
}

- (void)setUserName:(NSString *)userName {
  [self setUserInfoValue:userName forKey:kUserNameKey];
}

- (NSString *)password {
  return [self userInfoValueForKey:kPasswordKey];
}

- (void)setPassword:(NSString *)password {
  [self setUserInfoValue:password forKey:kPasswordKey];
}

- (NSString *)fullName {
  return [self userInfoValueForKey:kFullNameKey];
}

- (void)setFullName:(NSString *)fullName {
  [self setUserInfoValue:fullName forKey:kFullNameKey];
}

- (NSString *)email {
  return [self userInfoValueForKey:kEmailKey];
}

- (void)setEmail:(NSString *)email {
  [self setUserInfoValue:email forKey:kEmailKey];
}

- (NSArray<NSString *> *)sortedSubscribedGroupIds {
  return [_subscribedGroups.allKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

#pragma mark -

- (void)resetUserCredentials {
  [_keychain resetKeychainItem];
}

- (BOOL)isSubscribedToGroup:(TQNNTPGroup *)group {
  if (!group.groupId) {
    return NO;
  }
  return (_subscribedGroups[group.groupId] != nil);
}

- (void)subscribeToGroup:(TQNNTPGroup *)group {
  if (!group.groupId) {
    return;
  }

  _subscribedGroups[group.groupId] = @1;
  [[NSUserDefaults standardUserDefaults] setObject:_subscribedGroups forKey:kGroupsKey];
  [[NSNotificationCenter defaultCenter] postNotificationName:kUserSubscriptionsChangedNotification
                                                      object:self];
  NSLog(@"[INFO] Subscribed to group '%@'", group.groupId);
}

- (void)unsubscribeFromGroup:(TQNNTPGroup *)group {
  if (!group.groupId) {
    return;
  }

  [_subscribedGroups removeObjectForKey:group.groupId];
  [[NSUserDefaults standardUserDefaults] setObject:_subscribedGroups forKey:kGroupsKey];
  [[NSNotificationCenter defaultCenter] postNotificationName:kUserSubscriptionsChangedNotification
                                                      object:self];
  NSLog(@"[INFO] Unsubscribed from group '%@'", group.groupId);
}

- (id)userInfoValueForKey:(NSString *)key {
  NSAssert(key, @"Cannot get value, key is nil" );
  return [_keychain myObjectForKey:key];
}

- (void)setUserInfoValue:(id)value forKey:(NSString *)key {
  NSAssert(key, @"Cannot set value, key is nil" );
  NSAssert(value, @"Cannot set nil value in Keychain" );
  [_keychain mySetObject:value forKey:key];
}

@end
