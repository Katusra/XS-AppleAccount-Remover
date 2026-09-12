#import <Foundation/Foundation.h>
#import <Accounts/Accounts.h>

static NSString *XSLogPath(void)
{
    return @"/var/mobile/Media/XSAccountRemover/diagnostic.txt";
}

static void XSWriteLog(NSString *message)
{
    @try {
        NSString *path = XSLogPath();

        NSString *line =
            [NSString stringWithFormat:@"%@ %@\n",
             [NSDate date],
             message];

        NSFileManager *fm = [NSFileManager defaultManager];

        NSString *dir = [path stringByDeletingLastPathComponent];

        if (![fm fileExistsAtPath:dir]) {
            [fm createDirectoryAtPath:dir
          withIntermediateDirectories:YES
                           attributes:nil
                                error:nil];
        }

        if (![fm fileExistsAtPath:path]) {
            [line writeToFile:path
                   atomically:YES
                     encoding:NSUTF8StringEncoding
                        error:nil];
        } else {
            NSFileHandle *handle =
                [NSFileHandle fileHandleForWritingAtPath:path];

            [handle seekToEndOfFile];

            NSData *data =
                [line dataUsingEncoding:NSUTF8StringEncoding];

            [handle writeData:data];
            [handle closeFile];
        }
    }
    @catch (NSException *exception) {
        // 不让日志失败影响 Preferences
    }
}

static void XSRunDiagnostic(void)
{
    XSWriteLog(@"========== XSAccountRemover diagnostic ==========");
    XSWriteLog(@"Tweak code started.");

    NSBundle *bundle = [NSBundle mainBundle];

    XSWriteLog(
        [NSString stringWithFormat:@"Bundle: %@",
         bundle.bundleIdentifier ?: @"<nil>"]
    );

    XSWriteLog(
        [NSString stringWithFormat:@"Process: %@",
         [[NSProcessInfo processInfo] processName] ?: @"<nil>"]
    );

    XSWriteLog(@"Creating ACAccountStore...");

    ACAccountStore *store =
        [[ACAccountStore alloc] init];

    if (!store) {
        XSWriteLog(@"ERROR: ACAccountStore creation failed.");
        return;
    }

    XSWriteLog(@"ACAccountStore created.");

    ACAccountType *appleType =
        [store accountTypeWithAccountTypeIdentifier:
            @"com.apple.account.AppleAccount"];

    if (!appleType) {
        XSWriteLog(@"Apple Account type NOT found.");
        return;
    }

    XSWriteLog(@"Apple Account type found.");

    NSArray *accounts =
        [store accountsWithAccountType:appleType];

    XSWriteLog(
        [NSString stringWithFormat:
            @"Apple Account count: %lu",
            (unsigned long)accounts.count]
    );

    for (ACAccount *account in accounts) {

        XSWriteLog(
            [NSString stringWithFormat:
                @"Account username: %@",
                account.username ?: @"<nil>"]
        );

        XSWriteLog(
            [NSString stringWithFormat:
                @"Account identifier: %@",
                account.identifier ?: @"<nil>"]
        );
    }

    XSWriteLog(@"========== diagnostic finished ==========");
}

%ctor
{
    @autoreleasepool {

        dispatch_after(
            dispatch_time(DISPATCH_TIME_NOW,
                          (int64_t)(3.0 * NSEC_PER_SEC)),
            dispatch_get_main_queue(),
            ^{
                XSRunDiagnostic();
            }
        );
    }
}
