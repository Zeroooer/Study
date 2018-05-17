/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.
 
 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import "NSObject+FBKVOController.h"

#import <objc/message.h>

#if !__has_feature(objc_arc)
#error This file must be compiled with ARC. Convert your project to ARC or specify the -fobjc-arc flag.
#endif

#pragma mark NSObject Category -

NS_ASSUME_NONNULL_BEGIN

static void *NSObjectKVOControllerKey = &NSObjectKVOControllerKey;
static void *NSObjectKVOControllerNonRetainingKey = &NSObjectKVOControllerNonRetainingKey;

@implementation NSObject (FBKVOController)

/*
 * KVOController & KVOControllerNonRetaining 初始化最终调用的是下面这个方法
 * - (instancetype)initWithObserver:(nullable id)observer retainObserved:(BOOL)retainObserved;
 * 这个分类就是添加了两个关联对象
 * setter就是使用objc_setAssociatedObject按照键值简单存一下
 * getter方法就是初始化FBKVOController
 */

- (FBKVOController *)KVOController
{
  id controller = objc_getAssociatedObject(self, NSObjectKVOControllerKey);
  
  // lazily create the KVOController
  if (nil == controller) {
    controller = [FBKVOController controllerWithObserver:self];
    self.KVOController = controller;
  }
  
  return controller;
}

- (void)setKVOController:(FBKVOController *)KVOController
{
  objc_setAssociatedObject(self, NSObjectKVOControllerKey, KVOController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (FBKVOController *)KVOControllerNonRetaining
{
  id controller = objc_getAssociatedObject(self, NSObjectKVOControllerNonRetainingKey);
  
  if (nil == controller) {
    controller = [[FBKVOController alloc] initWithObserver:self retainObserved:NO];
    self.KVOControllerNonRetaining = controller;
  }
  
  return controller;
}

- (void)setKVOControllerNonRetaining:(FBKVOController *)KVOControllerNonRetaining
{
  objc_setAssociatedObject(self, NSObjectKVOControllerNonRetainingKey, KVOControllerNonRetaining, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end


NS_ASSUME_NONNULL_END
