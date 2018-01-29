#import "SCUser.h"

@implementation SCUser

- (instancetype)initWithUsername:(NSString *)username andPassword:(NSString *)password
{
    if (self = [super init]) {
        self.userName = username;
        self.password = password;
    }
    return self;
}

@end
