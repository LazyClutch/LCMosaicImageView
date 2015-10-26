//
//  LCMosaicImageView.m
//  LCMosaicImageView
//
//  Created by lazy on 15/10/23.
//  Copyright © 2015年 lazy. All rights reserved.
//

#import "LCMosaicImageView.h"

@interface LCMosaicImageView ()

@property (nonatomic, strong) UIImage *originalImage;
@property (nonatomic, strong) UIImage *compressedImage;
@property (nonatomic, strong) UIImage *mosaicImage;

@property (nonatomic, strong) UIPanGestureRecognizer *pan;

@end

@implementation LCMosaicImageView

static const CGFloat kDefaultMosaicUnitWidth = 24.0f;
static const CGFloat kDefaultMosaicUnitHeight = 24.0f;

#pragma mark - initializer

- (instancetype)initWithImage:(UIImage *)image {
    self = [super initWithImage:image];
    if (self) {
        _originalImage = image;
        _mosaicLevel = LCMosaicLevelDefault;
    }
    return self;
}

#pragma mark - api

- (void)resetImage {
    self.image = self.originalImage;
}

- (UIImage *)mosaicImageAtLevel:(LCMosaicLevel)level {
    self.mosaicLevel = level;
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([self.originalImage CGImage],
                            CGRectMake(0, 0,
                                self.originalImage.size.width, self.originalImage.size.height));
    UIImage * newImage = [UIImage imageWithCGImage:imageRef scale:1.0 orientation:self.image.imageOrientation];
    UIImage *mosaicImage = [self mosaicImage:newImage inLevel:level];
    CGImageRelease(imageRef);
    return mosaicImage;
}

#pragma mark - event handler

- (void)handlePan:(UIPanGestureRecognizer *)pan {
    CGPoint point = [pan locationInView:self];
    if (pan.state == UIGestureRecognizerStateBegan) {
        [self saveImage];
        if ([self.delegate respondsToSelector:@selector(imageViewWillMosaicImage:)]) {
            [self.delegate imageViewWillMosaicImage:self];
        }
        [self mosaicImageInPoint:point];
        if ([self.delegate respondsToSelector:@selector(imageViewDidMosaicImage:)]) {
            [self.delegate imageViewDidMosaicImage:self];
        }
    } else if (pan.state == UIGestureRecognizerStateChanged) {
        [self mosaicImageInPoint:point];
    } else {
        if ([self.delegate respondsToSelector:@selector(imageViewWillFinishMosaicImage:)]) {
            [self.delegate imageViewWillFinishMosaicImage:self];
        }
        [self saveImage];
        if ([self.delegate respondsToSelector:@selector(imageViewDidFinishMosaicImage:)]) {
            [self.delegate imageViewDidFinishMosaicImage:self];
        }
    }
}

#pragma mark - private

- (void)setup {
    self.compressedImage = [self captureScreen];
    self.mosaicImage = [self mosaicImageAtLevel:self.mosaicLevel];
}

- (void)saveImage {
    self.image = [self captureScreen];
}

- (UIImage *)captureScreen {
    UIImage* image = nil;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.frame.size.width, self.frame.size.height), self.opaque, 0.0);
    [self.layer renderInContext: UIGraphicsGetCurrentContext()];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    return image;
}

- (void)mosaicImageInPoint:(CGPoint)point {
    point = [self transformPoint:point];
    CGFloat scalar = [UIScreen mainScreen].scale;
    CGRect clipArea = CGRectMake((point.x - kDefaultMosaicUnitWidth / 2.0f) * scalar,
                                 (point.y - kDefaultMosaicUnitHeight / 2.0f) * scalar,
                                 kDefaultMosaicUnitWidth * scalar,
                                 kDefaultMosaicUnitHeight * scalar);
    
    UIImage *clipImage = [UIImage imageWithCGImage:
                          CGImageCreateWithImageInRect([self.mosaicImage CGImage],clipArea)
                                    scale:self.originalImage.scale
                                    orientation:self.mosaicImage.imageOrientation];

    UIImageView *imageView = [[UIImageView alloc] initWithImage:clipImage];
    imageView.frame = CGRectMake(0, 0, kDefaultMosaicUnitWidth, kDefaultMosaicUnitHeight);
    imageView.center = point;
    [self addSubview:imageView];
}

- (UIImage *)mosaicImage:(UIImage *)image inLevel:(LCMosaicLevel)level {
    CGImageRef imageRef = [image CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    NSUInteger maxOffset = height * width * 4;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    unsigned char *rawData = (unsigned char *) calloc(maxOffset, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height, bitsPerComponent, bytesPerRow, colorSpace, (CGBitmapInfo) (kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Big));
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    
    CGContextRelease(context);
    
    CGSize imageSize = image.size;
    UIGraphicsBeginImageContextWithOptions(imageSize, YES, 0);
    CGContextRef drawContext = UIGraphicsGetCurrentContext();
    
    for (int i = 0; i <= width / level; i++) {
        for (int j = 0; j <= height / level; j++) {
            NSInteger byteIndex = (bytesPerRow * j * level) + i * level * bytesPerPixel;
            if (byteIndex > maxOffset) continue;
            CGFloat red = (CGFloat) ((rawData[byteIndex + 1] * 1.0) / 255.0);
            CGFloat green = (CGFloat) ((rawData[byteIndex + 2] * 1.0) / 255.0);
            CGFloat blue = (CGFloat) ((rawData[byteIndex + 3] * 1.0) / 255.0);
            UIColor *aColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
            [self fillImage:image withColor:aColor inContext:drawContext atFrame:CGRectMake(i * level, j * level, level, level)];
        }
    }
    UIImage *mosaicedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    free(rawData);
    return mosaicedImage;
}

- (void)fillImage:(UIImage *)image withColor:(UIColor *)color inContext:(CGContextRef)context atFrame:(CGRect)frame {
    [color setFill];
    CGContextFillRect(context, frame);
}

- (CGPoint)transformPoint:(CGPoint)point {
    CGFloat x = (CGFloat)((NSInteger)point.x - (NSInteger)point.x % 2);
    CGFloat y = (CGFloat)((NSInteger)point.y - (NSInteger)point.y % 2);
    return CGPointMake(x, y);
}

#pragma mark - setter & getter

- (void)setMosaicEnabled:(BOOL)mosaicEnabled {
    _mosaicEnabled = mosaicEnabled;
    
    if (mosaicEnabled) {
        self.userInteractionEnabled = YES;
        [self addGestureRecognizer:self.pan];
        [self setup];
    } else {
        self.userInteractionEnabled = NO;
        [self removeGestureRecognizer:self.pan];
    }
}

- (UIPanGestureRecognizer *)pan {
    if (!_pan) {
        _pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    }
    return _pan;
}

@end
