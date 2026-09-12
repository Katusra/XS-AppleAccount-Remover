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

        NSFileHandle *handle =
            [NSFileHandle fileHandleForWritingAtPath:path];

        if (!handle) {
            [line writeToFile:path
                   atomically:YES
                     encoding:NSUTF8StringEncoding
                        error:nil];
            return;
        }

        [handle seekToEndOfFile];

        NSData *data =
            [line dataUsingEncoding:NSUTF8StringEncoding];

        [handle writeData:data];
        [handle closeFile];
    }
    @catch (NSException *exception) {
    }
}

static void XSRunDiagnostic(void)
{
    XSWriteLog(@"========== XSAccountRemover TYPE DIAGNOSTIC ==========");
    XSWriteLog(@"Diagnostic code started.");

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
        XSWriteLog(@"ERROR: Apple Account type not found.");
        return;
    }

    XSWriteLog(@"Apple Account type found.");

    XSWriteLog(
        [NSString stringWithFormat:
            @"AccountType identifier: %@",
            appleType.identifier ?: @"<nil>"]
    );

    XSWriteLog(
        [NSString stringWithFormat:
            @"AccountType description: %@",
            appleType.description ?: @"<nil>"]
    );

    NSArray *accounts =
        [store accountsWithAccountType:appleType];

    XSWriteLog(
        [NSString stringWithFormat:
            @"Apple Account count: %lu",
            (unsigned long)accounts.count]
    );

    for (ACAccount *account in accounts) {

        XSWriteLog(@"----- ACCOUNT BEGIN -----");

        XSWriteLog(
            [NSString stringWithFormat:
                @"Username: %@",
                account.username ?: @"<nil>"]
        );

        XSWriteLog(
            [NSString stringWithFormat:
                @"Identifier: %@",
                account.identifier ?: @"<nil>"]
        );

        XSWriteLog(
            [NSString stringWithFormat:
                @"Account description: %@",
                account.accountDescription ?: @"<nil>"]
        );

        if (account.accountType) {

            XSWriteLog(
                [NSString stringWithFormat:
                    @"Actual accountType identifier: %@",
                    account.accountType.identifier ?: @"<nil>"]
            );

            XSWriteLog(
                [NSString stringWithFormat:
                    @"Actual accountType description: %@",
                    account.accountType.description ?: @"<nil>"]
            );
        } else {
            XSWriteLog(@"Actual accountType: <nil>");
        }

        XSWriteLog(@"----- ACCOUNT END -----");
    }

    XSWriteLog(@"========== TYPE DIAGNOSTIC FINISHED ==========");
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
            });
    }
}
