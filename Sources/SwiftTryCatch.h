
#import <Foundation/Foundation.h>
@import UIKit;

@interface SwiftTryCatch : NSObject

+ (void)try:(void(^)())try catch:(void(^)(NSException*exception))catch finally:(void(^)())finally;
+ (void)throwString:(NSString*)s;
+ (void)throwException:(NSException*)e;

@end
