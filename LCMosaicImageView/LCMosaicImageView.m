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


#pragma mark - initializer

- (instancetype)initWithImage:(UIImage *)image {
    self = [super initWithImage:image];
    if (self) {
        UIImage *imageNoRotate = [self removeRotationForImage:image];
        _originalImage = imageNoRotate;
        _mosaicLevel = LCMosaicLevelDefault;
        _strokeScale = LCStrokeScaleDefault;
        [self addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"frame"];
}

#pragma mark - api
#pragma mark - instance method

- (void)reset {
    self.image = self.originalImage;
}

- (UIImage *)mosaicImage {
    return (_mosaicImage) ? _mosaicImage : [self mosaicImageAtLevel:LCMosaicLevelDefault];
}

- (UIImage *)mosaicImageAtLevel:(LCMosaicLevel)level {
    self.mosaicLevel = level;
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([self.originalImage CGImage],
                            CGRectMake(0, 0,
                                self.originalImage.size.width * self.originalImage.scale, self.originalImage.size.height * self.originalImage.scale));
    UIImage * newImage = [UIImage imageWithCGImage:imageRef scale:1.0 orientation:self.image.imageOrientation];
    UIImage *mosaicImage = [self mosaicImage:newImage inLevel:level];
    CGImageRelease(imageRef);
    NSInteger ratio = [UIScreen mainScreen].scale / self.originalImage.scale;

    return [self imageWithImage:mosaicImage convertToSize:CGSizeMake(self.frame.size.width * ratio, self.frame.size.height * ratio)];
}

#pragma mark - class method

+ (UIImage *)mosaicImage:(UIImage *)image {
    return [LCMosaicImageView mosaicImage:image atLevel:LCMosaicLevelDefault];
}

+ (UIImage *)mosaicImage:(UIImage *)image atLevel:(LCMosaicLevel)level {
    LCMosaicImageView *imageView = [[LCMosaicImageView alloc] initWithImage:image];
    return [imageView mosaicImageAtLevel:level];
}

#pragma mark - event handler

- (void)handlePan:(UIPanGestureRecognizer *)pan {
    CGPoint point = [pan locationInView:self];
    if (pan.state == UIGestureRecognizerStateChanged) {
        [self mosaicImageInPoint:point];
    } else if (pan.state == UIGestureRecognizerStateEnded) {
        if ([self.delegate respondsToSelector:@selector(imageViewWillFinishMosaicImage:)]) {
            [self.delegate imageViewWillFinishMosaicImage:self];
        }
        [self saveImage];
        if ([self.delegate respondsToSelector:@selector(imageViewDidFinishMosaicImage:)]) {
            [self.delegate imageViewDidFinishMosaicImage:self];
        }
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    [self saveImage];
    if ([self.delegate respondsToSelector:@selector(imageViewWillMosaicImage:)]) {
        [self.delegate imageViewWillMosaicImage:self];
    }
    [self mosaicImageInPoint:point];
    if ([self.delegate respondsToSelector:@selector(imageViewDidMosaicImage:)]) {
        [self.delegate imageViewDidMosaicImage:self];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if ([self.delegate respondsToSelector:@selector(imageViewWillFinishMosaicImage:)]) {
        [self.delegate imageViewWillFinishMosaicImage:self];
    }
    [self saveImage];
    if ([self.delegate respondsToSelector:@selector(imageViewDidFinishMosaicImage:)]) {
        [self.delegate imageViewDidFinishMosaicImage:self];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"frame"]) {
        [self setup];
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
    CGFloat scalar = [UIScreen mainScreen].scale / self.originalImage.scale;
    CGRect clipArea = CGRectMake((point.x - (double)self.strokeScale / 2.0f) * scalar,
                                 (point.y - (double)self.strokeScale / 2.0f) * scalar,
                                 (double)self.strokeScale * scalar,
                                 (double)self.strokeScale * scalar);
    
    UIImage *clipImage = [UIImage imageWithCGImage:
                          CGImageCreateWithImageInRect([self.mosaicImage CGImage],clipArea)
                                    scale:self.originalImage.scale
                                    orientation:self.mosaicImage.imageOrientation];

    UIImageView *imageView = [[UIImageView alloc] initWithImage:clipImage];
    imageView.frame = CGRectMake(0, 0, (double)self.strokeScale, (double)self.strokeScale);
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

- (UIImage *)imageWithImage:(UIImage *)image convertToSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return destImage;
}

- (UIImage *)removeRotationForImage:(UIImage*)image {
    if (image.imageOrientation == UIImageOrientationUp) {
        return image;
    }
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    UIImage *imageNoRotation =  UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return imageNoRotation;
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

- (void)setImage:(UIImage *)image {
    UIImage *imageNoRotate = [self removeRotationForImage:image];
    [super setImage:imageNoRotate];
    _mosaicLevel = (_mosaicLevel != 0) ? _mosaicLevel : LCMosaicLevelDefault;
    _strokeScale = (_strokeScale != 0) ? _strokeScale : LCStrokeScaleDefault;
    _originalImage = (_originalImage) ? _originalImage : imageNoRotate;
}

- (UIPanGestureRecognizer *)pan {
    if (!_pan) {
        _pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    }
    return _pan;
}

@end
