//
//  SKCache.h
//  PhotoBrowser
//
//  Created by wgh on 2017/7/31.
//  Copyright © 2017年 huoban. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SKCacheable <NSObject>
@end

@protocol SKImageCacheable <SKCacheable>
- (UIImage *_Nullable)imageForKey: (NSString *_Nonnull)key;
- (void)setImage: (UIImage *_Nonnull)image forKey: (NSString *_Nonnull)key;
- (void)removeImageForKey: (NSString *_Nonnull)key;

@end

@protocol SKRequestResponseCacheable <SKCacheable>

- (NSCachedURLResponse *_Nullable)cachedResponseForRequest: (NSURLRequest *_Nonnull)request;
- (void)storeCachedResponse: (NSCachedURLResponse *_Nonnull)cachedResponse  forRequest: (NSURLRequest *_Nonnull)request;

@end

@interface SKCache : NSObject

@property(nonatomic, nullable)id<SKCacheable> imageCache;
+ (instancetype _Nonnull )sharedCache;

- (UIImage *_Nullable)imageForKey: (NSString *_Nonnull)key;
- (void)setImage: (UIImage *_Nonnull)image forKey: (NSString *_Nonnull)key;
- (void)removeImageForKey: (NSString *_Nonnull)key;

- (UIImage *_Nullable)imageForRequest:(NSURLRequest *_Nonnull)request;
- (void)setImageData: (NSData *_Nonnull)data response: (NSURLResponse *_Nonnull)response request: (NSURLRequest *_Nullable)request;

@end

@interface SKDefaultImageCache : NSObject<SKImageCacheable>

@property(nonatomic,nonnull,strong)NSCache *cache;

@end
