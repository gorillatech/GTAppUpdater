//
// GTAppUpdater.m
//
// Copyright (c) 2016 Gorilla Technologies Srl (http://gorillatech.io)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


#ifndef GTAppUpdaterLocalizedStrings
#define GTAppUpdaterLocalizedStrings(key) NSLocalizedStringFromTableInBundle(key, @"GTAppUpdater", [NSBundle bundleWithURL:[[NSBundle bundleForClass:[self class]]URLForResource:@"GTAppUpdater" withExtension:@"bundle"]], nil)
#endif

#import "GTAppUpdater.h"

@implementation GTAppUpdater

NSString *lastVersion = nil;

+ (instancetype)manager {
    static GTAppUpdater *sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        sharedInstance = [[GTAppUpdater alloc] init];
    });
    return sharedInstance;
}

- (void)checkUpdate {
    [self checkUpdateWithStrategy:DefaultStrategy store:nil];
}

- (void)checkUpdateWithStore:(NSString *)store {
    [self checkUpdateWithStrategy:DefaultStrategy store:store];
}

- (void)checkUpdateWithStrategy:(UpdateStrategy)strategy{
    [self checkUpdateWithStrategy:strategy store:nil];
}

- (void)checkUpdateWithStrategy:(UpdateStrategy)strategy store:(NSString *)store{
    
    [self setAppName:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"]];
    [self setStrategy:strategy];
    [self setAppStoreLocation: store ? store : [[NSLocale currentLocale] objectForKey: NSLocaleCountryCode]];
    [self setDaysUntilPrompt:2];
    [self setBundleIdentifier:[[NSBundle mainBundle]objectForInfoDictionaryKey:@"CFBundleIdentifier"]];
    
    [self checkNewAppVersion:^(BOOL newVersion, NSString *version) {
        if (newVersion) {
            [self showAlert];
        } else {
            NSLog(@"Latest version");
        }
    }];
}


- (void)checkNewAppVersion:(void(^)(BOOL newVersion, NSString *version))completion {

    NSString *currentVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSURL *lookupURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/lookup?bundleId=%@&country=%@", self.bundleIdentifier, self.appStoreLocation]];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void) {
        
        NSData *lookupResults = [NSData dataWithContentsOfURL:lookupURL];
        if (!lookupResults) {
            completion(false, nil);
            return;
        }
        
        NSDictionary *jsonResults = [NSJSONSerialization JSONObjectWithData:lookupResults options:0 error:nil];

        dispatch_async(dispatch_get_main_queue(), ^(void) {
            NSUInteger resultCount = [jsonResults[@"resultCount"] integerValue];
            if (resultCount){
                NSDictionary *appDetails = [jsonResults[@"results"] firstObject];
                NSString *appItunesUrl = [appDetails[@"trackViewUrl"] stringByReplacingOccurrencesOfString:@"&uo=4" withString:@""];
                NSString *latestVersion = appDetails[@"version"];
                if ([latestVersion isEqualToString:[[NSUserDefaults standardUserDefaults]objectForKey:@"GTAppUpdater.skipVersion"]]) {
                    completion(false, nil);
                    return;
                }

                if ([latestVersion compare:currentVersion options:NSNumericSearch] == NSOrderedDescending) {
                    self.updatePageUrl = appItunesUrl;
                    lastVersion = latestVersion;
                    completion(true, latestVersion);
                } else {
                    completion(false, nil);
                }
            } else {
                completion(false, nil);
            }
        });
    });
}


- (NSDate *)remindDate {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"GTAppUpdater.remindDate"];
}

- (void)setRemindDate:(NSDate *)remindDate {
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"GTAppUpdater.remindDate"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)showAlert {
    
    NSString *alertTitle = self.alertTitle != nil ? self.alertTitle : GTAppUpdaterLocalizedStrings(@"alert.success.title");
    
    switch (self.strategy) {
        case DefaultStrategy:
        default: {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alertTitle
                                                                message:self.alertDefaultMessage != nil ? self.alertDefaultMessage : [NSString stringWithFormat:GTAppUpdaterLocalizedStrings(@"alert.success.default.text"), self.appName, lastVersion]
                                                               delegate:self
                                                      cancelButtonTitle:GTAppUpdaterLocalizedStrings(@"alert.button.skip")
                                                      otherButtonTitles:GTAppUpdaterLocalizedStrings(@"alert.button.update"), nil];
            [alertView show];
        }
            break;
            
        case ForceStrategy: {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alertTitle
                                                                message:self.alertForceMessage != nil ? self.alertForceMessage : [NSString stringWithFormat:GTAppUpdaterLocalizedStrings(@"alert.success.force.text"), self.appName, lastVersion]
                                                               delegate:self
                                                      cancelButtonTitle:GTAppUpdaterLocalizedStrings(@"alert.button.update")
                                                      otherButtonTitles:nil, nil];
            [alertView show];
        }
            break;
            
        case RemindStrategy: {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alertTitle
                                                                message:self.alertRemindMessage != nil ? self.alertRemindMessage : [NSString stringWithFormat:GTAppUpdaterLocalizedStrings(@"alert.success.remindme.text"), _appName, lastVersion]
                                                               delegate:self
                                                      cancelButtonTitle:GTAppUpdaterLocalizedStrings(@"alert.button.skip")
                                                      otherButtonTitles:GTAppUpdaterLocalizedStrings(@"alert.button.update"), GTAppUpdaterLocalizedStrings(@"alert.button.remindme"), nil];
            [alertView show];
        }
            break;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (self.strategy) {
        case DefaultStrategy:
        default: {
            if (buttonIndex == 0) {
                [[NSUserDefaults standardUserDefaults] setObject:lastVersion forKey:@"GTAppUpdater.skipVersion"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            } else {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.updatePageUrl]];
            }
        }
            
            break;
            
        case ForceStrategy:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.updatePageUrl]];
            break;
            
        case RemindStrategy: {
            if (buttonIndex == 0) {
                [[NSUserDefaults standardUserDefaults] setObject:lastVersion forKey:@"GTAppUpdater.skipVersion"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            } else if (buttonIndex == 1) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.updatePageUrl]];
            } else {
                [self setRemindDate:[NSDate date]];
            }
        }
            break;
    }
}

- (BOOL)checkConsecutiveDays
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDate *today = [NSDate date];
    
    NSDate *dateToRound = [[self remindDate] earlierDate:today];
    NSDateComponents * dateComponents = [gregorian components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit
                                                     fromDate:dateToRound];
    
    NSDate *roundedDate = [gregorian dateFromComponents:dateComponents];
    NSDate *otherDate = (dateToRound == [self remindDate]) ? today : [self remindDate] ;
    NSInteger diff = fabs([roundedDate timeIntervalSinceDate:otherDate]);
    NSInteger daysDifference = floor(diff/(24 * 60 * 60));
    
    return daysDifference >= _daysUntilPrompt;
}

@end
