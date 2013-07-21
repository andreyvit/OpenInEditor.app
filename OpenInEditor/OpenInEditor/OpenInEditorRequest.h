
#import <Foundation/Foundation.h>


enum {
    OpenInEditorRequestValueUnknown = -1
};


@interface OpenInEditorRequest : NSObject

- (id)initWithFileURL:(NSURL*)fileURL line:(int)line column:(int)column otherParameters:(NSDictionary*)otherParameters;

@property(nonatomic, strong) NSURL *fileURL;
@property(nonatomic, assign) int line;
@property(nonatomic, assign) int column;
@property(nonatomic, strong) NSDictionary *otherParameters;

- (NSString *)componentsJoinedByString:(NSString *)separator;

@end
