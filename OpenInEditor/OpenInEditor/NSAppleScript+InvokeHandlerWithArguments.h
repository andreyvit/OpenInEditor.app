
#import <Foundation/Foundation.h>

@interface NSAppleScript (InvokeHandlerWithArguments)

- (NSAppleEventDescriptor *)executeHandlerNamed:(NSString *)handleName withArguments:(NSArray *)arguments error:(NSDictionary **)errorInfo;

@end
