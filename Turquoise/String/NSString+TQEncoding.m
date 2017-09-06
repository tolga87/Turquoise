
#import "NSString+TQEncoding.h"

@implementation NSString (TQEncoding)

- (NSString *)tq_decodedString {
  if (self.length < 4) {
    return self;
  }

  if (![self containsString:@"=?"]) {
    return self;
  }

  NSScanner *scanner = [NSScanner scannerWithString:self];
  NSCharacterSet *delimiterCharSet = [NSCharacterSet characterSetWithCharactersInString:@"=?_"];
  NSString *prefix;
  NSString *encoding;

  NSMutableString *mutString = [NSMutableString string];

  [scanner scanUpToString:@"=?" intoString:&prefix];
  if (prefix.length > 0) {
    // prefix will be nil if the string begins with "=?"
    [mutString appendString:prefix];
  }
  [scanner scanCharactersFromSet:delimiterCharSet intoString:nil];

  BOOL charSetRead = [scanner scanUpToString:@"?" intoString:nil];
  if (!charSetRead) {
    NSLog(@"Error: Invalid character set");
    return self;
  }
  [scanner scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"?"]
                      intoString:nil];

  BOOL encodingRead = [scanner scanUpToString:@"?" intoString:&encoding];
  if (!encodingRead) {
    NSLog(@"Error: Invalid encoding");
    return self;
  }
  [scanner scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"?"]
                      intoString:nil];

  NSUInteger charIndex = scanner.scanLocation;
  NSString *messageBody = [self substringFromIndex:charIndex];
  NSString *decodedMessage;
  if ([encoding.uppercaseString isEqualToString:@"Q"]) {
    decodedMessage = [self qDecodeString:messageBody];
  } else if ([encoding.uppercaseString isEqualToString:@"B"]) {
    decodedMessage = [self base64DecodeString:messageBody];
  } else {
    // this should not happen
    decodedMessage = messageBody;
  }

  [mutString appendString:decodedMessage];
  return [mutString copy];;
}

- (NSString *)qDecodeString:(NSString *)string {
  if (!string) {
    return nil;
  }

  NSScanner *scanner;
  NSMutableString *mutString = [NSMutableString string];

  for (NSUInteger charIndex = 0; charIndex < string.length; charIndex++) {
    unichar curChar = [string characterAtIndex:charIndex];

    if (curChar == '_') {
      [mutString appendString:@" "];
    } else if (curChar == '?') {
      break;
    } else if (curChar == '=') {
      if (charIndex + 5 >= string.length) {
        NSLog(@"Error: Parsing error");
        break;
      }

      NSString *encodedSequence = [string substringWithRange:NSMakeRange(charIndex + 1, 5)];
      char *buffer = malloc(sizeof(unichar));
      scanner = [NSScanner scannerWithString:encodedSequence];

      unsigned int firstChar, secondChar;
      [scanner scanHexInt:&firstChar];
      buffer[0] = firstChar;

      // skip the middle '='
      [scanner scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"="]
                          intoString:nil];
      [scanner scanHexInt:&secondChar];
      buffer[1] = secondChar;

      NSData *data = [NSData dataWithBytes:buffer length:sizeof(unichar)];
      NSString *decodedSequence = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

      [mutString appendString:decodedSequence];
      charIndex += 5;
    } else {
      [mutString appendFormat:@"%c", curChar];
    }
  }

  return [mutString copy];
}

- (NSString *)base64DecodeString:(NSString *)string {
  if (string.length < 2) {
    return string;
  }

  NSString *encodedString;
  if ([string hasSuffix:@"?="]) {
    encodedString = [string substringToIndex:string.length - 2];
  } else {
    encodedString = string;
  }

  NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:encodedString options:0];
  NSString *decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
  return decodedString;
}

- (NSString *)tq_newlineStrippedString {
  if ([self hasSuffix:@"\r\n"]) {
    return [self substringToIndex:self.length - 2];
  } else {
    return self;
  }
}

- (NSString *)tq_whitespaceAndNewlineStrippedString {
  return [self stringByTrimmingCharactersInSet:
          [NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (BOOL)tq_isEmpty {
  return [self tq_whitespaceAndNewlineStrippedString].length == 0;
}

@end
