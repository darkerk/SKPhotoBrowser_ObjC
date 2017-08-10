//
//  SKPhotoBrowser.h
//  PhotoBrowser
//
//  Created by wgh on 2017/7/31.
//  Copyright © 2017年 huoban. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKCache.h"
#import "SKPhoto.h"
#import "SKPhotoBrowserOptions.h"

@class SKPhotoBrowser;
@protocol SKPhotoBrowserDelegate <NSObject>
@optional
- (void)didShowPhotoAtIndex: (NSUInteger)index;
- (void)willDismissAtPageIndex: (NSUInteger)index;

- (void)willShowActionSheet: (NSUInteger)photoIndex;
- (void)didDismissAtPageIndex: (NSUInteger)index;
- (void)didDismissActionSheetWithButtonIndex: (NSUInteger)index photoIndex: (NSUInteger)photoIndex;
- (void)didScrollToIndex: (NSUInteger)index;
- (void)photoBrowser: (nonnull SKPhotoBrowser *)browser removePhotoAtIndex: (NSUInteger)index reload: (void (^ __nullable)(void))reload;
- (nullable UIView *)photoBrowser: (nonnull SKPhotoBrowser *)browser viewForPhotoAtIndex: (NSUInteger)index;
- (void)photoBrowser: (nonnull SKPhotoBrowser *)browser controlsVisibilityToggled: (BOOL)hidden;

@end

@protocol SKPhotoProtocol;
@class SKZoomingScrollView;
@interface SKPhotoBrowser : UIViewController

@property(nonatomic,nonnull,strong)NSMutableArray<id<SKPhotoProtocol>> *photos;
@property(nonatomic,assign)NSUInteger numberOfPhotos;
@property(nonatomic,assign)NSUInteger initialPageIndex;
@property(nonatomic,assign)NSUInteger currentPageIndex;

@property(nonatomic,nonnull,strong)UIView *backgroundView;

@property(nonatomic,nullable,weak)id<SKPhotoBrowserDelegate> delegate;

- (nonnull instancetype)initWithPhotos: (nonnull NSArray<id<SKPhotoProtocol>> *)photos;
- (nonnull instancetype)initWithOriginImage: (nonnull UIImage *)originImage photos: (nonnull NSArray<id<SKPhotoProtocol>> *)photos animatedFromView: (nonnull UIView *)animatedFromView;
- (void)initializePageIndex: (NSUInteger)index;

- (void)hideControlsAfterDelay;
- (void)cancelControlHiding;

- (BOOL)areControlsHidden;
- (void)determineAndClose;
- (void)toggleControls;

- (void)gotoPreviousPage;
- (void)gotoNextPage;

- (void)actionButtonPressed;

- (void)showButtons;

- (void)dismissPhotoBrowserAnimated: (BOOL)flag completion: (void (^ __nullable)(void))completion;

- (nullable id<SKPhotoProtocol>)photoAtIndex: (NSUInteger)index;
- (nonnull UIImage *)getImageFromView: (nonnull UIView *)sender;
- (nullable SKZoomingScrollView *)pageDisplayedAtIndex: (NSUInteger)index;

@end
