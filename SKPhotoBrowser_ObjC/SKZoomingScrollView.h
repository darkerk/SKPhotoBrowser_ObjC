//
//  SKZoomingScrollView.h
//  PhotoBrowser
//
//  Created by wgh on 2017/7/31.
//  Copyright © 2017年 huoban. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SKPhotoProtocol;
@class SKCaptionView;
@class SKPhotoBrowser;
@class SKDetectingImageView;
@interface SKZoomingScrollView : UIScrollView

@property(nonatomic,strong)SKDetectingImageView *photoImageView;
@property(nonatomic,strong)SKCaptionView *captionView;
@property(nonatomic,strong)id<SKPhotoProtocol> photo;

- (instancetype)initWithFrame:(CGRect)frame browser: (SKPhotoBrowser *)browser;
- (void)prepareForReuse;
- (void)displayImage: (BOOL)complete;
- (void)displayImageFailure;
- (void)setMaxMinZoomScalesForCurrentBounds;

@end
