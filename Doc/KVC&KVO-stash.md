## KVC - NSObject的NSKeyValueCoding分类

### 1.KVC定义的方法
通过属性的名称(key)来间接访问与key相关的属性，不需要getter&setter也可以
主要有以下几个最为重要的方法：
1. 设值的方法：
```
- (void)setValue:(nullable id)value forKey:(NSString *)key;           
- (void)setValue:(nullable id)value forKeyPath:(NSString *)keyPath;   
- (void)setValuesForKeysWithDictionary:(NSDictionary<NSString *, id> *)keyedValues;
```

2. 取值的方法：
```
- (nullable id)valueForKey:(NSString *)key;
- (nullable id)valueForKeyPath:(NSString *)keyPath;
- (NSDictionary<NSString *, id> *)dictionaryWithValuesForKeys:(NSArray<NSString *> *)keys;
```



3. 其他一些常见方法：
```
// 是否可以直接访问成员变量，默认返回YES
+ (BOOL)accessInstanceVariablesDirectly;

// KVC提供属性值正确性验证的API，它可以用来检查set的值是否正确，为不正确的值做个替换值或者拒绝设置新值并返回错误原因
- (BOOL)validateValue:(inout id __nullable * __nonnull)ioValue forKey:(NSString *)inKey error:(out NSError **)outError;
- (BOOL)validateValue:(inout id  _Nullable *)ioValue forKeyPath:(NSString *)inKeyPath error:(out NSError * _Nullable *)outError;

// 取值&设值时传入不存在的key
- (nullable id)valueForUndefinedKey:(NSString *)key;
- (void)setValue:(nullable id)value forUndefinedKey:(NSString *)key;

// 给非对象属性传nil，则会调用这个方法，默认抛出异常
- (void)setNilValueForKey:(NSString *)key;

// 返回一个像NSMutableArray的代理对象，响应NSMutableSet的方法
- (NSMutableArray *)mutableArrayValueForKey:(NSString *)key;
- (NSMutableArray *)mutableArrayValueForKeyPath:(NSString *)keyPath;

// 返回一个像NSMutableSet的代理对象，响应NSMutableSet的方法
- (NSMutableArray *)mutableSetValueForKey:(NSString *)key;
- (NSMutableArray *)mutableSetValueForKeyPath:(NSString *)keyPath;

// 返回一个像NSMutableOrderedSet的代理对象，响应NSMutableOrderedSet的方法
- (NSMutableArray *)mutableOrderedSetValueForKey:(NSString *)key;
- (NSMutableArray *)mutableOrderedSetValueForKeyPath:(NSString *)keyPath;
```

### 2.集合代理对象实现KVC
#### 1.不可变集合
访问不可变集合，调用valueForKey: 可以返回 NSArray | NSSet | NSOrderedSet 的集合代理对象

+ 返回NSArray的集合代理对象需要实现以下方法:
```
- countOf<Key>            // count   

// 以下二选一
- objectIn<Key>AtIndex:   // objectAtIndex:
- <key>AtIndexes:         // objectsAtIndexes:

// 可选(增强性能)
- get<Key>:range:         // getObjects:range:
```
+ 返回NSSet的集合代理对象需要实现以下方法:
```
- countOf<Key>            // count 
- enumeratorOf<Key>       // objectEnumerator
- memberOf<Key>:          // member:
```
+ 返回NSOrderedSet的集合代理对象需要实现以下方法:
```
- countOf<Key>            // count
- indexIn<Key>OfObject:   // indexOfObject:

// 以下二选一
- objectIn<Key>AtIndex:   // objectAtIndex:
- <key>AtIndexes:         // objectAtIndexes:

// 可选(增强性能）
- get<Key>:range:         // getObjects:range:
```

#### 2.可变集合
访问可变集合，调用mutable<Array | Set | OrderedSet>valueFor<Key | KeyPath>: 可以返回 NSMutableArray | NSMutableSet | NSMutableOrderedSet 的集合代理对象

+ 返回NSMutableArray | NSMutableOrderedSet的集合代理对象需要实现以下方法:
```
// 至少实现一个插入方法和删除方法
- insertObject:in<Key>AtIndex:     // insertObject:atIndex:
- removeObjectFrom<Key>AtIndex:    // removeObjectAtIndex:
- insert<Key>:atIndexes:           // insertObjects:atIndexes:
- remove<Key>AtIndexes:            // removeObjectsAtIndexes:

// 可选(增强性能) 二选一
// replaceObjectAtIndex:withOject:
- replaceObjectIn<Key>AtIndex:withObject:  

// replaceObjectsAtIndexes:withObjects
- replace<Key>AtIndexes:with<Key>:         
```

+ 返回NSMutableSet的集合代理对象需要实现以下方法:
```
// 至少实现一个插入方法和删除方法
- add<Key>Object:              // addObject:
- remove<Key>Object:           // removeObject:
- add<Key>:                    // unionSet:
- remove<Key>:                 // minusSet:
// 可选(增强性能) 二选一
- intersect<Key>:              // intersectSet:
- set<Key>:                    // setSet:
```

### 3.KVC集合操作符
+ 简单集合操作符
    + @count  返回集合中对象总数的NSNumber对象
    + @sum    将集合中对象都转换成double类型，求和转换成NSNumber对象返回
    + @avg    将集合中对象都转换成double类型，求均值转换成NSNumber对象返回
    + @max    返回集合中对象的最大值
    + @min    返回集合中对象的最小值
+ 对象操作符
    + @unionOfObjects 返回一个由操作符右边的keyPath所指定的对象属性组成的数组
    + @distinctUnionOfObjects 在unionOfObjects的基础上去重
+ 嵌套集合操作符
    + @unionOfArrays 返回了一个数组，其中包含这个集合中每个数组对于这个操作符右边指定的keyPath进行操作之后的值
    + @distinctUnionOfArrays 在unionOfArrays基础上去重
    + @distinctUnionOfSets 返回的是NSSet

ref: http://nshipster.cn/kvc-collection-operators/






## KVO - NSObject的NSKeyValueObserving分类
KVO是一种允许对象监听其他对象的属性，然后在所监听的属性被修改时收到通知的一种机制
### KVO定义的方法
1. 值更改通知回调方法
```
/*
 * keyPath - 被监听对象的keyPath
 * object  - keyPath所属对象
 * change  - 包含了属性被修改的信息的字典，内容由添加观察者时设置的options决定
 * context - 添加观察者时提供的上下文信息
 */
- (void)observeValueForKeyPath:(NSString *)keyPath 
                      ofObject:(id)object 
                        change:(NSDictionary<NSKeyValueChangeKey, id> *)change 
                       context:(void *)context;
```
2. 注册/删除观察者的方法
```
- (void)addObserver:(NSObject *)observer
         forKeyPath:(NSString *)keyPath
            options:(NSKeyValueObservingOptions)options
            context:(void *)context;

- (void)removeObserver:(NSObject *)observer
            forKeyPath:(NSString *)keyPath;

- (void)removeObserver:(NSObject *)observer
            forKeyPath:(NSString *)keyPath
               context:(void *)context;

enum {
    // 提供属性的新值
    NSKeyValueObservingOptionNew = 0x01,

    // 提供属性的旧值
    NSKeyValueObservingOptionOld = 0x02,

    // 如果指定，则在添加观察者的时候立即发送一个通知给观察者，
    // 并且是在注册观察者方法返回之前
    NSKeyValueObservingOptionInitial = 0x04,

    // 在willChangeValueForKey:和didChangeValueForKey:都会给观察者发送通知
    // 在willChangeValueForKey:的发送通知里的change字典会有NSKeyValueChangeNotificationIsPriorKey标识是值改变之前
    // 这样每次修改属性时，实际上会发送两条通知
    NSKeyValueObservingOptionPrior = 0x08
};
typedef NSUInteger NSKeyValueObservingOptions;
```
3. 通知观察者发生了什么变化的方法(手动控制KVO的时候使用)
```
- (void)willChangeValueForKey:(NSString *)key;
- (void)didChangeValueForKey:(NSString *)key;

// 有序的一对多关系
- (void)willChange:(NSKeyValueChange)changeKind 
   valuesAtIndexes:(NSIndexSet *)indexes 
            forKey:(NSString *)key;
- (void)didChange:(NSKeyValueChange)changeKind
  valuesAtIndexes:(NSIndexSet *)indexes
           forKey:(NSString *)key;

// 无序的一对多关系
- (void)willChangeValueForKey:(NSString *)key 
              withSetMutation:(NSKeyValueSetMutationKind)mutationKind     
                 usingObjects:(NSSet *)objects;
- (void)didChangeValueForKey:(NSString *)key
             withSetMutation:(NSKeyValueSetMutationKind)mutationKind
                usingObjects:(NSSet *)objects;
```