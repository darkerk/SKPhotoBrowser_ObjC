//
//  SKToolbar.m
//  PhotoBrowser
//
//  Created by wgh on 2017/8/1.
//  Copyright © 2017年 huoban. All rights reserved.
//

#import "SKToolbar.h"
#import "SKPhotoBrowser.h"
#import "SKPhotoBrowserOptions.h"

@interface SKToolbar ()

@property(nonatomic,strong)UILabel *toolCounterLabel;
@property(nonatomic,strong)UIBarButtonItem *toolCounterButton;
@property(nonatomic,strong)UIBarButtonItem *toolPreviousButton;
@property(nonatomic,strong)UIBarButtonItem *toolNextButton;

@property(nonatomic,weak)SKPhotoBrowser *browser;

@end

@implementation SKToolbar

- (NSBundle *)bundle {
    return [NSBundle bundleForClass:[SKPhotoBrowser class]];
}

- (instancetype)initWithFrame:(CGRect)frame browser:(SKPhotoBrowser *)browser
{
    self = [super initWithFrame:frame];
    if (self) {
        self.browser = browser;
        [self setupApperance];
        [self setupPreviousButton];
        [self setupNextButton];
        [self setupCounterLabel];
        [self setupActionButton];
        [self setupToolbar];
    }
    return self;
}

- (void)setupApperance {
    self.backgroundColor = [UIColor clearColor];
    self.clipsToBounds = YES;
    self.translucent = true;
    [self setBackgroundImage:[UIImage new] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    
    if (![SKPhotoBrowserOptions sharedInstance].displayToolbar) {
        self.hidden = YES;
    }
}

- (void)updateToolbar: (NSUInteger)currentPageIndex {
    if (!self.browser) {
        return;
    }
    
    if (self.browser.numberOfPhotos > 1) {
        self.toolCounterLabel.text = [NSString stringWithFormat:@"%@ / %@", @(currentPageIndex + 1), @(self.browser.numberOfPhotos)];
    }else {
        self.toolCounterLabel.text = nil;
    }
    
    self.toolPreviousButton.enabled = currentPageIndex > 0;
    self.toolNextButton.enabled = currentPageIndex < (self.browser.numberOfPhotos - 1);
}

- (void)setupToolbar {
    if (!self.browser) {
        return;
    }
    NSMutableArray<UIBarButtonItem *> *items = [NSMutableArray arrayWithCapacity:0];
    
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    [items addObject:flexSpace];
    if (self.browser.numberOfPhotos > 1 && [[SKPhotoBrowserOptions sharedInstance] displayBackAndForwardButton]) {
        [items addObject:self.toolPreviousButton];
    }
    if ([[SKPhotoBrowserOptions sharedInstance] displayCounterLabel]) {
        [items addObject:flexSpace];
        [items addObject:self.toolCounterButton];
        [items addObject:flexSpace];
    }else {
        [items addObject:flexSpace];
    }
    if (self.browser.numberOfPhotos > 1 && [[SKPhotoBrowserOptions sharedInstance] displayBackAndForwardButton]) {
        [items addObject:self.toolNextButton];
    }
    [items addObject:flexSpace];
    if ([[SKPhotoBrowserOptions sharedInstance] displayAction]) {
        [items addObject:self.toolActionButton];
    }
    
    [self setItems:items animated:NO];
}

- (void)setupPreviousButton {
    SKPreviousButton *previousBtn = [[SKPreviousButton alloc] init];
    [previousBtn addTarget:self.browser action:NSSelectorFromString(@"gotoPreviousPage") forControlEvents:UIControlEventTouchUpInside];
    self.toolPreviousButton = [[UIBarButtonItem alloc] initWithCustomView:previousBtn];
}

- (void)setupNextButton {
    SKNextButton *nextBtn = [[SKNextButton alloc] init];
    [nextBtn addTarget:self.browser action:NSSelectorFromString(@"gotoNextPage") forControlEvents:UIControlEventTouchUpInside];
    self.toolNextButton = [[UIBarButtonItem alloc] initWithCustomView:nextBtn];
}

- (void)setupCounterLabel {
    self.toolCounterLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 95, 40)];
    _toolCounterLabel.backgroundColor = [UIColor clearColor];
    _toolCounterLabel.textAlignment = NSTextAlignmentCenter;
    _toolCounterLabel.shadowColor = [UIColor blackColor];
    _toolCounterLabel.shadowOffset = CGSizeMake(0, 1);
    _toolCounterLabel.font = [SKToolbarOptions sharedInstance].font;
    _toolCounterLabel.textColor = [SKToolbarOptions sharedInstance].textColor;
    self.toolCounterButton = [[UIBarButtonItem alloc] initWithCustomView:_toolCounterLabel];
}

- (void)setupActionButton {
    self.toolActionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self.browser action:NSSelectorFromString(@"actionButtonPressed")];
    self.toolActionButton.tintColor = [UIColor whiteColor];
}

@end

///////////////////////////////////////////////////////////////////////////////////////////
@interface SKToolbarButton ()
@property(nonatomic,assign)UIEdgeInsets insets;
@end

@implementation SKToolbarButton

- (UIEdgeInsets)insets {
    return UIEdgeInsetsMake(13.25, 17.25, 13.25, 17.25);
}

- (NSBundle *)bundle {
    return [NSBundle bundleForClass:[SKPhotoBrowser class]];
}

- (void)setup: (NSString *)imageName {
    self.backgroundColor = [UIColor clearColor];
    self.imageEdgeInsets = self.insets;
    self.translatesAutoresizingMaskIntoConstraints = YES;
    self.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
    self.contentMode = UIViewContentModeCenter;
    
    UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"SKPhotoBrowser.bundle/images/%@", imageName] inBundle:[self bundle] compatibleWithTraitCollection:nil];
    [self setImage:image forState:UIControlStateNormal];
}

@end

///////////////////////////////////////////////////////////////////////////////////////////
@implementation SKPreviousButton

- (instancetype)init
{
    return [self initWithFrame:CGRectMake(0, 0, 44, 44)];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(0, 0, 44, 44)];
    if (self) {
        [self setup:@"btn_common_back_wh"];
    }
    return self;
}

@end

///////////////////////////////////////////////////////////////////////////////////////////
@implementation SKNextButton

- (instancetype)init
{
    return [self initWithFrame:CGRectMake(0, 0, 44, 44)];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(0, 0, 44, 44)];
    if (self) {
        [self setup:@"btn_common_forward_wh"];
    }
    return self;
}

@end
