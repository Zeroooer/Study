#import <Foundation/Foundation.h>

int globalVal = 1;
static int staticGlobalVal = 2;

int main(int argc, const char * argv[]) {
    static int staticVal = 3;
    int val = 4;
    __block int blockVal = 4;
    NSObject *obj = [NSObject new];
    __block NSObject *blockObj = [NSObject new];
    __weak void (^block)(void) = ^{
        globalVal++;
        staticGlobalVal++;
        staticVal++;
        blockVal++;
        val;
        obj;
        blockObj;
    };
    blockVal++;
}
