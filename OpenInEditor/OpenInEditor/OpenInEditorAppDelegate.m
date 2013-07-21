
#import "OpenInEditorAppDelegate.h"
#import "OpenInEditorRequest.h"
#import "PlainUnixTask.h"
#import "NSString+ProperURLEncoding.h"

#define bailout(message, ...)  do { \
        NSLog(message, ## __VA_ARGS__); \
        return; \
    } while(0)

#define bailout_return(value, message, ...)  do { \
        NSLog(message, ## __VA_ARGS__); \
        return value; \
    } while(0)


@implementation OpenInEditorAppDelegate

- (void)awakeFromNib {
    [[NSAppleEventManager sharedAppleEventManager] setEventHandler:self andSelector:@selector(handleURLEvent:withReplyEvent:) forEventClass:kInternetEventClass andEventID:kAEGetURL];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
}

- (void)handleURLEvent:(NSAppleEventDescriptor*)event withReplyEvent:(NSAppleEventDescriptor*)replyEvent {
    NSString *urlString = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];
    if (!urlString)
        bailout(@"OpenInEditor: URL string is empty");

    NSURL *url = [NSURL URLWithString:urlString];
    if (!url)
        bailout(@"OpenInEditor: failed to parse URL string '%@'", urlString);

    if (![url.host isEqualToString:@"open"])
        bailout(@"OpenInEditor: failed to parse URL string '%@'", urlString);

    NSDictionary *parameters = [url.query dictionaryByParsingURLQueryComponents];
    NSString *fileURLString = parameters[@"url"];
    if (fileURLString.length == 0)
        bailout(@"OpenInEditor: missing or empty 'url' parameter in '%@'", urlString);

    NSURL *fileURL = [NSURL URLWithString:fileURLString];
    if (!fileURL)
        bailout(@"OpenInEditor: failed to parse the value of 'url' parameter as URL in '%@'", urlString);
    if (![fileURL isFileURL])
        bailout(@"OpenInEditor: 'url' is not a file:// scheme in '%@'", urlString);

    int line = OpenInEditorRequestValueUnknown;
    NSString *lineString = parameters[@"line"];
    if (lineString.length > 0) {
        line = [lineString intValue];
        if (line <= 0)
            line = OpenInEditorRequestValueUnknown;
    }

    int column = OpenInEditorRequestValueUnknown;
    NSString *columnString = parameters[@"column"];
    if (columnString.length > 0) {
        column = [columnString intValue];
        if (column <= 0)
            column = OpenInEditorRequestValueUnknown;
    }

    OpenInEditorRequest *request = [[OpenInEditorRequest alloc] initWithFileURL:fileURL line:line column:column otherParameters:parameters];

    // verify that the file exists, because otherwise we might be allowing sandboxed apps and web sites to pass arbitrary arguments to editor scripts and the like
    NSError *error;
    NSDictionary *values = [fileURL resourceValuesForKeys:@[NSURLIsReadableKey] error:&error];
    if (!values)
        bailout(@"OpenInEditor: file does not exist: '%@' (error: %@)", urlString, error.localizedDescription);
    if (![values[NSURLIsReadableKey] boolValue])
        bailout(@"OpenInEditor: file isn't readable: '%@'", urlString);

    NSString *scheme = url.scheme;
    BOOL success = [self openRequest:request inEditor:scheme];
    if (!success)
        NSLog(@"OpenInEditor: failed to open %@", request);
}

- (BOOL)openRequest:(OpenInEditorRequest *)request inEditor:(NSString *)scheme {
    if ([scheme isEqualToString:@"subl2"])
        return [self openInSublimeText2:request];
    else if ([scheme isEqualToString:@"subl3"])
        return [self openInSublimeText3:request];
    else if ([scheme isEqualToString:@"subl"])
        return [self openInSublimeText2:request] || [self openInSublimeText3:request];
    else
        bailout_return(NO, @"OpenInEditor: unknown URL scheme '%@'", scheme);
}

- (BOOL)openInSublimeText2:(OpenInEditorRequest *)request {
    NSURL *bundleURL = [[NSWorkspace sharedWorkspace] URLForApplicationWithBundleIdentifier:@"com.sublimetext.2"];
    if (!bundleURL)
        bailout_return(NO, @"Sublime Text 2 not found");

    NSURL *helperScriptURL = [bundleURL URLByAppendingPathComponent:@"Contents/SharedSupport/bin/subl"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:helperScriptURL.path])
        bailout_return(NO, @"Sublime Text 2 helper script does not exist at '%@'", helperScriptURL.path);

    NSLog(@"Found Sublime Text 2 at %@", bundleURL.path);

    NSString *location = [request componentsJoinedByString:@":"];

    LaunchUnixTaskAndCaptureOutput(helperScriptURL, @[@"--stay", location], LaunchUnixTaskAndCaptureOutputOptionsMergeStdoutAndStderr, ^(NSString *outputText, NSString *stderrText, NSError *error) {
        if (error) {
            NSLog(@"Failed to open %@ in Sublime Text 2 at %@, error is %@, bin/subl output: %@", request, bundleURL.path, error.localizedDescription, outputText);
        } else {
            if (outputText.length > 0) {
                NSLog(@"Succeeded to open %@ in Sublime Text 2 at %@, bin/subl output: %@", request, bundleURL.path, outputText);
            }
        }
    });
    return YES;
}

- (BOOL)openInSublimeText3:(OpenInEditorRequest *)request {
    NSURL *bundleURL = [[NSWorkspace sharedWorkspace] URLForApplicationWithBundleIdentifier:@"com.sublimetext.3"];
    if (!bundleURL)
        bailout_return(NO, @"Sublime Text 3 not found");

    NSURL *helperScriptURL = [bundleURL URLByAppendingPathComponent:@"Contents/SharedSupport/bin/subl"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:helperScriptURL.path])
        bailout_return(NO, @"Sublime Text 3 helper script does not exist at '%@'", helperScriptURL.path);

    NSLog(@"Found Sublime Text 3 at %@", bundleURL.path);

    NSString *location = [request componentsJoinedByString:@":"];

    LaunchUnixTaskAndCaptureOutput(helperScriptURL, @[@"--stay", location], LaunchUnixTaskAndCaptureOutputOptionsMergeStdoutAndStderr, ^(NSString *outputText, NSString *stderrText, NSError *error) {
        if (error) {
            NSLog(@"Failed to open %@ in Sublime Text 3 at %@, error is %@, bin/subl output: %@", request, bundleURL.path, error.localizedDescription, outputText);
        } else {
            if (outputText.length > 0) {
                NSLog(@"Succeeded to open %@ in Sublime Text 3 at %@, bin/subl output: %@", request, bundleURL.path, outputText);
            }
        }
    });
    return YES;
}

@end
