
#import "OpenInEditorRequest.h"

@implementation OpenInEditorRequest

@synthesize fileURL = _fileURL;
@synthesize line = _line;
@synthesize column = _column;
@synthesize otherParameters = _otherParameters;

- (id)initWithFileURL:(NSURL*)aFileURL line:(int)aLine column:(int)aColumn otherParameters:(NSDictionary*)anOtherParameters {
    self = [super init];
    if (self) {
        _fileURL = aFileURL;
        _line = aLine;
        _column = aColumn;
        _otherParameters = anOtherParameters;
    }
    return self;
}

- (NSString *)componentsJoinedByString:(NSString *)separator {
    NSMutableArray *array = [NSMutableArray arrayWithObject:self.fileURL.path];
    if (self.line != OpenInEditorRequestValueUnknown) {
        [array addObject:[NSString stringWithFormat:@"%d", self.line]];

        if (self.column != OpenInEditorRequestValueUnknown) {
            [array addObject:[NSString stringWithFormat:@"%d", self.column]];
        }
    }
    return [array componentsJoinedByString:separator];
}

- (NSString *)description {
    return [self componentsJoinedByString:@":"];
}

@end
