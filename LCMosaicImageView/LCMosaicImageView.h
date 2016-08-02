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

typedef NS_ENUM(NSInteger, LCStrokeScale) {
    LCStrokeScaleTiny = 8,
    LCStrokeScaleSmall = 14,
    LCStrokeScaleMedium = 20,
    LCStrokeScaleDefault = 25,
    LCStrokeScaleLarge = 32,
    LCStrokeScaleVeryLarge = 40
};

@protocol LCMosaicImageViewDelegate <NSObject>

@optional

/**
 *  This method will be called before the very beginning of each paint event.
 *
 *  @param imageView current image view
 */
- (void)imageViewWillMosaicImage:(LCMosaicImageView *)imageView;

/**
 *  This method will be called after the very beginning of each paint event.
 *
 *  @param imageView current image view
 */
- (void)imageViewDidMosaicImage:(LCMosaicImageView *)imageView;

/**
 *  This method will be called before the very last of each paint event.
 *
 *  @param imageView current image view
 */
- (void)imageViewWillFinishMosaicImage:(LCMosaicImageView *)imageView;

/**
 *  This method will be called after the very last of each paint event.
 *
 *  @param imageView current image view
 */
- (void)imageViewDidFinishMosaicImage:(LCMosaicImageView *)imageView;

@end


@interface LCMosaicImageView : UIImageView

- (instancetype)initWithImage:(UIImage *)image;

/**
 *  Use this method to reset to the very initial status of image view.
 */
- (void)reset;

/**
 *  Instance method to get a whole mosaic image. The LCMosaicLevel will be set to LCMosaicLevelDefault.
 *
 *  @return An instance of UIImage
 */
- (UIImage *)mosaicImage;

/**
 *  Instance method to get a whole mosaic image.
 *
 *  @param level LCMosaicLevel
 *
 *  @return An instance of UIImage
 */
- (UIImage *)mosaicImageAtLevel:(LCMosaicLevel)level;

/**
 *  Class method to get a whole mosaic image. The LCMosaicLevel will be set to LCMosaicLevelDefault.
 *
 *  @return An instance of UIImage
 */
+ (UIImage *)mosaicImage:(UIImage *)image;

/**
 *  Class method to get a whole mosaic image at certain mosaic level.
 *
 *  @param level LCMosaicLevel
 *
 *  @return An instance of UIImage
 */
+ (UIImage *)mosaicImage:(UIImage *)image atLevel:(LCMosaicLevel)level;

/**
 *  Use this method to control whether the image view is ready for paint event.
 */
@property (nonatomic, assign, getter=isMosaicEnabled) BOOL mosaicEnabled;

/**
 *  You can refer to the project page https://github.com/LazyClutch/LCMosaicImageView to see different kind of mosaic effect. A more mosaic level means that the image will get more blurred.
 */
@property (nonatomic, assign) LCMosaicLevel mosaicLevel;

/**
 *  You can refer to the project page to see different kind of stroke scale effect. A more stroke effect means that you will get a larger area for one stroke.
 */
@property (nonatomic, assign) LCStrokeScale strokeScale;

@property (nonatomic, weak) id<LCMosaicImageViewDelegate> delegate;

@end
