# Introduction
LCMosaicImageView is an image view which enables you to add mosaic effect on image or get mosaic copy of your image. You can use your finger to paint on the image, making partial mosaic effect on your touch area or directly call built-in API to get mosaic copy.

### Features:

- Paint on the image for partial mosaic effects.
- Built-in API to get a whole mosaic image.
- Easy to reset.
- You can set different mosaic level for different mosaic effects.
- Easy to use, both for iPhone and iPad.

# Overview

####Paint on the image

<img src="http://7xl7ci.com1.z0.glb.clouddn.com/lcmosaicview_paint.gif" alt="paint" title="paint" />

#### Reset to original status

<img src="http://7xl7ci.com1.z0.glb.clouddn.com/lcmosaicview_reset.gif" alt="reset" title="reset" />

#### Get a while mosaic image

<img src="http://7xl7ci.com1.z0.glb.clouddn.com/lcmosaicview_oneclick.gif" alt="oneclick" title="oneclick" />

#### Different mosaic level

<img src="http://7xl7ci.com1.z0.glb.clouddn.com/lcmosaicview_level.gif" alt="level" title="level" />

# Get Started

### Installation

You can either use Cocoapods, adding `pod 'LCMosaicImageView'` in your podfile, or directly add `LCMosaicImageView.h` and `LCMosaicImageView.m` to your project.

## Usage

- Import header file

		#import <LCMosaicImageView/LCMosaicImageView.h>

- Initialize `LCMosaicImageView`

		LCMosaicImageView *imageView = [[LCMosaicImageView alloc] initWithImage:YOUR_IMAGE];
		[self.view addSubview:imageView];

- (**optional**)Set mosaic level. If you don't do that, the level will be set to `LCMosaicLevelDefault`

		imageView.mosaicLevel = LCMosaicLevelHigh;

- (**optional**)Set delegate, you can set delegate to detect mosaic event.
	
		imageView.delegate = self;

- Reset imageView to its original status;

		[imageView reset];

- Get full mosaic image. You can achieve it by 2 instance methods and 2 class methods:

		- (UIImage *)mosaicImage;
		- (UIImage *)mosaicImageAtLevel:(LCMosaicLevel)level;
		+ (UIImage *)mosaicImage:(UIImage *)image;
		+ (UIImage *)mosaicImage:(UIImage *)image atLevel:(LCMosaicLevel)level;

# Requirement

- iOS 6.0+

# License

LCMosaicImageView is available under the MIT license. See the LICENSE file for more info.