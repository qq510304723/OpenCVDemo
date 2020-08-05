//
//  OpenCVViewController.m
//  OpenCVDemo
//
//  Created by lihuaguang on 2020/7/31.
//  Copyright © 2020 lihuaguang. All rights reserved.
//

#import "OpenCVViewController.h"
#import "WDOpenCVUtils.h"
#import "Masonry.h"

@interface OpenCVViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) UIImage *originImage;
@property (copy, nonatomic) NSArray *vertexes;

@end

@implementation OpenCVViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    static int index = 1;
    if (index > 4) {
        index = 1;
    }
    self.originImage = [UIImage imageNamed:[NSString stringWithFormat:@"%d.png", index]];
    index++;

    self.imageView.userInteractionEnabled = YES;
    self.imageView.image = self.originImage;
    
    CGSize limitSize = CGSizeMake(self.view.bounds.size.width, 300);
    CGSize imageSize = self.originImage.size;
    CGFloat imageScale = fminf(limitSize.width/imageSize.width, limitSize.height/imageSize.height);
    CGSize scaledImageSize = CGSizeMake(imageSize.width*imageScale, imageSize.height*imageScale);
    CGRect imageFrame = CGRectMake(roundf(0.5f*(limitSize.width-scaledImageSize.width)), roundf(0.5f*(limitSize.height-scaledImageSize.height)), roundf(scaledImageSize.width), roundf(scaledImageSize.height));
    
    [self.imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.centerY.equalTo(self.view);
        make.size.mas_equalTo(imageFrame.size);
    }];
}

- (IBAction)buttonClicked:(id)sender {
    UIButton *btn = (UIButton *)sender;
    if (btn.tag == 201) {
        self.imageView.image = self.originImage;
        for (UIView *view in self.imageView.subviews) {
            [view removeFromSuperview];
        }
    }
    else if (btn.tag == 202) {
        UIImage *image = [WDOpenCVUtils RGB2GrayWithImage:self.imageView.image];
        if (image) {
            self.imageView.image = image;
        }
    }
    else if (btn.tag == 203) {
        UIImage *image = [WDOpenCVUtils gaussianBlurWithImage:self.imageView.image];
        if (image) {
            self.imageView.image = image;
        }
    }
    else if (btn.tag == 204) {
        UIImage *image = [WDOpenCVUtils dilateWithImage:self.imageView.image];
        if (image) {
            self.imageView.image = image;
        }
    }
    else if (btn.tag == 205) {
        UIImage *image = [WDOpenCVUtils cannyExtractionWithImage:self.imageView.image];
        if (image) {
            self.imageView.image = image;
        }
    }
    else if (btn.tag == 301) {
        UIImage *image = [WDOpenCVUtils showContoursWithImage:self.imageView.image];
        if (image) {
            self.imageView.image = image;
        }
    }
    else if (btn.tag == 302) {
        NSArray *vertexes = [WDOpenCVUtils findContoursVertexWithBlackContourImage:self.imageView.image sourceImage:self.originImage];
        self.imageView.image = self.originImage;
        NSLog(@"vertexes = %@", vertexes);
        
        if (vertexes.count == 4) {
            CGFloat size = 20;
            for (NSValue *value in vertexes) {
                CGPoint point = value.CGPointValue;
                
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                button.frame = (CGRect){point.x - size / 2, point.y - size / 2, size, size};
                button.layer.borderColor = [UIColor redColor].CGColor;
                button.layer.borderWidth = 1.0;
                button.layer.cornerRadius = size / 2;
                [self.imageView addSubview:button];
            }
        }
    }
    else if (btn.tag == 303) {
        UIImage *image = [WDOpenCVUtils getCorrectQuadImageWithImage:self.originImage vertexes:self.vertexes];
        if (image) {
            self.imageView.image = image;
        }
        for (UIView *view in self.imageView.subviews) {
            [view removeFromSuperview];
        }
    }
}


@end
