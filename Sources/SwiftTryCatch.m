
#import "SwiftTryCatch.h"

@implementation SwiftTryCatch

+(void)try:(void (^)())try catch:(void (^)(NSException *))catch finally:(void (^)())finally{
    @try {
        try ? try() : nil;
    }
    
    @catch (NSException *exception) {
        catch ? catch(exception) : nil;
    }
    @finally {
        finally ? finally() : nil;
    }
}

+ (void)throwString:(NSString*)s
{
	@throw [NSException exceptionWithName:s reason:s userInfo:nil];
}

+ (void)throwException:(NSException*)e
{
	@throw e;
}

@end
