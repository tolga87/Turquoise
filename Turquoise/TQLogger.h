#import <Foundation/Foundation.h>

@interface TQLogger : NSObject

void TQLogDebug(NSString *formatString, ...) NS_FORMAT_FUNCTION(1, 2);

void TQLogInfo(NSString *formatString, ...) NS_FORMAT_FUNCTION(1, 2);

void TQLogError(NSString *formatString, ...) NS_FORMAT_FUNCTION(1, 2);

@end
