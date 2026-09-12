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

static void XSRemoveAppleAccount(void)
{
    XSWriteLog(@"========== XSAccountRemover REMOVE TEST ==========");
    XSWriteLog(@"Remove code started.");

    ACAccountStore *store =
        [[ACAccountStore alloc] init];

    if (!store) {
        XSWriteLog(@"ERROR: ACAccountStore creation failed.");
        return;
    }

    ACAccountType *appleType =
        [store accountTypeWithAccountTypeIdentifier:
            @"com.apple.account.AppleAccount"];

    if (!appleType) {
        XSWriteLog(@"ERROR: Apple Account type not found.");
        return;
    }

    NSArray *accounts =
        [store accountsWithAccountType:appleType];

    XSWriteLog(
        [NSString stringWithFormat:
            @"Apple Account count: %lu",
            (unsigned long)accounts.count]
    );

    if (accounts.count == 0) {
        XSWriteLog(@"No Apple Account found.");
        return;
    }

    for (ACAccount *account in accounts) {

        NSString *username =
            account.username ?: @"<nil>";

        NSString *identifier =
            account.identifier ?: @"<nil>";

        XSWriteLog(
            [NSString stringWithFormat:
                @"TARGET username: %@",
                username]
        );

        XSWriteLog(
            [NSString stringWithFormat:
                @"TARGET identifier: %@",
                identifier]
        );

        XSWriteLog(@"Calling removeAccount...");

        [store removeAccount:account
        withCompletionHandler:^(BOOL success, NSError *error) {

            if (success) {

                XSWriteLog(
                    [NSString stringWithFormat:
                        @"SUCCESS: removed account %@",
                        username]
                );

            } else {

                XSWriteLog(@"FAILED: removeAccount returned NO.");

                if (error) {

                    XSWriteLog(
                        [NSString stringWithFormat:
                            @"Error domain: %@",
                            error.domain ?: @"<nil>"]
                    );

                    XSWriteLog(
                        [NSString stringWithFormat:
                            @"Error code: %ld",
                            (long)error.code]
                    );

                    XSWriteLog(
                        [NSString stringWithFormat:
                            @"Error description: %@",
                            error.localizedDescription ?: @"<nil>"]
                    );
                }
            }

            XSWriteLog(@"========== REMOVE TEST FINISHED ==========");
        }];
    }
}

%ctor
{
    @autoreleasepool {

        dispatch_after(
            dispatch_time(DISPATCH_TIME_NOW,
                          (int64_t)(3.0 * NSEC_PER_SEC)),
            dispatch_get_main_queue(),
            ^{
                XSRemoveAppleAccount();
            }
        );
    }
}
