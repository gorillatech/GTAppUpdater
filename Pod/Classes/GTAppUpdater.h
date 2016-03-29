//
// GTAppUpdater.h
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

#import <Foundation/Foundation.h>

typedef enum {
    DefaultStrategy = 0,
    ForceStrategy,
    RemindStrategy
} UpdateStrategy;

@interface GTAppUpdater : NSObject

@property (nonatomic, strong) NSString *bundleIdentifier, *appStoreLocation, *appName, *route, *updatePageUrl;
@property (nonatomic, strong) NSString *alertTitle, *alertDefaultMessage, *alertForceMessage, *alertRemindMessage;
@property (nonatomic, assign) UpdateStrategy strategy;
@property (nonatomic, assign) NSUInteger daysUntilPrompt;
@property (nonatomic, strong) NSDate *remindDate;

+ (id)manager;

- (void)checkUpdate;
- (void)checkUpdateWithStrategy:(UpdateStrategy)strategy;
- (void)checkUpdateWithStore:(NSString *)store;
- (void)checkUpdateWithStrategy:(UpdateStrategy)strategy store:(NSString *)store;

@end