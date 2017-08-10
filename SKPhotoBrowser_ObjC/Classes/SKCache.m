//
//  SKCache.m
//  PhotoBrowser
//
//  Created by wgh on 2017/7/31.
//  Copyright © 2017年 huoban. All rights reserved.
//

#import "SKCache.h"

@implementation SKCache

+ (instancetype)sharedCache {
    static SKCache *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[SKCache alloc] init];
    });
    
    return _instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.imageCache = [[SKDefaultImageCache alloc] init];
    }
    return self;
}

- (UIImage *_Nullable)imageForKey:(NSString *)key {
    if ([self.imageCache conformsToProtocol:@protocol(SKImageCacheable)]) {
        return [(id<SKImageCacheable>)self.imageCache imageForKey:key];
    }
    return nil;
}

- (void)setImage:(UIImage *)image forKey:(NSString *)key {
    if ([self.imageCache conformsToProtocol:@protocol(SKImageCacheable)]) {
        [(id<SKImageCacheable>)self.imageCache setImage:image forKey:key];
    }
}

- (void)removeImageForKey:(NSString *)key {
    if ([self.imageCache conformsToProtocol:@protocol(SKImageCacheable)]) {
        [(id<SKImageCacheable>)self.imageCache removeImageForKey:key];
    }
}

- (UIImage *_Nullable)imageForRequest:(NSURLRequest *)request {
    if ([self.imageCache conformsToProtocol:@protocol(SKRequestResponseCacheable)]) {
        NSCachedURLResponse *response = [(id<SKRequestResponseCacheable>)self.imageCache cachedResponseForRequest:request];
        if (response) {
            return [UIImage imageWithData:response.data];
        }
    }
    return nil;
}

- (void)setImageData: (NSData *)data response: (NSURLResponse *)response request: (NSURLRequest *)request {
    if ([self.imageCache conformsToProtocol:@protocol(SKRequestResponseCacheable)] && request) {
        NSCachedURLResponse *cachedResponse = [[NSCachedURLResponse alloc] initWithResponse:response data:data];
        [(id<SKRequestResponseCacheable>)self.imageCache storeCachedResponse:cachedResponse forRequest:request];
    }
}

@end

@implementation SKDefaultImageCache

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.cache = [[NSCache alloc] init];
    }
    return self;
}

- (UIImage *_Nullable)imageForKey:(NSString *)key {
    id obj = [self.cache objectForKey:key];
    if (obj && [obj isKindOfClass:[UIImage class]]) {
        return obj;
    }
    return nil;
}

- (void)setImage:(UIImage *)image forKey:(NSString *)key {
    [self.cache setObject:image forKey:key];
}

- (void)removeImageForKey:(NSString *)key {
    [self.cache removeObjectForKey:key];
}

@end
