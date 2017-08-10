//
//  SKPhoto.m
//  PhotoBrowser
//
//  Created by wgh on 2017/7/31.
//  Copyright © 2017年 huoban. All rights reserved.
//

#import "SKPhoto.h"
#import "SKCache.h"

@implementation SKPhoto

- (instancetype)initWithImage: (UIImage *)image
{
    self = [super init];
    if (self) {
        self.underlyingImage = image;
        self.contentMode = UIViewContentModeScaleAspectFill;
    }
    return self;
}

- (instancetype)initWithURLString: (NSString *)urlString
{
    self = [super init];
    if (self) {
        self.photoURL = urlString;
        self.contentMode = UIViewContentModeScaleAspectFill;
    }
    return self;
}

- (instancetype)initWithURLString: (NSString *)urlString holderImage:(nullable UIImage *)holderImage
{
    self = [super init];
    if (self) {
        self.photoURL = urlString;
        self.underlyingImage = holderImage;
        self.contentMode = UIViewContentModeScaleAspectFill;
    }
    return self;
}

- (void)checkCache {
    if (self.photoURL && self.shouldCachePhotoURLImage) {
        if ([[SKCache sharedCache].imageCache conformsToProtocol:@protocol(SKRequestResponseCacheable)]) {
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.photoURL]];
            UIImage *image = [[SKCache sharedCache] imageForRequest:request];
            if (image) {
                self.underlyingImage = image;
            }
        }else {
            UIImage *image = [[SKCache sharedCache] imageForKey:self.photoURL];
            self.underlyingImage = image;
        }
    }
}

- (void)loadUnderlyingImageAndNotify {
    if (!self.photoURL) {
        return;
    }
    
    NSURL *url = [NSURL URLWithString:self.photoURL];
    if (!url) {
        return;
    }
    
    __weak __typeof(&*self)weakSelf = self;
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionTask *task;
    task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf loadUnderlyingImageComplete];
            });
        }else {
            if (data && response) {
                UIImage *image = [UIImage imageWithData:data];
                if (image) {
                    if (weakSelf.shouldCachePhotoURLImage) {
                        if ([[SKCache sharedCache].imageCache conformsToProtocol:@protocol(SKRequestResponseCacheable)]) {
                            [[SKCache sharedCache] setImageData:data response:response request:task.originalRequest];
                        }else {
                            [[SKCache sharedCache] setImage:image forKey:weakSelf.photoURL];
                        }
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        weakSelf.underlyingImage = image;
                        [weakSelf loadUnderlyingImageComplete];
                    });
                }
            }
        }
    }];
    [task resume];
}

- (void)loadUnderlyingImageComplete {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"photoLoadingDidEndNotification" object:self];
}

////////////////
+ (instancetype)photoWithImage: (UIImage *)image {
   return [[SKPhoto alloc] initWithImage:image];
}

+ (instancetype)photoWithImageURL: (NSString *)url {
    return [[SKPhoto alloc] initWithURLString:url];
}

+ (instancetype)photoWithImageURL: (NSString *)url holderImage: (nullable UIImage *)holderImage {
    return [[SKPhoto alloc] initWithURLString:url holderImage:holderImage];
}

@end
