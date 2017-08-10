//
//  SKPagingScrollView.h
//  PhotoBrowser
//
//  Created by wgh on 2017/7/31.
//  Copyright © 2017年 huoban. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SKPhotoProtocol;
@class SKZoomingScrollView;
@class SKCaptionView;
@class SKPhotoBrowser;
@interface SKPagingScrollView : UIScrollView

@property(nonatomic,assign)NSInteger numberOfPhotos;

- (nonnull instancetype)initWithFrame:(CGRect)frame browser: (nonnull SKPhotoBrowser *)browser;

- (void)loadAdjacentPhotosIfNecessary: (nonnull id<SKPhotoProtocol>)photo currentPageIndex: (NSUInteger)currentPageIndex;
- (void)updateFrame: (CGRect)bounds currentPageIndex: (NSUInteger)currentPageIndex;
- (nullable SKZoomingScrollView *)pageDisplayingAtPhoto: (nonnull id<SKPhotoProtocol>)photo;
- (nullable SKZoomingScrollView *)pageDisplayedAtIndex: (NSUInteger)index;
- (void)reload;
- (void)updateContentOffset: (NSUInteger)index;
- (void)tilePages;
- (void)animate: (CGRect)frame;
- (nonnull NSSet<SKCaptionView *> *)getCaptionViews;
- (void)deleteImage;

@end
