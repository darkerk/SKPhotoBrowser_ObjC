//
//  SKPhoto.h
//  PhotoBrowser
//
//  Created by wgh on 2017/7/31.
//  Copyright © 2017年 huoban. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SKPhotoProtocol <NSObject>

@property(nonatomic,readonly)UIImage *underlyingImage;
@property(nonatomic,readonly,copy)NSString *caption;
@property(nonatomic,readwrite)NSInteger index;
@property(nonatomic,readwrite)UIViewContentMode contentMode;

- (void)loadUnderlyingImageAndNotify;
- (void)checkCache;

@end

@interface SKPhoto : NSObject <SKPhotoProtocol>

@property(nonatomic,strong)UIImage *underlyingImage;
@property(nonatomic,copy)NSString *caption;
@property(nonatomic,assign)UIViewContentMode contentMode;
@property(nonatomic,assign)NSInteger index;
@property(nonatomic,copy)NSString *photoURL;
@property(nonatomic,assign)BOOL shouldCachePhotoURLImage;

@end

@interface SKPhoto ()

+ (instancetype)photoWithImage: (UIImage *)image;
+ (instancetype)photoWithImageURL: (NSString *)url;
+ (instancetype)photoWithImageURL: (NSString *)url holderImage: (UIImage *)holderImage;

@end
