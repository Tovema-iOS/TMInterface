//
//  TMInterfaceManager.m
//  Pods
//
//  Created by LinXiaoBin on 16/3/15.
//
//

#import "TMInterfaceManager.h"
#import "TMBaseRequest.h"

@interface TMInterfaceManager() <TMInterfaceManagerDelegate>
{
    NSMutableSet *_interfaces;
    dispatch_semaphore_t _lock;
}

@end

@implementation TMInterfaceManager

+ (instancetype)sharedInstance
{
    static TMInterfaceManager *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

+ (instancetype)modelInstance:(NSString *)name
{
    if (!name) {
        return nil;
    }

    static NSMutableDictionary *cache = nil;
    static dispatch_semaphore_t lock;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = @{}.mutableCopy;
        lock = dispatch_semaphore_create(1);
    });

    TMInterfaceManager *manager = cache[name];
    if (manager) {
        return manager;
    }

    dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
    manager = cache[name] ?: [[TMInterfaceManager alloc] init];
    cache[name] = manager;
    dispatch_semaphore_signal(lock);
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _interfaces = [NSMutableSet set];
        _lock = dispatch_semaphore_create(1);
    }
    return self;
}

#pragma mark - private

- (void)addInterface:(TMBaseRequest *)interface
{
    if ([interface isKindOfClass:[TMBaseRequest class]]) {
        dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
        interface.managerDelegate = self;
        [_interfaces addObject:interface];
        dispatch_semaphore_signal(_lock);
    }
}

- (void)removeInterface:(TMBaseRequest *)interface
{
    if ([interface isKindOfClass:[TMBaseRequest class]]) {
        dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
        [_interfaces removeObject:interface];
        dispatch_semaphore_signal(_lock);
    }
}

#pragma mark TMInterfaceManagerDelegate <NSObject>
- (void)tm_interfaceDidRequestFinished:(TMBaseRequest *)interface
{
    [self removeInterface:interface];
}

@end
