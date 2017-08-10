//
//  SKPhotoBrowser.m
//  PhotoBrowser
//
//  Created by wgh on 2017/7/31.
//  Copyright © 2017年 huoban. All rights reserved.
//

#import "SKPhotoBrowser.h"
#import "SKButton.h"
#import "SKToolbar.h"
#import "SKPagingScrollView.h"
#import "SKZoomingScrollView.h"
#import "SKAnimator.h"
#import "SKCaptionView.h"

NSUInteger const kPageIndexTagOffset = 1000;

@interface Defer : NSObject
+ (instancetype)block:(void(^)())block;
@end
@implementation Defer {
@private void(^_deferBlock)();
}
+ (instancetype)block:(void (^)())block {
    Defer *_d = [Defer new];
    _d->_deferBlock = block ?: ^{};
    return _d;
}
- (void)dealloc {
    _deferBlock();
}
@end

@interface SKPhotoBrowser ()<UIScrollViewDelegate>

@property(nonatomic,strong)SKCloseButton *closeButton;
@property(nonatomic,strong)SKDeleteButton *deleteButton;
@property(nonatomic,strong)SKToolbar *toolbar;

@property(nonatomic,strong)UIActivityViewController *activityViewController;
@property(nonatomic,strong)UIActivityItemProvider *activityItemProvider;
@property(nonatomic,strong)UIPanGestureRecognizer *panGesture;

@property(nonatomic,strong)UIWindow *applicationWindow;
@property(nonatomic,strong)SKPagingScrollView *pagingScrollView;

@property(nonatomic,assign)BOOL isEndAnimationByToolBar;
@property(nonatomic,assign)BOOL isViewActive;
@property(nonatomic,assign)BOOL isPerformingLayout;

@property(nonatomic,assign)CGFloat firstX;
@property(nonatomic,assign)CGFloat firstY;

@property(nonatomic,strong)NSTimer *controlVisibilityTimer;
@property(nonatomic,strong)SKAnimator *animator;

@end

@implementation SKPhotoBrowser

- (instancetype)initWithPhotos: (NSArray<id<SKPhotoProtocol>> *)photos
{
    self = [super init];
    if (self) {
        [self setup];
        for (id<SKPhotoProtocol> photo in photos) {
            [photo checkCache];
            [self.photos addObject:photo];
        }
    }
    return self;
}

- (instancetype)initWithOriginImage: (UIImage *)originImage photos: (NSArray<id<SKPhotoProtocol>> *)photos animatedFromView: (UIView *)animatedFromView
{
    self = [super init];
    if (self) {
        [self setup];
        self.animator.senderOriginImage = originImage;
        self.animator.senderViewForAnimation = animatedFromView;
        for (id<SKPhotoProtocol> photo in photos) {
            [photo checkCache];
            [self.photos addObject:photo];
        }
    }
    return self;
}

- (void)setup {
    self.photos = [NSMutableArray arrayWithCapacity:0];
    self.animator = [[SKAnimator alloc] init];
    
    self.isEndAnimationByToolBar = YES;
    
    if ([UIApplication sharedApplication].delegate.window) {
        self.applicationWindow = [UIApplication sharedApplication].delegate.window;
    }else if ([UIApplication sharedApplication].keyWindow) {
        self.applicationWindow = [UIApplication sharedApplication].keyWindow;
    }else {
        return;
    }
    
    self.modalPresentationCapturesStatusBarAppearance = YES;
    self.modalPresentationStyle = UIModalPresentationCustom;
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSKPhotoLoadingDidEndNotification:) name:@"photoLoadingDidEndNotification" object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self configureAppearance];
    [self configureCloseButton];
    [self configureDeleteButton];
    [self configureToolbar];
    
    [self.animator willPresentBrowser:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self reloadData];
    NSInteger i =0;
    for (id<SKPhotoProtocol> photo in self.photos) {
        photo.index = i;
        i = i + 1;
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.isPerformingLayout = YES;
    [self.pagingScrollView updateFrame:self.view.bounds currentPageIndex:self.currentPageIndex];
    self.toolbar.frame = [self frameForToolbarAtOrientation];
     
    if ([self.delegate respondsToSelector:@selector(didShowPhotoAtIndex:)]) {
        [self.delegate didShowPhotoAtIndex:self.currentPageIndex];
    }
    
    self.isPerformingLayout = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.isViewActive = YES;
}

- (BOOL)prefersStatusBarHidden {
    return ![SKPhotoBrowserOptions sharedInstance].displayStatusbar;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
// MARK: - Public Function For Customizing Buttons
- (void)updateCloseButton: (UIImage *)image size: (CGSize)size {
    if (!self.closeButton) {
        [self configureCloseButton];
    }
    [self.closeButton setImage:image forState:UIControlStateNormal];
    if (!CGSizeEqualToSize(size, CGSizeZero)) {
        [self.closeButton setFrameSize:size];
    }
}

- (void)updateDeleteButton: (UIImage *)image size: (CGSize)size {
    if (!self.deleteButton) {
        [self configureDeleteButton];
    }
    [self.deleteButton setImage:image forState:UIControlStateNormal];
    if (!CGSizeEqualToSize(size, CGSizeZero)) {
        [self.deleteButton setFrameSize:size];
    }
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////
// MARK: - Public Function For Browser Control
- (void)initializePageIndex: (NSUInteger)index {
    NSUInteger i = index;
    if (index > self.numberOfPhotos) {
        i = self.numberOfPhotos - 1;
    }
    
    self.initialPageIndex = i;
    self.currentPageIndex = i;
    
    if (self.isViewLoaded) {
        [self jumpToPageAtIndex:index];
        if (!self.isViewActive) {
            [self.pagingScrollView tilePages];
        }
    }
}

- (void)jumpToPageAtIndex: (NSUInteger)index {
    if (index < self.numberOfPhotos) {
        if (!self.isEndAnimationByToolBar) {
            return;
        }
        self.isEndAnimationByToolBar = NO;
        [self.toolbar updateToolbar:self.currentPageIndex];
        
        CGRect pageFrame = [self frameForPageAtIndex:index];
        [self.pagingScrollView animate:pageFrame];
    }
    [self hideControlsAfterDelay];
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////
// MARK: - Private Functio
- (void)configureAppearance {
    self.view.backgroundColor = [SKPhotoBrowserOptions sharedInstance].backgroundColor;
    self.view.clipsToBounds = YES;
    self.view.opaque = NO;
    
    self.backgroundView = [[UIView alloc ] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds))];
    self.backgroundView.backgroundColor = [SKPhotoBrowserOptions sharedInstance].backgroundColor;
    self.backgroundView.alpha = 0;
    [self.applicationWindow addSubview:self.backgroundView];
    
    self.pagingScrollView = [[SKPagingScrollView alloc] initWithFrame:self.view.frame browser:self];
    self.pagingScrollView.delegate = self;
    [self.view addSubview:self.pagingScrollView];
    
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)];
    self.panGesture.minimumNumberOfTouches = 1;
    self.panGesture.maximumNumberOfTouches = 1;
    if ([SKPhotoBrowserOptions sharedInstance].disableVerticalSwipe) {
        [self.view addGestureRecognizer:self.panGesture];
    }
}

- (void)configureCloseButton {
    self.closeButton = [[SKCloseButton alloc] initWithFrame:CGRectZero];
    [self.closeButton addTarget:self action:@selector(closeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    self.closeButton.hidden = ![SKPhotoBrowserOptions sharedInstance].displayCloseButton;
    [self.view addSubview:self.closeButton];
}

- (void)configureDeleteButton {
    self.deleteButton = [[SKDeleteButton alloc] initWithFrame:CGRectZero];
    [self.deleteButton addTarget:self action:@selector(deleteButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    self.deleteButton.hidden = ![SKPhotoBrowserOptions sharedInstance].displayDeleteButton;
    [self.view addSubview:self.deleteButton];
}

- (void)configureToolbar {
    self.toolbar = [[SKToolbar alloc] initWithFrame:[self frameForToolbarAtOrientation] browser:self];
    [self.view addSubview:self.toolbar];
}

- (void)setControlsHidden: (BOOL)hidden animated: (BOOL)animated permanent: (BOOL)permanent {
    [self cancelControlHiding];
    
    NSSet<SKCaptionView *> *captionViews = [self.pagingScrollView getCaptionViews];
    
    CGFloat alpha = hidden ? 0.0 : 1.0;
    [UIView animateWithDuration:0.35 animations:^{
        self.toolbar.alpha = alpha;
        self.toolbar.frame = hidden ? [self frameForToolbarHideAtOrientation] : [self frameForToolbarAtOrientation];
        
        if ([SKPhotoBrowserOptions sharedInstance].displayCloseButton) {
            self.closeButton.alpha = alpha;
            self.closeButton.frame = hidden ? self.closeButton.hideFrame : self.closeButton.showFrame;
        }
        if ([SKPhotoBrowserOptions sharedInstance].displayDeleteButton) {
            self.deleteButton.alpha = alpha;
            self.deleteButton.frame = hidden ? self.deleteButton.hideFrame : self.deleteButton.showFrame;
        }
        
        [captionViews enumerateObjectsUsingBlock:^(SKCaptionView * _Nonnull obj, BOOL * _Nonnull stop) {
            obj.alpha = alpha;
        }];
    }];
    
    if (!permanent) {
        [self hideControlsAfterDelay];
    }
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)deleteImage {
    [Defer block:^{
        [self reloadData];
    }];
    
    if (self.photos.count > 1) {
        [self.pagingScrollView deleteImage];
        
        [self.photos removeObjectAtIndex:self.currentPageIndex];
        if (self.currentPageIndex != 0) {
            [self gotoPreviousPage];
        }
        [self.toolbar updateToolbar:self.currentPageIndex];
        
    }else if (self.photos.count == 1) {
        [self dismissPhotoBrowserAnimated:YES completion:nil];
    }
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////
// MARK: - Internal Function For Frame Calc
- (CGRect)frameForToolbarAtOrientation {
    UIInterfaceOrientation currentOrientation = [UIApplication sharedApplication].statusBarOrientation;
    CGFloat height = 44.0;
    if (self.navigationController.navigationBar) {
        height = CGRectGetHeight(self.navigationController.navigationBar.frame);
    }
    if (UIInterfaceOrientationIsLandscape(currentOrientation)) {
        height = 32.0;
    }
    return CGRectMake(0, CGRectGetHeight(self.view.bounds) - height, CGRectGetWidth(self.view.bounds), height);
}

- (CGRect)frameForToolbarHideAtOrientation {
    UIInterfaceOrientation currentOrientation = [UIApplication sharedApplication].statusBarOrientation;
    CGFloat height = 44.0;
    if (self.navigationController.navigationBar) {
        height = CGRectGetHeight(self.navigationController.navigationBar.frame);
    }
    if (UIInterfaceOrientationIsLandscape(currentOrientation)) {
        height = 32.0;
    }
    return CGRectMake(0, CGRectGetHeight(self.view.bounds) + height, CGRectGetWidth(self.view.bounds), height);
}

- (CGRect)frameForPageAtIndex: (NSUInteger)index {
    CGRect bounds = self.pagingScrollView.bounds;
    CGRect pageFrame = bounds;
    pageFrame.size.width -= (2 * 10);
    pageFrame.origin.x = (bounds.size.width * index) + 10;
    return pageFrame;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)reloadData {
    [self performLayout];
    [self.view setNeedsLayout];
}

- (void)performLayout {
    self.isPerformingLayout = YES;
    
    [self.toolbar updateToolbar:self.currentPageIndex];
    
    [self.pagingScrollView reload];
    
    [self.pagingScrollView updateContentOffset:self.currentPageIndex];
    [self.pagingScrollView tilePages];
    
    if ([self.delegate respondsToSelector:@selector(didShowPhotoAtIndex:)]) {
        [self.delegate didShowPhotoAtIndex:self.currentPageIndex];
    }
    
    self.isPerformingLayout = NO;
}

- (void)prepareForClosePhotoBrowser {
    [self cancelControlHiding];
    [self.applicationWindow removeGestureRecognizer:self.panGesture];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)dismissPhotoBrowserAnimated: (BOOL)flag completion: (void (^ __nullable)(void))completion {
    [self prepareForClosePhotoBrowser];
    if (!flag) {
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    }
    
    [self dismissViewControllerAnimated:!flag completion:^{
        if (completion) {
            completion();
        }
        if ([self.delegate respondsToSelector:@selector(didDismissAtPageIndex:)]) {
            [self.delegate didDismissAtPageIndex:self.currentPageIndex];
        }
    }];
}

- (void)determineAndClose {
    if ([self.delegate respondsToSelector:@selector(willDismissAtPageIndex:)]) {
        [self.delegate willDismissAtPageIndex:self.currentPageIndex];
    }
    [self.animator willDismissBrowser:self];
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)hideControlsAfterDelay {
    [self cancelControlHiding];
    self.controlVisibilityTimer = [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(hideControls:) userInfo:nil repeats:NO];
}

- (void)hideControls: (NSTimer *)timer {
    [self hideControls];
    if ([self.delegate respondsToSelector:@selector(photoBrowser:controlsVisibilityToggled:)]) {
        [self.delegate photoBrowser:self controlsVisibilityToggled:YES];
    }
}

- (void)hideControls {
    [self setControlsHidden:YES animated:YES permanent:NO];
}

- (void)cancelControlHiding {
    if (self.controlVisibilityTimer) {
        [self.controlVisibilityTimer invalidate];
        self.controlVisibilityTimer = nil;
    }
}

- (BOOL)areControlsHidden {
    return self.toolbar.alpha == 0.0;
}

- (void)toggleControls {
    BOOL hidden = ![self areControlsHidden];
    [self setControlsHidden:hidden animated:YES permanent:NO];
    if ([self.delegate respondsToSelector:@selector(photoBrowser:controlsVisibilityToggled:)]) {
        [self.delegate photoBrowser:self controlsVisibilityToggled:[self areControlsHidden]];
    }
}

- (void)popupShare: (BOOL)includeCaption {
    id<SKPhotoProtocol> photo = self.photos[self.currentPageIndex];
    UIImage *underlyingImage = photo.underlyingImage;
    if (!underlyingImage) {
        return;
    }
    
    NSMutableArray *activityItems = [NSMutableArray arrayWithCapacity:0];
    [activityItems addObject:underlyingImage];
    
    if (photo.caption && includeCaption) {
        NSString *shareExtraCaption = [SKPhotoBrowserOptions sharedInstance].shareExtraCaption;
        if (shareExtraCaption) {
            NSString *caption = [photo.caption stringByAppendingString:shareExtraCaption];
            [activityItems addObject:caption];
        }else {
            [activityItems addObject:photo.caption];
        }
    }
    
    if (self.activityItemProvider) {
        [activityItems addObject:self.activityItemProvider];
    }
    __weak __typeof(&*self)weakSelf = self;
    self.activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    _activityViewController.completionWithItemsHandler = ^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
        
        [weakSelf hideControlsAfterDelay];
        weakSelf.activityViewController = nil;
    };
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self presentViewController:self.activityViewController animated:YES completion:nil];
    }else {
        self.activityViewController.modalPresentationStyle = UIModalPresentationPopover;
        UIPopoverPresentationController *popover = self.activityViewController.popoverPresentationController;
        if (popover) {
            popover.barButtonItem = self.toolbar.toolActionButton;
        }
        [self presentViewController:self.activityViewController animated:YES completion:nil];
    }
}

- (void)gotoPreviousPage {
    [self jumpToPageAtIndex:self.currentPageIndex - 1];
}

- (void)gotoNextPage {
    [self jumpToPageAtIndex:self.currentPageIndex + 1];
}

///////////////////////////////////////////////////////////////////////////////////////////////
// MARK: - Internal Function For Button Pressed, UIGesture Control
- (void)panGestureRecognized: (UIPanGestureRecognizer *)sender {
    SKZoomingScrollView *zoomingScrollView = [self.pagingScrollView pageDisplayedAtIndex:self.currentPageIndex];
    if (!zoomingScrollView) {
        return;
    }
    self.backgroundView.hidden = YES;
    
    CGFloat viewHeight = CGRectGetHeight(zoomingScrollView.frame);
    CGFloat viewHalfHeight = viewHeight / 2.0;
    CGPoint translatedPoint = [sender translationInView:self.view];
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        self.firstX = zoomingScrollView.center.x;
        self.firstY = zoomingScrollView.center.y;
        
        [self hideControls];
        [self setNeedsStatusBarAppearanceUpdate];
    }
    
    translatedPoint = CGPointMake(self.firstX, self.firstY + translatedPoint.y);
    zoomingScrollView.center = translatedPoint;
    
    CGFloat minOffset = viewHalfHeight / 4;
    CGFloat offset = 1 - (zoomingScrollView.center.y > viewHalfHeight
                          ? zoomingScrollView.center.y - viewHalfHeight
                          : -(zoomingScrollView.center.y - viewHalfHeight)) / viewHalfHeight;
    
    self.view.backgroundColor = [[SKPhotoBrowserOptions sharedInstance].backgroundColor colorWithAlphaComponent:MAX(0.7, offset)];
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        if ( zoomingScrollView.center.y > viewHalfHeight + minOffset
            || zoomingScrollView.center.y < viewHalfHeight - minOffset) {
            
            self.backgroundView.backgroundColor = self.view.backgroundColor;
            [self determineAndClose];
        }else {
            [self setNeedsStatusBarAppearanceUpdate];
            
            CGFloat velocityY = [sender velocityInView:self.view].y * 0.35;
            CGFloat finalX = self.firstX;
            CGFloat finalY = viewHalfHeight;
            
            double animationDuration = fabs(velocityY) * 0.0002 + 0.2;
            
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:animationDuration];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
            
            self.view.backgroundColor = [SKPhotoBrowserOptions sharedInstance].backgroundColor;
            zoomingScrollView.center = CGPointMake(finalX, finalY);
            
            [UIView commitAnimations];
        }
    }
}

- (void)deleteButtonPressed: (UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(photoBrowser:removePhotoAtIndex:reload:)]) {
        __weak __typeof(&*self)weakSelf = self;
        [self.delegate photoBrowser:self removePhotoAtIndex:self.currentPageIndex reload:^{
            [weakSelf deleteImage];
        }];
    }
}

- (void)closeButtonPressed: (UIButton *)sender {
    [self determineAndClose];
}

- (void)actionButtonPressed {
    if ([self.delegate respondsToSelector:@selector(willShowActionSheet:)]) {
        [self.delegate willShowActionSheet:self.currentPageIndex];
    }
    if (self.numberOfPhotos == 0) {
        return;
    }
    
    NSArray *titles = [SKPhotoBrowserOptions sharedInstance].actionButtonTitles;
    if (titles && titles.count > 0) {
        UIAlertController *actionSheetController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        [actionSheetController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        
        
        [titles enumerateObjectsUsingBlock:^(NSString *text, NSUInteger idx, BOOL * _Nonnull stop) {
            [actionSheetController addAction:[UIAlertAction actionWithTitle:text style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                if ([self.delegate respondsToSelector:@selector(didDismissActionSheetWithButtonIndex:photoIndex:)]) {
                    [self.delegate didDismissActionSheetWithButtonIndex:idx photoIndex:self.currentPageIndex];
                }
            }]];
        }];

        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            [self presentViewController:actionSheetController animated:YES completion:nil];
        }else {
            actionSheetController.modalPresentationStyle = UIModalPresentationPopover;
            UIPopoverPresentationController *popover = actionSheetController.popoverPresentationController;
            if (popover) {
                popover.sourceView = self.view;
                popover.barButtonItem = self.toolbar.toolActionButton;
            }
    
            [self presentViewController:actionSheetController animated:YES completion:nil];
        }
        
    }else {
        [self popupShare:YES];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////
- (NSUInteger)numberOfPhotos {
    return [self.photos count];
}

- (nullable id<SKPhotoProtocol>)photoAtIndex: (NSUInteger)index {
    if (index < self.photos.count) {
        return self.photos[index];
    }
    return nil;
}

- (void)showButtons {
    if ([SKPhotoBrowserOptions sharedInstance].displayCloseButton) {
        self.closeButton.alpha = 1;
        self.closeButton.frame = self.closeButton.showFrame;
    }
    if ([SKPhotoBrowserOptions sharedInstance].displayDeleteButton) {
        self.deleteButton.alpha = 1;
        self.deleteButton.frame = self.deleteButton.showFrame;
    }
}

- (nonnull UIImage *)getImageFromView: (nonnull UIView *)sender {
    UIGraphicsBeginImageContextWithOptions(sender.frame.size, YES, 0);
    [sender.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (nullable SKZoomingScrollView *)pageDisplayedAtIndex: (NSUInteger)index {
    return [self.pagingScrollView pageDisplayedAtIndex:index];
}

// MARK: - Notification
- (void)handleSKPhotoLoadingDidEndNotification: (NSNotification *)notification {
    id<SKPhotoProtocol> photo = [notification object];
    if (!photo) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        SKZoomingScrollView *page = [self.pagingScrollView pageDisplayingAtPhoto:photo];
        if (page) {
            id<SKPhotoProtocol> photo = page.photo;
            if (photo) {
                if (photo.underlyingImage) {
                    [page displayImage:YES];
                    [self loadAdjacentPhotosIfNecessary:photo];
                }else {
                    [page displayImageFailure];
                }
            }
        }
    });
}

- (void)loadAdjacentPhotosIfNecessary: (id<SKPhotoProtocol>) photo {
    [self.pagingScrollView loadAdjacentPhotosIfNecessary:photo currentPageIndex:self.currentPageIndex];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

///////////////////////////////////////////////////////////////////////////////////////////////
// MARK: -  UIScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.isViewActive && !self.isPerformingLayout) {
        
        [self.pagingScrollView tilePages];
        
        NSUInteger previousCurrentPage = self.currentPageIndex;
        CGRect visibleBounds = self.pagingScrollView.bounds;
        
        NSUInteger index = floorf(CGRectGetMidX(visibleBounds) / CGRectGetWidth(visibleBounds));
        self.currentPageIndex = MIN(MAX(index, 0), self.numberOfPhotos - 1);

        if (self.currentPageIndex != previousCurrentPage) {
            if ([self.delegate respondsToSelector:@selector(didShowPhotoAtIndex:)]) {
                [self.delegate didShowPhotoAtIndex:self.currentPageIndex];
            }
            
            [self.toolbar updateToolbar:self.currentPageIndex];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self hideControlsAfterDelay];
    
    NSUInteger currentIndex = self.pagingScrollView.contentOffset.x / CGRectGetWidth(self.pagingScrollView.frame);
    if ([self.delegate respondsToSelector:@selector(didScrollToIndex:)]) {
        [self.delegate didScrollToIndex:currentIndex];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    self.isEndAnimationByToolBar = YES;
}

@end
