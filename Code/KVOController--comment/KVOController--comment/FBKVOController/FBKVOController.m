/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.

 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import "FBKVOController.h"

#import <objc/message.h>
#import <pthread.h>

#if !__has_feature(objc_arc)
#error This file must be compiled with ARC. Convert your project to ARC or specify the -fobjc-arc flag.
#endif

NS_ASSUME_NONNULL_BEGIN

#pragma mark Utilities -

static NSString *describe_option(NSKeyValueObservingOptions option)
{
  switch (option) {
    case NSKeyValueObservingOptionNew:
      return @"NSKeyValueObservingOptionNew";
      break;
    case NSKeyValueObservingOptionOld:
      return @"NSKeyValueObservingOptionOld";
      break;
    case NSKeyValueObservingOptionInitial:
      return @"NSKeyValueObservingOptionInitial";
      break;
    case NSKeyValueObservingOptionPrior:
      return @"NSKeyValueObservingOptionPrior";
      break;
    default:
      NSCAssert(NO, @"unexpected option %tu", option);
      break;
  }
  return nil;
}

static void append_option_description(NSMutableString *s, NSUInteger option)
{
  if (0 == s.length) {
    [s appendString:describe_option(option)];
  } else {
    [s appendString:@"|"];
    [s appendString:describe_option(option)];
  }
}

static NSUInteger enumerate_flags(NSUInteger *ptrFlags)
{
  NSCAssert(ptrFlags, @"expected ptrFlags");
  if (!ptrFlags) {
    return 0;
  }

  NSUInteger flags = *ptrFlags;
  if (!flags) {
    return 0;
  }

  NSUInteger flag = 1 << __builtin_ctzl(flags);
  flags &= ~flag;
  *ptrFlags = flags;
  return flag;
}

static NSString *describe_options(NSKeyValueObservingOptions options)
{
  NSMutableString *s = [NSMutableString string];
  NSUInteger option;
  while (0 != (option = enumerate_flags(&options))) {
    append_option_description(s, option);
  }
  return s;
}

#pragma mark _FBKVOInfo -

typedef NS_ENUM(uint8_t, _FBKVOInfoState) {
  _FBKVOInfoStateInitial = 0,

  // whether the observer registration in Foundation has completed
  _FBKVOInfoStateObserving,

  // whether `unobserve` was called before observer registration in Foundation has completed
  // this could happen when `NSKeyValueObservingOptionInitial` is one of the NSKeyValueObservingOptions
  _FBKVOInfoStateNotObserving,
};

NSString *const FBKVONotificationKeyPathKey = @"FBKVONotificationKeyPathKey";

/**
 @abstract The key-value observation info.
 @discussion Object equality is only used within the scope of a controller instance. Safely omit controller from equality definition.
 */
@interface _FBKVOInfo : NSObject
@end

@implementation _FBKVOInfo
{
@public
  __weak FBKVOController *_controller;
  NSString *_keyPath;
  NSKeyValueObservingOptions _options;
  SEL _action;
  void *_context;
  FBKVONotificationBlock _block;
  _FBKVOInfoState _state;
}

- (instancetype)initWithController:(FBKVOController *)controller
                           keyPath:(NSString *)keyPath
                           options:(NSKeyValueObservingOptions)options
                             block:(nullable FBKVONotificationBlock)block
                            action:(nullable SEL)action
                           context:(nullable void *)context
{
  self = [super init];
  if (nil != self) {
    _controller = controller;
    _block = [block copy];
    _keyPath = [keyPath copy];
    _options = options;
    _action = action;
    _context = context;
  }
  return self;
}

- (instancetype)initWithController:(FBKVOController *)controller keyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options block:(FBKVONotificationBlock)block
{
  return [self initWithController:controller keyPath:keyPath options:options block:block action:NULL context:NULL];
}

- (instancetype)initWithController:(FBKVOController *)controller keyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options action:(SEL)action
{
  return [self initWithController:controller keyPath:keyPath options:options block:NULL action:action context:NULL];
}

- (instancetype)initWithController:(FBKVOController *)controller keyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context
{
  return [self initWithController:controller keyPath:keyPath options:options block:NULL action:NULL context:context];
}

- (instancetype)initWithController:(FBKVOController *)controller keyPath:(NSString *)keyPath
{
  return [self initWithController:controller keyPath:keyPath options:0 block:NULL action:NULL context:NULL];
}

- (NSUInteger)hash
{
  return [_keyPath hash];
}

- (BOOL)isEqual:(id)object
{
  if (nil == object) {
    return NO;
  }
  if (self == object) {
    return YES;
  }
  if (![object isKindOfClass:[self class]]) {
    return NO;
  }
  return [_keyPath isEqualToString:((_FBKVOInfo *)object)->_keyPath];
}

- (NSString *)debugDescription
{
  NSMutableString *s = [NSMutableString stringWithFormat:@"<%@:%p keyPath:%@", NSStringFromClass([self class]), self, _keyPath];
  if (0 != _options) {
    [s appendFormat:@" options:%@", describe_options(_options)];
  }
  if (NULL != _action) {
    [s appendFormat:@" action:%@", NSStringFromSelector(_action)];
  }
  if (NULL != _context) {
    [s appendFormat:@" context:%p", _context];
  }
  if (NULL != _block) {
    [s appendFormat:@" block:%p", _block];
  }
  [s appendString:@">"];
  return s;
}

@end

#pragma mark _FBKVOSharedController -

/**
 @abstract The shared KVO controller instance.
 @discussion Acts as a receptionist, receiving and forwarding KVO notifications.
 */
@interface _FBKVOSharedController : NSObject

/** A shared instance that never deallocates. */
+ (instancetype)sharedController;

/** observe an object, info pair */
- (void)observe:(id)object info:(nullable _FBKVOInfo *)info;

/** unobserve an object, info pair */
- (void)unobserve:(id)object info:(nullable _FBKVOInfo *)info;

/** unobserve an object with a set of infos */
- (void)unobserve:(id)object infos:(nullable NSSet *)infos;

@end

@implementation _FBKVOSharedController
{
  NSHashTable<_FBKVOInfo *> *_infos;
  pthread_mutex_t _mutex;
}

+ (instancetype)sharedController
{
  static _FBKVOSharedController *_controller = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _controller = [[_FBKVOSharedController alloc] init];
  });
  return _controller;
}

- (instancetype)init
{
  self = [super init];
  if (nil != self) {
    NSHashTable *infos = [NSHashTable alloc];
#ifdef __IPHONE_OS_VERSION_MIN_REQUIRED
    _infos = [infos initWithOptions:NSPointerFunctionsWeakMemory|NSPointerFunctionsObjectPointerPersonality capacity:0];
#elif defined(__MAC_OS_X_VERSION_MIN_REQUIRED)
    if ([NSHashTable respondsToSelector:@selector(weakObjectsHashTable)]) {
      _infos = [infos initWithOptions:NSPointerFunctionsWeakMemory|NSPointerFunctionsObjectPointerPersonality capacity:0];
    } else {
      // silence deprecated warnings
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
      _infos = [infos initWithOptions:NSPointerFunctionsZeroingWeakMemory|NSPointerFunctionsObjectPointerPersonality capacity:0];
#pragma clang diagnostic pop
    }

#endif
    pthread_mutex_init(&_mutex, NULL);
  }
  return self;
}

- (void)dealloc
{
  pthread_mutex_destroy(&_mutex);
}

- (NSString *)debugDescription
{
  NSMutableString *s = [NSMutableString stringWithFormat:@"<%@:%p", NSStringFromClass([self class]), self];

  // lock
  pthread_mutex_lock(&_mutex);

  NSMutableArray *infoDescriptions = [NSMutableArray arrayWithCapacity:_infos.count];
  for (_FBKVOInfo *info in _infos) {
    [infoDescriptions addObject:info.debugDescription];
  }

  [s appendFormat:@" contexts:%@", infoDescriptions];

  // unlock
  pthread_mutex_unlock(&_mutex);

  [s appendString:@">"];
  return s;
}

- (void)observe:(id)object info:(nullable _FBKVOInfo *)info
{
  if (nil == info) {
    return;
  }

  // register info
  pthread_mutex_lock(&_mutex);
  // [_FBKVOSharedController sharedController]的_infos成员是一个维护所有_FBKVOInfo的HashTable
  [_infos addObject:info];
  pthread_mutex_unlock(&_mutex);

  // KVO注册观察者
  // add observer
  [object addObserver:self forKeyPath:info->_keyPath options:info->_options context:(void *)info];

  if (info->_state == _FBKVOInfoStateInitial) {
    info->_state = _FBKVOInfoStateObserving;
  } else if (info->_state == _FBKVOInfoStateNotObserving) {
    // this could happen when `NSKeyValueObservingOptionInitial` is one of the NSKeyValueObservingOptions,
    // and the observer is unregistered within the callback block.
    // at this time the object has been registered as an observer (in Foundation KVO),
    // so we can safely unobserve it.
    [object removeObserver:self forKeyPath:info->_keyPath context:(void *)info];
  }
}

- (void)unobserve:(id)object info:(nullable _FBKVOInfo *)info
{
  if (nil == info) {
    return;
  }

  // unregister info
  pthread_mutex_lock(&_mutex);
  [_infos removeObject:info];
  pthread_mutex_unlock(&_mutex);

  // remove observer
  if (info->_state == _FBKVOInfoStateObserving) {
    [object removeObserver:self forKeyPath:info->_keyPath context:(void *)info];
  }
  info->_state = _FBKVOInfoStateNotObserving;
}

- (void)unobserve:(id)object infos:(nullable NSSet<_FBKVOInfo *> *)infos
{
  if (0 == infos.count) {
    return;
  }

  // unregister info
  pthread_mutex_lock(&_mutex);
  for (_FBKVOInfo *info in infos) {
    [_infos removeObject:info];
  }
  pthread_mutex_unlock(&_mutex);

  // remove observer
  for (_FBKVOInfo *info in infos) {
    if (info->_state == _FBKVOInfoStateObserving) {
      [object removeObserver:self forKeyPath:info->_keyPath context:(void *)info];
    }
    info->_state = _FBKVOInfoStateNotObserving;
  }
}

/*
 * 集中接受KVO的属性变更通知
 * 通过响应KVO信息进行属性变更通知的派发
 * 回调方式优先级 block > action > 覆写observeValueForKeyPath:ofObject:change:context:方法
 */
- (void)observeValueForKeyPath:(nullable NSString *)keyPath
                      ofObject:(nullable id)object
                        change:(nullable NSDictionary<NSKeyValueChangeKey, id> *)change
                       context:(nullable void *)context
{
  NSAssert(context, @"missing context keyPath:%@ object:%@ change:%@", keyPath, object, change);

  _FBKVOInfo *info;

  {
    // lookup context in registered infos, taking out a strong reference only if it exists
    pthread_mutex_lock(&_mutex);
    info = [_infos member:(__bridge id)context];
    pthread_mutex_unlock(&_mutex);
  }

  if (nil != info) {

    // take strong reference to controller
    FBKVOController *controller = info->_controller;
    if (nil != controller) {

      // take strong reference to observer
      id observer = controller.observer;
      if (nil != observer) {

        // dispatch custom block or action, fall back to default action
        if (info->_block) {
          NSDictionary<NSKeyValueChangeKey, id> *changeWithKeyPath = change;
          // add the keyPath to the change dictionary for clarity when mulitple keyPaths are being observed
          if (keyPath) {
            NSMutableDictionary<NSString *, id> *mChange = [NSMutableDictionary dictionaryWithObject:keyPath forKey:FBKVONotificationKeyPathKey];
            [mChange addEntriesFromDictionary:change];
            changeWithKeyPath = [mChange copy];
          }
          info->_block(observer, object, changeWithKeyPath);
        } else if (info->_action) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
          [observer performSelector:info->_action withObject:change withObject:object];
#pragma clang diagnostic pop
        } else {
          [observer observeValueForKeyPath:keyPath ofObject:object change:change context:info->_context];
        }
      }
    }
  }
}

@end

#pragma mark FBKVOController -

@implementation FBKVOController
{
  NSMapTable<id, NSMutableSet<_FBKVOInfo *> *> *_objectInfosMap;
  pthread_mutex_t _lock;
}

#pragma mark Lifecycle -

+ (instancetype)controllerWithObserver:(nullable id)observer
{
  return [[self alloc] initWithObserver:observer];
}

/*
 * KVOController初始化全能方法
 * @param observer - 观察者
 * @param retainObserved - 标记是否持有观察者
 * 主要初始化以下三个成员
 * _observer: 观察者
 * _objectInfosMap: 存储KVO有关信息的NSMapTable:以观察者为key，value是一个_FBKVOInfo的set
 * _lock: 持有一把pthread_mutex_t锁，用于操作_objectInfosMap时保证线程安全
 */
- (instancetype)initWithObserver:(nullable id)observer retainObserved:(BOOL)retainObserved
{
  self = [super init];
  if (nil != self) {
    // 设置self为观察者
    _observer = observer;
    /*
     * NSPointerFunctionsStrongMemory: 强引用
     * NSPointerFunctionsWeakMemory: 弱引用
     * NSPointerFunctionsObjectPointerPersonality
     */
    NSPointerFunctionsOptions keyOptions = retainObserved ? NSPointerFunctionsStrongMemory|NSPointerFunctionsObjectPointerPersonality : NSPointerFunctionsWeakMemory|NSPointerFunctionsObjectPointerPersonality;
    // initWithKeyOptions: 指明maptable的key的内存管理选项和值对比选项
    // valueOptions: 指明maptable的value的内存管理选项和值对比选项
    _objectInfosMap = [[NSMapTable alloc] initWithKeyOptions:keyOptions valueOptions:NSPointerFunctionsStrongMemory|NSPointerFunctionsObjectPersonality capacity:0];
    // 初始化pthread_mutex_t锁
    pthread_mutex_init(&_lock, NULL);
  }
  return self;
}

- (instancetype)initWithObserver:(nullable id)observer
{
  return [self initWithObserver:observer retainObserved:YES];
}

- (void)dealloc
{
  [self unobserveAll];
  pthread_mutex_destroy(&_lock);
}

#pragma mark Properties -

- (NSString *)debugDescription
{
  NSMutableString *s = [NSMutableString stringWithFormat:@"<%@:%p", NSStringFromClass([self class]), self];
  [s appendFormat:@" observer:<%@:%p>", NSStringFromClass([_observer class]), _observer];

  // lock
  pthread_mutex_lock(&_lock);

  if (0 != _objectInfosMap.count) {
    [s appendString:@"\n  "];
  }

  for (id object in _objectInfosMap) {
    NSMutableSet *infos = [_objectInfosMap objectForKey:object];
    NSMutableArray *infoDescriptions = [NSMutableArray arrayWithCapacity:infos.count];
    [infos enumerateObjectsUsingBlock:^(_FBKVOInfo *info, BOOL *stop) {
      [infoDescriptions addObject:info.debugDescription];
    }];
    [s appendFormat:@"%@ -> %@", object, infoDescriptions];
  }

  // unlock
  pthread_mutex_unlock(&_lock);

  [s appendString:@">"];
  return s;
}

#pragma mark Utilities -

- (void)_observe:(id)object info:(_FBKVOInfo *)info
{
  // lock
  pthread_mutex_lock(&_lock);

  // 寻找以object为key的_FBKVOInfo的set
  NSMutableSet *infos = [_objectInfosMap objectForKey:object];

  // check for info existence
  _FBKVOInfo *existingInfo = [infos member:info];
  // 过滤重复的KVO
  if (nil != existingInfo) {
    // observation info already exists; do not observe it again

    // unlock and return
    pthread_mutex_unlock(&_lock);
    return;
  }

  // 初始化_FBKVOInofo的set，存入_objectInfosMap
  // lazilly create set of infos
  if (nil == infos) {
    infos = [NSMutableSet set];
    [_objectInfosMap setObject:infos forKey:object];
  }

  // 添加_FBKVOInfo到set中
  // add info and oberve
  [infos addObject:info];

  // unlock prior to callout
  pthread_mutex_unlock(&_lock);

  // 调用内部[_FBKVOSharedController sharedController]的observe:info:发起KBO
  [[_FBKVOSharedController sharedController] observe:object info:info];
}

- (void)_unobserve:(id)object info:(_FBKVOInfo *)info
{
  // lock
  pthread_mutex_lock(&_lock);

  // get observation infos
  NSMutableSet *infos = [_objectInfosMap objectForKey:object];

  // lookup registered info instance
  _FBKVOInfo *registeredInfo = [infos member:info];

  if (nil != registeredInfo) {
    [infos removeObject:registeredInfo];

    // remove no longer used infos
    if (0 == infos.count) {
      [_objectInfosMap removeObjectForKey:object];
    }
  }

  // unlock
  pthread_mutex_unlock(&_lock);

  // unobserve
  [[_FBKVOSharedController sharedController] unobserve:object info:registeredInfo];
}

- (void)_unobserve:(id)object
{
  // lock
  pthread_mutex_lock(&_lock);

  NSMutableSet *infos = [_objectInfosMap objectForKey:object];

  // remove infos
  [_objectInfosMap removeObjectForKey:object];

  // unlock
  pthread_mutex_unlock(&_lock);

  // unobserve
  [[_FBKVOSharedController sharedController] unobserve:object infos:infos];
}

- (void)_unobserveAll
{
  // lock
  pthread_mutex_lock(&_lock);

  NSMapTable *objectInfoMaps = [_objectInfosMap copy];

  // clear table and map
  [_objectInfosMap removeAllObjects];

  // unlock
  pthread_mutex_unlock(&_lock);

  _FBKVOSharedController *shareController = [_FBKVOSharedController sharedController];

  for (id object in objectInfoMaps) {
    // unobserve each registered object and infos
    NSSet *infos = [objectInfoMaps objectForKey:object];
    [shareController unobserve:object infos:infos];
  }
}

#pragma mark API -
/*
 * KVOController监听属性的主要方法
 * @param object - 被观察的对象
 * @param keyPath - 被监听的属性名
 * @param options - KVO观察选项
 * @param block - KVO收到通知后执行block
 */
- (void)observe:(nullable id)object keyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options block:(FBKVONotificationBlock)block
{
  NSAssert(0 != keyPath.length && NULL != block, @"missing required parameters observe:%@ keyPath:%@ block:%p", object, keyPath, block);
  if (nil == object || 0 == keyPath.length || NULL == block) {
    return;
  }
    
  /*
   * 初始化_FBKVOInfo，保存整个KVO过程的所有信息
   */
  // create info
  _FBKVOInfo *info = [[_FBKVOInfo alloc] initWithController:self keyPath:keyPath options:options block:block];

  // observe object with info
  [self _observe:object info:info];
}


- (void)observe:(nullable id)object keyPaths:(NSArray<NSString *> *)keyPaths options:(NSKeyValueObservingOptions)options block:(FBKVONotificationBlock)block
{
  NSAssert(0 != keyPaths.count && NULL != block, @"missing required parameters observe:%@ keyPath:%@ block:%p", object, keyPaths, block);
  if (nil == object || 0 == keyPaths.count || NULL == block) {
    return;
  }

  for (NSString *keyPath in keyPaths) {
    [self observe:object keyPath:keyPath options:options block:block];
  }
}

- (void)observe:(nullable id)object keyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options action:(SEL)action
{
  NSAssert(0 != keyPath.length && NULL != action, @"missing required parameters observe:%@ keyPath:%@ action:%@", object, keyPath, NSStringFromSelector(action));
  NSAssert([_observer respondsToSelector:action], @"%@ does not respond to %@", _observer, NSStringFromSelector(action));
  if (nil == object || 0 == keyPath.length || NULL == action) {
    return;
  }

  // create info
  _FBKVOInfo *info = [[_FBKVOInfo alloc] initWithController:self keyPath:keyPath options:options action:action];

  // observe object with info
  [self _observe:object info:info];
}

- (void)observe:(nullable id)object keyPaths:(NSArray<NSString *> *)keyPaths options:(NSKeyValueObservingOptions)options action:(SEL)action
{
  NSAssert(0 != keyPaths.count && NULL != action, @"missing required parameters observe:%@ keyPath:%@ action:%@", object, keyPaths, NSStringFromSelector(action));
  NSAssert([_observer respondsToSelector:action], @"%@ does not respond to %@", _observer, NSStringFromSelector(action));
  if (nil == object || 0 == keyPaths.count || NULL == action) {
    return;
  }

  for (NSString *keyPath in keyPaths) {
    [self observe:object keyPath:keyPath options:options action:action];
  }
}

- (void)observe:(nullable id)object keyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(nullable void *)context
{
  NSAssert(0 != keyPath.length, @"missing required parameters observe:%@ keyPath:%@", object, keyPath);
  if (nil == object || 0 == keyPath.length) {
    return;
  }

  // create info
  _FBKVOInfo *info = [[_FBKVOInfo alloc] initWithController:self keyPath:keyPath options:options context:context];

  // observe object with info
  [self _observe:object info:info];
}

- (void)observe:(nullable id)object keyPaths:(NSArray<NSString *> *)keyPaths options:(NSKeyValueObservingOptions)options context:(nullable void *)context
{
  NSAssert(0 != keyPaths.count, @"missing required parameters observe:%@ keyPath:%@", object, keyPaths);
  if (nil == object || 0 == keyPaths.count) {
    return;
  }

  for (NSString *keyPath in keyPaths) {
    [self observe:object keyPath:keyPath options:options context:context];
  }
}

- (void)unobserve:(nullable id)object keyPath:(NSString *)keyPath
{
  // create representative info
  _FBKVOInfo *info = [[_FBKVOInfo alloc] initWithController:self keyPath:keyPath];

  // unobserve object property
  [self _unobserve:object info:info];
}

- (void)unobserve:(nullable id)object
{
  if (nil == object) {
    return;
  }

  [self _unobserve:object];
}

- (void)unobserveAll
{
  [self _unobserveAll];
}

@end

NS_ASSUME_NONNULL_END
