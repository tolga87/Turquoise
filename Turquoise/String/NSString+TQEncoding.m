
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

  char *decodingBuffer = malloc(sizeof(unichar));
  int bufferIndex = 0;
  NSString *decodedSequence = nil;

  for (NSUInteger charIndex = 0; charIndex < string.length; charIndex++) {
    unichar curChar = [string characterAtIndex:charIndex];


    if (curChar == '_') {
      [mutString appendString:@" "];
    } else if (curChar == '?') {
      break;
    } else if (curChar != '=') {
      [mutString appendFormat:@"%c", curChar];
    } else {
      // curChar == '='

      if (charIndex + 2 >= string.length) {
        NSLog(@"Error: Parsing error");
        break;
      }

      NSString *encodedCharString = [string substringWithRange:NSMakeRange(charIndex + 1, 2)];
      scanner = [NSScanner scannerWithString:encodedCharString];

      unsigned int decodedChar;
      [scanner scanHexInt:&decodedChar];
      decodingBuffer[bufferIndex] = decodedChar;

      if (bufferIndex == 1) {
        // if this is the second byte we're reading, this should be a 2-byte character.
        // if we can't convert it to something readable, there's something wrong.
        NSData *data = [NSData dataWithBytes:decodingBuffer length:sizeof(unichar)];
        decodedSequence = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (decodedSequence.length == 0) {
          decodedSequence = @"?";
        }
        bufferIndex = 0;
        memset(decodingBuffer, 0, sizeof(unichar));
      } else if (bufferIndex == 0) {
        // if this is the first byte we're reading, this could be a 1-byte or a 2-byte character.
        // try to decode the single byte first. if it fails, it must be a 2-byte character.
        NSData *data = [NSData dataWithBytes:decodingBuffer length:sizeof(char)];
        decodedSequence = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (decodedSequence.length == 0) {
          bufferIndex = 1;
        } else {
          bufferIndex = 0;
          memset(decodingBuffer, 0, sizeof(unichar));
        }
      }

      if (decodedSequence.length > 0) {
        [mutString appendString:decodedSequence];
      }

      charIndex += 2;
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
