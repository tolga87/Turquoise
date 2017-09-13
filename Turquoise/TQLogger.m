#import "TQLogger.h"

typedef NS_ENUM(NSUInteger, TQLoggingLevel) {
  TQLoggingLevelOff   = 4,  // do not log anything
  TQLoggingLevelError = 3,  // log only errors
  TQLoggingLevelInfo  = 2,  // log info and error messages
  TQLoggingLevelDebug = 1,  // log everything (verbose)
};

@implementation TQLogger

static const TQLoggingLevel LoggingLevel = TQLoggingLevelOff;

void TQLog(NSUInteger level, NSString *string) {
  if (level >= LoggingLevel) {
    NSLog(@"%@", string);
  }
}

void TQLogDebug(NSString *formatString, ...) {
  va_list args;
  va_start(args, formatString);
  NSString *string = [[NSString alloc] initWithFormat:formatString arguments:args];
  TQLog(TQLoggingLevelDebug, string);
  va_end(args);
}

void TQLogInfo(NSString *formatString, ...) {
  va_list args;
  va_start(args, formatString);
  NSString *string = [[NSString alloc] initWithFormat:formatString arguments:args];
  TQLog(TQLoggingLevelInfo, string);
  va_end(args);
}

void TQLogError(NSString *formatString, ...) {
  va_list args;
  va_start(args, formatString);
  NSString *string = [[NSString alloc] initWithFormat:formatString arguments:args];
  TQLog(TQLoggingLevelError, string);
  va_end(args);
}

@end
