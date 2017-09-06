
#import <Foundation/Foundation.h>

@interface NSString (TQEncoding)

- (NSString *)tq_decodedString;

- (NSString *)tq_newlineStrippedString;

- (NSString *)tq_whitespaceAndNewlineStrippedString;

- (BOOL)tq_isEmpty;

@end
