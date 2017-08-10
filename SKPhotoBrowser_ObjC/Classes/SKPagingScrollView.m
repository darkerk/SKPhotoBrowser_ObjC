//
//  SKPagingScrollView.m
//  PhotoBrowser
//
//  Created by wgh on 2017/7/31.
//  Copyright © 2017年 huoban. All rights reserved.
//

#import "SKPagingScrollView.h"
#import "SKCaptionView.h"
#import "SKDetectingImageView.h"
#import "SKZoomingScrollView.h"
#import "SKPhotoBrowser.h"
#import "SKPhoto.h"

static const NSUInteger kPageIndexTagOffset = 1000;
static const CGFloat kSideMargin = 10.0;

@interface SKPagingScrollView ()

@property(nonatomic,strong)NSMutableArray<SKZoomingScrollView *> *visiblePages;
@property(nonatomic,strong)NSMutableArray<SKZoomingScrollView *> *recycledPages;

@property(nonatomic,weak)SKPhotoBrowser *browser;

@end

@implementation SKPagingScrollView

- (instancetype)initWithFrame:(CGRect)frame browser: (SKPhotoBrowser *)browser
{
    self = [self initWithFrame:frame];
    if (self) {
        self.browser = browser;
        [self updateFrame:self.bounds currentPageIndex:browser.currentPageIndex];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.pagingEnabled = YES;
        self.visiblePages = [NSMutableArray arrayWithCapacity:0];
        self.recycledPages = [NSMutableArray arrayWithCapacity:0];
    }
    return self;
}

- (NSInteger)numberOfPhotos {
    if (self.browser) {
        return self.browser.photos.count;
    }
    return 0;
}

- (void)loadAdjacentPhotosIfNecessary: (id<SKPhotoProtocol>)photo currentPageIndex: (NSUInteger)currentPageIndex {
    if (!self.browser) {
        return;
    }
    
    SKZoomingScrollView *page = [self pageDisplayingAtPhoto:photo];
    if (page) {
        NSUInteger pageIndex = page.tag - kPageIndexTagOffset;
        if (currentPageIndex == pageIndex) {
            //Previous
            if (pageIndex > 0) {
                id<SKPhotoProtocol> previousPhoto = self.browser.photos[pageIndex - 1];
                if (!previousPhoto.underlyingImage) {
                    [previousPhoto loadUnderlyingImageAndNotify];
                }
            }
            //next
            if (pageIndex < self.numberOfPhotos - 1) {
                id<SKPhotoProtocol> nextPhoto = self.browser.photos[pageIndex + 1];
                if (!nextPhoto.underlyingImage) {
                    [nextPhoto loadUnderlyingImageAndNotify];
                }
            }
        }
    }
}

- (void)updateFrame: (CGRect)bounds currentPageIndex: (NSUInteger)currentPageIndex {
    CGRect rect = bounds;
    rect.origin.x -= kSideMargin;
    rect.size.width += (kSideMargin * 2);
    
    self.frame = rect;
    if (self.visiblePages.count > 0) {
        for (SKZoomingScrollView *page in self.visiblePages) {
            NSUInteger pageIndex = page.tag - kPageIndexTagOffset;
            page.frame = [self frameForPageAtIndex:pageIndex];
            [page setMaxMinZoomScalesForCurrentBounds];
            if (page.captionView) {
                page.captionView.frame = [self frameForCaptionView:page.captionView index:pageIndex];
            }
        }
    }
    
    [self updateContentSize];
    [self updateContentOffset:currentPageIndex];
}

- (void)reload {
    [self.visiblePages enumerateObjectsUsingBlock:^(SKZoomingScrollView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    
    [self.visiblePages removeAllObjects];
    [self.recycledPages removeAllObjects];
}

- (void)deleteImage {
    if (self.numberOfPhotos > 0) {
        [self.visiblePages.firstObject.captionView removeFromSuperview];
    }
}

- (void)animate: (CGRect)frame {
    [self setContentOffset:CGPointMake(frame.origin.x - kSideMargin, 0) animated:YES];
}

- (void)updateContentSize {
    self.contentSize = CGSizeMake(CGRectGetWidth(self.bounds) * self.numberOfPhotos, CGRectGetHeight(self.bounds));
}

- (void)updateContentOffset: (NSUInteger)index {
    CGFloat pageWidth = CGRectGetWidth(self.bounds);
    CGFloat _newOffset = index * pageWidth;
    self.contentOffset = CGPointMake(_newOffset, 0);
}

- (void)tilePages {
    if (!self.browser) {
        return;
    }
    
    NSUInteger firstIndex = [self getFirstIndex];
    NSUInteger lastIndex = [self getLastIndex];
    
    __weak __typeof(&*self)weakSelf = self;
    [self.visiblePages enumerateObjectsUsingBlock:^(SKZoomingScrollView * _Nonnull page, NSUInteger idx, BOOL * _Nonnull stop) {
        if (page.tag - kPageIndexTagOffset < firstIndex || page.tag - kPageIndexTagOffset > lastIndex) {
            [weakSelf.recycledPages addObject:page];
            [page prepareForReuse];
            [page removeFromSuperview];
        }
    }];
    
    NSMutableSet<SKZoomingScrollView *> *visibleSet = [[NSMutableSet alloc] initWithCapacity:0];
    [visibleSet addObjectsFromArray:self.visiblePages];
    
    NSSet<SKZoomingScrollView *> *recycledPagesSet = [NSSet setWithArray:self.recycledPages];
    [visibleSet minusSet:recycledPagesSet];
    
    [self.visiblePages removeAllObjects];
    [self.visiblePages addObjectsFromArray:[visibleSet allObjects]];
    
    while (self.recycledPages.count > 2) {
        [self.recycledPages removeObjectAtIndex:0];
    }
    
    for (NSUInteger i = firstIndex; i <= lastIndex; i++) {
        
        BOOL temp = NO;
        for (SKZoomingScrollView *v in self.visiblePages) {
            if (v.tag - kPageIndexTagOffset == i) {
                temp = YES;
            }
        }
        if (temp) {
            continue;
        }
        
        SKZoomingScrollView *page = [[SKZoomingScrollView alloc] initWithFrame:self.frame browser:self.browser];
        page.frame = [self frameForPageAtIndex:i];
        page.tag = i + kPageIndexTagOffset;
        page.photo = self.browser.photos[i];
        
        [self.visiblePages addObject:page];
        [self addSubview:page];
        
        SKCaptionView *captionView = [self createCaptionView:i];
        if (captionView) {
            captionView.frame = [self frameForCaptionView:captionView index:i];
            captionView.alpha = [self.browser areControlsHidden] ? 0 : 1;
            [self addSubview:captionView];
            
            page.captionView = captionView;
        }
    }
}

- (CGRect)frameForCaptionView: (SKCaptionView *)captionView index: (NSUInteger)index {
    CGRect pageFrame = [self frameForPageAtIndex:index];
    CGSize captionSize = [captionView sizeThatFits:CGSizeMake(pageFrame.size.width, 0)];
    CGFloat navHeight = 44;
    if (self.browser.navigationController.navigationBar) {
        navHeight = self.browser.navigationController.navigationBar.frame.size.height;
    }
    return CGRectMake(pageFrame.origin.x, CGRectGetHeight(pageFrame) - captionSize.height - navHeight, CGRectGetWidth(pageFrame), captionSize.height);
}

- (nullable SKZoomingScrollView *)pageDisplayedAtIndex: (NSUInteger)index {
    for (SKZoomingScrollView *page in self.visiblePages) {
        if (page.tag - kPageIndexTagOffset == index) {
            return page;
        }
    }
    return nil;
}

- (nullable SKZoomingScrollView *)pageDisplayingAtPhoto: (id<SKPhotoProtocol>)photo {
    for (SKZoomingScrollView *page in self.visiblePages) {
        if ([page.photo isEqual:photo]) {
            return page;
        }
    }
    return nil;
}

- (NSSet<SKCaptionView *> *)getCaptionViews {
    NSMutableSet<SKCaptionView *> *captionViews = [[NSMutableSet alloc] initWithCapacity:0];
    [self.visiblePages enumerateObjectsUsingBlock:^(SKZoomingScrollView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.captionView) {
            [captionViews addObject:obj.captionView];
        }
    }];
    return captionViews;
}

//////////////////////////////////////////////////////////////////////////////////////
- (CGRect)frameForPageAtIndex: (NSUInteger)index {
    CGRect pageFrame = self.bounds;
    pageFrame.size.width -= (kSideMargin * 2);
    pageFrame.origin.x = (CGRectGetWidth(self.bounds) * index) + kSideMargin;
    return pageFrame;
}

- (nullable SKCaptionView *)createCaptionView: (NSUInteger)index {
    id<SKPhotoProtocol> photo = [self.browser photoAtIndex:index];
    if (photo && photo.caption) {
        return [[SKCaptionView alloc] initWithPhoto:photo];
    }
    return nil;
}

- (NSUInteger)getFirstIndex {
    NSInteger firstIndex = floor((CGRectGetMinX(self.bounds) + kSideMargin * 2) / CGRectGetWidth(self.bounds));
    if (firstIndex < 0) {
        return 0;
    }
    if (firstIndex > self.numberOfPhotos - 1) {
        return self.numberOfPhotos - 1;
    }
    return firstIndex;
}

- (NSUInteger)getLastIndex {
    NSInteger lastIndex = floor((CGRectGetMaxX(self.bounds) - kSideMargin * 2 - 1) / CGRectGetWidth(self.bounds));
    if (lastIndex < 0) {
        return 0;
    }
    if (lastIndex > self.numberOfPhotos - 1) {
        return self.numberOfPhotos - 1;
    }
    return lastIndex;
}

@end
