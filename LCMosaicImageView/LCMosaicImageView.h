//
//  LCMosaicImageView.h
//  LCMosaicImageView
//
//  Created by lazy on 15/10/23.
//  Copyright © 2015年 lazy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LCMosaicImageView;

typedef NS_ENUM(NSInteger, LCMosaicLevel) {
    LCMosaicLevelLow = 1,
    LCMosaicLevelMedium = 3,
    LCMosaicLevelDefault = 5,
    LCMosaicLevelHigh = 8,
    LCMosaicLevelVeryHigh = 10
};


@protocol LCMosaicImageViewDelegate <NSObject>

@optional

- (void)imageViewWillMosaicImage:(LCMosaicImageView *)imageView;
- (void)imageViewDidMosaicImage:(LCMosaicImageView *)imageView;
- (void)imageViewWillFinishMosaicImage:(LCMosaicImageView *)imageView;
- (void)imageViewDidFinishMosaicImage:(LCMosaicImageView *)imageView;

@end

@interface LCMosaicImageView : UIImageView

- (void)resetImage;

- (instancetype)initWithImage:(UIImage *)image;
- (instancetype)initWithMosaicableImage:(UIImage *)image;

@property (nonatomic, assign, getter=isMosaicEnabled) BOOL mosaicEnabled;
@property (nonatomic, assign) LCMosaicLevel mosaicLevel;

@property (nonatomic, weak) id<LCMosaicImageViewDelegate> delegate;

@end
