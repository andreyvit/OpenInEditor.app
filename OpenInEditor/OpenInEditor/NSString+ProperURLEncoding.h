
#import <Foundation/Foundation.h>

@interface NSString (ProperURLEncoding)

- (NSString *)stringByEscapingURLComponent;
- (NSString *)stringByUnescapingURLComponent;

- (void)enumerateURLQueryComponentsUsingBlock:(void (^)(NSString *key, NSString *value))block;
- (NSDictionary *)dictionaryByParsingURLQueryComponents;

@end
