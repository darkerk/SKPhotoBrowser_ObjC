//
//  SKCaptionView.m
//  PhotoBrowser
//
//  Created by wgh on 2017/7/31.
//  Copyright © 2017年 huoban. All rights reserved.
//

#import "SKCaptionView.h"
#import "SKPhoto.h"
#import "SKPhotoBrowserOptions.h"

@interface SKCaptionView ()

@property(nonatomic,strong)id<SKPhotoProtocol> photo;
@property(nonatomic,strong)UILabel *photoLabel;
@property(nonatomic,assign)CGFloat photoLabelPadding;

@end

@implementation SKCaptionView

- (instancetype)initWithPhoto:(id<SKPhotoProtocol>)photo
{
    self = [super initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds))];
    if (self) {
        self.photo = photo;
        [self setup];
    }
    return self;
}

- (void)setup {
    self.opaque = NO;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
    
    self.photoLabelPadding = 10;
    
    self.photoLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.photoLabelPadding, 0, CGRectGetWidth(self.bounds) - (self.photoLabelPadding * 2), CGRectGetHeight(self.bounds))];
    _photoLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _photoLabel.opaque = NO;
    _photoLabel.backgroundColor = [UIColor clearColor];
    _photoLabel.textColor = [SKCaptionOptions sharedInstance].textColor;
    _photoLabel.textAlignment = [SKCaptionOptions sharedInstance].textAlignment;
    _photoLabel.lineBreakMode = [SKCaptionOptions sharedInstance].lineBreakMode;
    _photoLabel.font = [SKCaptionOptions sharedInstance].font;
    _photoLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.5];
    _photoLabel.shadowOffset = CGSizeMake(0, 1);
    _photoLabel.text = self.photo.caption;
    [self addSubview:_photoLabel];
}

- (CGSize)sizeThatFits:(CGSize)size {
    NSString *text = self.photoLabel.text;
    if (text && [text length] > 0) {
        UIFont *font = self.photoLabel.font;
        CGFloat width = size.width - self.photoLabelPadding * 2;
        CGFloat height = font.lineHeight * self.photoLabel.numberOfLines;
        
        NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName: font}];
        CGRect textRect = [attributedText boundingRectWithSize:CGSizeMake(width, height) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        return CGSizeMake(textRect.size.width, textRect.size.height + self.photoLabelPadding * 2);
    }
    return CGSizeZero;
}

@end
