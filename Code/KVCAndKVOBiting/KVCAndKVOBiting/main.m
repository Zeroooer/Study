//
//  main.m
//  KVCAndKVOBiting
//
//  Created by Hisen on 27/02/2018.
//  Copyright © 2018 Hisen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

#import "KVCObject.h"
#import "CustomObject.h"
#import "Observer.h"
#import "KVOObject.h"

int main(int argc, char * argv[]) {
    @autoreleasepool {
//        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
        
        /*
         * KVC Intro
         */
        
        // 1.设置值的方法 & 搜索模式
        /*
         * 1. 首先查找set<Key>:Value 或者_set<Key>:Value方法(key首字母大写)，找到即调用，未找到执行步骤2
         * 2. 检查+(BOOL)accessInstanceVariablesDirectly方法的返回值，返回YES执行步骤3，返回NO执行步骤4
         * 3. 按照_<key> -> _is<Key> -> <key> -> is<Key>的顺序去类中搜索相关的成员变量，找到即赋值，否则进入步骤4
         * 4. 调用setValue:forUndefinedKey:方法,在这个方法里抛出异常，可以覆写自定义错误处理
         */
        KVCObject *kvcObj = [KVCObject new];
        // 设置基本类型属性
        [kvcObj setValue:@100 forKey:@"scalarProp"];
        // 设置结构体类型属性
        [kvcObj setValue:[NSValue valueWithCGRect:CGRectMake(0, 0, 100, 100)] forKey:@"structProp"];
        // 设置只读属性
        [kvcObj setValue:@"readOnlyProp" forKey:@"readonlyProp"];
        // 设置私有属性
        [kvcObj setValue:@"privateProp" forKey:@"privateProp"];
        // 设置普通属性
        [kvcObj setValue:@"strProp" forKey:@"strProp"];
        // 通过keyPath设值
        CustomObject *customObj = [CustomObject new];
        [kvcObj setValue:customObj forKey:@"customObjProp"];
        [kvcObj setValue:@"customObjProp.name" forKeyPath:@"customObjProp.name"];
        NSLog(@"%@", kvcObj);
        
        // 2.获取值的方法 & 搜索模式
        /*
         * 1.按照get<Key> -> <key> -> is<Key> -> _<key>的顺序查找getter方法，找到即调用，进入步骤2，否则进入步骤3
         * 2.如果取到的值是一个对象指针，则直接返回，如果取到的值是BOOL或者Int等基本类型，则包装成一个NSNumber对象返回，如果取到的值是不支持NSNumber的基本类型(比如CGRect)，则包装成NSValue返回
         * 3.NSArray Check: 查找countOf<Key>,objectIn<Key>AtIndex:,<key>AtIndexs:格式的方法，如果找到第一个和后两个的其中一个即返回一个NSKeyValueArray(NSArray的子类，可以响应NSArray的所有方法的代理集合)，否则进入步骤4
         * 4.NSSet Check: 查找countOf<Key>,enumeratorOf<Key>,memberOf<Key>格式的方法，如果三个方法都找到，则返回一个可以响应NSSet所有方法的代理集合，否则进入步骤5
         * 5.检查+(BOOL)accessInstanceVariablesDirectly方法的返回值，返回YES执行步骤6，返回NO执行步骤7
         * 6.按照_<key> -> _is<Key> -> <key> -> is<Key>的顺序搜索成员变量名
         * 7.valueForUndefinedKey:
         */
        // 取基本类型属性，自动包装为NSNumber对象返回
        NSLog(@"%@, class: %@", [kvcObj valueForKey:@"scalarProp"], NSStringFromClass([[kvcObj valueForKey:@"scalarProp"] class]));
        // 取结构提类型属性，自动包装为NSValue对象返回
        NSLog(@"%@, class: %@", [kvcObj valueForKey:@"structProp"], NSStringFromClass([[kvcObj valueForKey:@"structProp"] class]));
        // 通过keyPath取值
        NSLog(@"%@", [kvcObj valueForKeyPath:@"customObjProp.name"]);
        
        // 3.不可变集合 & 操作符
        NSMutableArray *customObjs = [NSMutableArray new];
        for (int i = 0; i < 10; i++) {
            CustomObject *customObj = [[CustomObject alloc] initWithName:[NSString stringWithFormat:@"customObj-%d", i] andAmount: i / 2 == 0 ? 10 : 20];
            [customObjs addObject:customObj];
        }
        
        kvcObj.arrProp = [customObjs copy];
        for (CustomObject *customObj in [kvcObj valueForKey:@"arrProp"]) {
            NSLog(@"customObj.name: %@, customObj.amount: %ld", customObj.name, (long)customObj.amount);
        }
        
        // 循环遍历它的内容并向每个对象发送消息
        NSLog(@"All customObj name: %@", [kvcObj valueForKeyPath:@"arrProp.name"]);
        NSLog(@"All customObj amount: %@", [kvcObj valueForKeyPath:@"arrProp.amount"]);
        
        // 简单集合操作符
        NSLog(@"count: %@", [kvcObj valueForKeyPath:@"arrProp.@count.amount"]);
        NSLog(@"min: %@", [kvcObj valueForKeyPath:@"arrProp.@min.amount"]);
        NSLog(@"max: %@", [kvcObj valueForKeyPath:@"arrProp.@max.amount"]);
        NSLog(@"sum: %@", [kvcObj valueForKeyPath:@"arrProp.@sum.amount"]);
        NSLog(@"avg: %@", [kvcObj valueForKeyPath:@"arrProp.@avg.amount"]);
        
        // 对象操作符
        NSLog(@"unionOfObjects: %@", [kvcObj valueForKeyPath:@"arrProp.@unionOfObjects.name"]);
        NSLog(@"distinctUnionOfObjects: %@", [kvcObj valueForKeyPath:@"arrProp.@distinctUnionOfObjects.amount"]);

        // 嵌套数组操作符
        NSLog(@"unionOfArrays: %@", [@[[kvcObj valueForKey:@"arrProp"], [kvcObj valueForKey:@"arrProp"]] valueForKeyPath:@"@unionOfArrays.name"]);
        NSLog(@"distinctUnionOfArrays: %@", [@[[kvcObj valueForKey:@"arrProp"], [kvcObj valueForKey:@"arrProp"]] valueForKeyPath:@"@distinctUnionOfArrays.amount"]);
        
        // 4. 可变集合 NSMutableArray & NSSet & NSOrderedSet
        
        // 5. KVC批处理
        NSArray *kvcKeys = @[@"scalarProp", @"structProp", @"strProp", @"customObjProp", @"arrProp", @"readonlyProp"];
        // 传入一组key，封装成NSDictionary返回
        NSDictionary *kvcValues = [kvcObj dictionaryWithValuesForKeys:kvcKeys];
        NSLog(@"kvcValues: %@", kvcValues);
        
        NSDictionary *newKVCValues = @{
                                       @"scalarProp": @200
                                       };
        // 传入一个字典，批量修改key对应的value值
        [kvcObj setValuesForKeysWithDictionary:newKVCValues];
        NSLog(@"kvcValues: %@", kvcObj);
        
        // 6. 异常处理 - 错误的key & 错误的值
        // 默认会抛异常，给非对象类型设置非法的nil值，重写setNilValueForKey:处理
        [kvcObj setValue:nil forKey:@"scalarProp"];
        // 给不存在的key设值，重写setValue:forUndefinedKey:处理
        [kvcObj setValue:@"keyNotFound" forKey:@"keyNotFound"];
        // 通过不存在的key取值，重写valueForUndefinedKey:处理
        NSString *keyNotFound = [kvcObj valueForKey:@"keyNotFound"];
        NSLog(@"%@", keyNotFound);
        
        // 7. KVV - 键值验证
        // 添加- (BOOL)validate<Key>:error:方法
        NSError *error;
        id illegalValue = @"illegal";
        id legalValue = @"legal";
        /*
         * 去类中寻找方法validate<Key>:error:,找到即调用，否则默认返回YES
         * KVV 需要显式的调用validateValue:forKey:error:,不会自动验证
         */
        BOOL ifIllegal = [kvcObj validateValue:&illegalValue forKey:@"strProp" error: &error];
        if (ifIllegal) {
            NSLog(@"键值匹配");
        } else {
            NSLog(@"键值不匹配");
        }
        ifIllegal = [kvcObj validateValue:&legalValue forKey:@"strProp" error: &error];
        if (ifIllegal) {
            NSLog(@"键值匹配");
        } else {
            NSLog(@"键值不匹配");
        }
        
//        id xxx = [@[@"aaa", @"aaa", @"ccc"] valueForKeyPath:@"@distinctUnionOfObjects.self"];
//        NSLog(@"%@", xxx);
//
//        id yyy = [@[@[@"aaa", @"aaa", @"ccc"], @[@"aaa", @"ccc"]] valueForKeyPath:@"@unionOfObjects.self"];
//        NSLog(@"%@", yyy);
        
//        NSMutableSet *set = [[NSMutableSet alloc] initWithObjects:@1, @2, @3, @4, @5, nil];
//        [set unionSet: [NSSet setWithObjects:@5, @6, nil]]; // 合并set
//        NSLog(@"%@", set);
//        [set minusSet: [NSSet setWithObjects:@1, @2, nil]]; // 把传入的set中的元素从set中删除
//        NSLog(@"%@", set);
//        [set intersectSet: [NSSet setWithObjects:@3, @6, @1, nil]];
//        NSLog(@"%@", set);
        

        
        /*
         * KVO Intro
         */
        
        Observer *observer = [Observer new];
        KVOObject *kvoObj = [KVOObject new];
        
        // 1.添加观察者
        /*
         * 添加观察者的时候,观察者与被观察者都不会被持有
         * NSKeyValueObservingOptionOld     - 在通知的change字典中提供旧值
         * NSKeyValueObservingOptionNew     - 在通知的change字典中提供新值
         * NSKeyValueObservingOptionInitial - 添加观察者的时候立即发送通知给观察者，在注册观察者方法返回之前
         * NSKeyValueObservingOptionPrior   - 在属性更改之前和之后各发送一个通知给观察者，属性更改前发送的通知的change字典中会有一个NSKeyValueChangeNotificationIsPriorKey标识是只更改前的通知
         */
        [kvoObj addObserver:observer
                 forKeyPath:@"strProp"
                    options: NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld | NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionPrior
                    context:nil];
        kvoObj.strProp = @"oldValue";
        kvoObj.strProp = @"newValue";
        [kvoObj removeObserver:observer forKeyPath:@"strProp" context:nil];
        
        // 多次添加观察者
        /*
         * 同个对象的同个属性多次注册同个观察者，会收到多次通知
         * willChangeValueForKey: 是先注册先通知
         * didChangeValueForKey:  是后注册先通知
         */
        [kvoObj addObserver:observer
                 forKeyPath:@"intProp"
                    options: NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld | NSKeyValueObservingOptionPrior
                    context:nil];
        [kvoObj addObserver:observer
                 forKeyPath:@"intProp"
                    options: NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld | NSKeyValueObservingOptionPrior
                    context:"context1"];
        [kvoObj addObserver:observer
                 forKeyPath:@"intProp"
                    options: NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld | NSKeyValueObservingOptionPrior
                    context:"context2"];
        kvoObj.intProp = 100;
        [kvoObj removeObserver:observer forKeyPath:@"intProp" context:nil];
        [kvoObj removeObserver:observer forKeyPath:@"intProp" context:"context1"];
        [kvoObj removeObserver:observer forKeyPath:@"intProp" context:"context2"];

        
        // 手动KVO
        /*
         * 重写+automaticallyNotifiesObserversForKey:,根据key关闭属性的自动通知发送
         * 手动实现该属性setter方法，手动发送通知
         */
        [kvoObj addObserver:observer
                 forKeyPath:@"manualKVOProp"
                    options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                    context:nil];
        // 在手动重写的setter方法中，添加了属性值改变才发送通知的逻辑，因此这里只会发出一次通知
        kvoObj.manualKVOProp = @"newValue";
        kvoObj.manualKVOProp = @"newValue";
        [kvoObj removeObserver:observer forKeyPath:@"manualKVOProp" context:nil];

        
        
        // 计算属性(注册依赖)
        /*
         * KVO 提供了两种表示属性依赖的机制
         * 1. + (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key
         * 2. + (NSSet *)keyPathsForValuesAffecting<Key>:(NSString *)key
         * 两个方法都是返回key关联的属性的key名组成的set，当这些属性被修改时，注册了key的观察者也能收到通知
         * 使用第二种的依赖关系会更加清晰
         */
        [kvoObj addObserver:observer
                 forKeyPath:@"computedProp"
                    options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                    context:nil];
        kvoObj.strProp = @"computedProp";
        kvoObj.intProp = 666;
        [kvoObj removeObserver:observer forKeyPath:@"computedProp" context:nil];
        
        // 可变数组与KVO
        [kvoObj addObserver:observer
                 forKeyPath:@"mutableArrProp"
                    options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                    context:nil];
        kvoObj.mutableArrProp = [NSMutableArray new];
        // 点语法获取的是真正的数组
        NSMutableArray *realArr = kvoObj.mutableArrProp;
        // mutableArrayValueForKey 获取的是集合代理对象
        NSMutableArray *proxyArr = [kvoObj mutableArrayValueForKey:@"mutableArrProp"];
        NSLog(@"realArr: %@, proxyArr: %@", [realArr class], [proxyArr class]);
        [realArr addObject:@"obj1"]; // 不会发通知
        [proxyArr addObject:@"obj2"]; // 会发通知
        [kvoObj removeObserver:observer forKeyPath:@"mutableArrProp" context:nil];
        
        // 监听信息
        [kvoObj addObserver:observer
                 forKeyPath:@"mutableArrProp"
                    options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                    context:nil];
        [kvoObj addObserver:observer
                 forKeyPath:@"mutableArrProp"
                    options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                    context:"context1"];
        id observationInfo = kvoObj.observationInfo;
        // 一个数组存储NSKeyValueObservance对象，每个对象包含观察者，被监听的属性，添加观察者设置的选项和上下文信息等
        NSLog(@"%@", observationInfo);
        [kvoObj removeObserver:observer forKeyPath:@"mutableArrProp" context:nil];
        [kvoObj removeObserver:observer forKeyPath:@"mutableArrProp" context:"context1"];

    }
    
    
}
