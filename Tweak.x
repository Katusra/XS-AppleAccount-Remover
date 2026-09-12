#import <Foundation/Foundation.h>
#import <Accounts/Accounts.h>
#import <stdarg.h>

static BOOL gHasRun = NO;

static void XSLog(NSString *format, ...)
{
    va_list args;
    va_start(args, format);

    NSString *message =
        [[NSString alloc] initWithFormat:format arguments:args];

    va_end(args);

    NSLog(@"[XSAccountRemover] %@", message);
}

static void XSRemoveAppleAccounts(void)
{
    if (gHasRun) {
        return;
    }

    gHasRun = YES;

    XSLog(@"Starting Apple Account removal test");

    ACAccountStore *store = [[ACAccountStore alloc] init];

    ACAccountType *appleType =
        [store accountTypeWithAccountTypeIdentifier:@"com.apple.account.AppleAccount"];

    if (!appleType) {
        XSLog(@"Apple Account type not found");
        return;
    }

    NSArray *accounts =
        [store accountsWithAccountType:appleType];

    XSLog(@"Found %lu Apple Account(s)",
          (unsigned long)accounts.count);

    if (accounts.count == 0) {
        XSLog(@"No Apple Account found");
        return;
    }

    for (ACAccount *account in accounts) {

        NSString *identifier = account.identifier;
        NSString *username = account.username;

        XSLog(@"Trying to remove account: %@ (%@)",
              username ?: @"<no username>",
              identifier ?: @"<no identifier>");

        [store removeAccount:account
        withCompletionHandler:^(BOOL success, NSError *error) {

            if (success) {

                XSLog(@"SUCCESS: account removed: %@",
                      username ?: @"<unknown>");

            } else {

                XSLog(@"FAILED: account was not removed");

                if (error) {
                    XSLog(@"Error domain=%@ code=%ld description=%@",
                          error.domain,
                          (long)error.code,
                          error.localizedDescription);
                }
            }
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
                XSRemoveAppleAccounts();
            }
        );
    }
}
