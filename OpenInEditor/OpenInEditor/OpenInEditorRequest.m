
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

- (int)computeLinearOffsetWithError:(NSError **)outError {
    NSError *error;
    NSString *content = [NSString stringWithContentsOfURL:self.fileURL usedEncoding:NULL error:&error];
    if (!content) {
        if (outError)
            *outError = error;
        return OpenInEditorRequestValueUnknown;
    }

    int line = self.line;
    int column = self.column;
    __block int curline = 0;
    __block int offset = -1;
    __block int lastOffset = -1;
    [content enumerateSubstringsInRange:NSMakeRange(0, content.length) options:NSStringEnumerationByLines|NSStringEnumerationSubstringNotRequired usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        ++curline;
        if (curline == line) {
            offset = (int)substringRange.location;
            if (column != OpenInEditorRequestValueUnknown) {
                offset += MIN(substringRange.length, (column - 1));
            }
            *stop = YES;
        }
        lastOffset = (int)substringRange.location;
    }];

    if (offset == -1) {
        if (lastOffset >= 0)
            offset = lastOffset;  // if the specified line does not exist (the number is too large), jump to the start of the last line
        else
            offset = 0;  // oops, no lines in the file at all
    }

    return offset;
}

@end
