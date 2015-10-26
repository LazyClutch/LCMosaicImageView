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
    LCMosaicLevelLow = 3,
    LCMosaicLevelMedium = 7,
    LCMosaicLevelDefault = 10,
    LCMosaicLevelHigh = 15,
    LCMosaicLevelVeryHigh = 20
};


@protocol LCMosaicImageViewDelegate <NSObject>

@optional

- (void)imageViewWillMosaicImage:(LCMosaicImageView *)imageView;
- (void)imageViewDidMosaicImage:(LCMosaicImageView *)imageView;
- (void)imageViewWillFinishMosaicImage:(LCMosaicImageView *)imageView;
- (void)imageViewDidFinishMosaicImage:(LCMosaicImageView *)imageView;

@end

@interface LCMosaicImageView : UIImageView

- (instancetype)initWithImage:(UIImage *)image;

- (void)reset;

- (UIImage *)mosaicImage;
- (UIImage *)mosaicImageAtLevel:(LCMosaicLevel)level;

+ (UIImage *)mosaicImage:(UIImage *)image;
+ (UIImage *)mosaicImage:(UIImage *)image atLevel:(LCMosaicLevel)level;

@property (nonatomic, assign, getter=isMosaicEnabled) BOOL mosaicEnabled;
@property (nonatomic, assign) LCMosaicLevel mosaicLevel;

@property (nonatomic, weak) id<LCMosaicImageViewDelegate> delegate;

@end
