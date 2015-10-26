//
//  ViewController.m
//  LCMosaicImageView
//
//  Created by lazy on 15/10/23.
//  Copyright © 2015年 lazy. All rights reserved.
//

#import "ViewController.h"
#import "LCMosaicImageView.h"

@interface ViewController () <LCMosaicImageViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *resetButton;
@property (weak, nonatomic) IBOutlet UIButton *mosaicButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *oneClickButton;

@property (nonatomic, strong) LCMosaicImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.resetButton.hidden = YES;
    self.saveButton.hidden = YES;
    
    [self.view addSubview:self.imageView];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - event handler

- (IBAction)reset:(id)sender {
    [self.imageView resetImage];
    self.resetButton.hidden = YES;
    self.oneClickButton.hidden = NO;
}

- (IBAction)mosaic:(id)sender {
    self.mosaicButton.hidden = YES;
    self.resetButton.hidden = YES;
    self.saveButton.hidden = NO;
    self.oneClickButton.hidden = YES;
    
    self.imageView.mosaicEnabled = YES;
}

- (IBAction)save:(id)sender {
    self.saveButton.hidden = YES;
    self.resetButton.hidden = YES;
    self.mosaicButton.hidden = NO;
    self.oneClickButton.hidden = NO;
    
    self.imageView.mosaicEnabled = NO;
    
    UIImageWriteToSavedPhotosAlbum(self.imageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (IBAction)oneClick:(id)sender {
    self.mosaicButton.hidden = YES;
    self.oneClickButton.hidden = YES;
    self.resetButton.hidden = NO;
    self.saveButton.hidden = NO;
    
    self.imageView.mosaicEnabled = YES;

    UIImage *image = [self.imageView mosaicImageAtLevel:LCMosaicLevelVeryHigh];
    self.imageView.image = image;
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"Fail to save image. Please check again!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Image is successfully saved to album" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
}

#pragma mark - LCMosaicImageView Delegate

- (void)imageViewDidMosaicImage:(LCMosaicImageView *)imageView {
    self.mosaicButton.hidden = YES;
    self.resetButton.hidden = NO;
    self.saveButton.hidden = NO;
}

#pragma mark - getter

- (LCMosaicImageView *)imageView {
    if (!_imageView) {
        _imageView = [[LCMosaicImageView alloc] initWithImage:[UIImage imageNamed:@"sample"]];
        _imageView.center = self.view.center;
        _imageView.mosaicLevel = LCMosaicLevelLow;
        _imageView.delegate = self;
    }
    return _imageView;
}

@end
