//
//  ViewController.m
//  OpenCVDemo
//
//  Created by lihuaguang on 2020/7/30.
//  Copyright © 2020 lihuaguang. All rights reserved.
//

#import "ViewController.h"
#import "WDOCRResizingImageViewController.h"
#import "WDOpenCVEditingViewController.h"

@interface ViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, WDOpenCVEditingViewControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
}

- (IBAction)selectPhoto:(id)sender {
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self; //设置代理
    //    imagePickerController.allowsEditing = YES;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"defaultImageResizing"]) {
        if (![segue.destinationViewController isKindOfClass:[WDOCRResizingImageViewController class]]) {
            return;
        }
        
        UIImage *image = [UIImage imageNamed:@"5.png"];
        WDOCRResizingImageViewController *destVC = (WDOCRResizingImageViewController *)segue.destinationViewController;
        destVC.image = image;
    }
    
    if ([segue.identifier isEqualToString:@"toCrop"]) {
        if (![segue.destinationViewController isKindOfClass:[UINavigationController class]]) {
            return;
        }
        
        UIImage *image = [UIImage imageNamed:@"4.png"];
        UINavigationController *destVC = (UINavigationController *)segue.destinationViewController;
        WDOpenCVEditingViewController *editor = (WDOpenCVEditingViewController *)destVC.topViewController;
        editor.delegate = self;
        editor.originImage = image;
    }
    
}

#pragma mark imageDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^{
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage] ; //通过key值获取到图片
        WDOpenCVEditingViewController *editor = [[WDOpenCVEditingViewController alloc] init];
        editor.delegate = self;
        editor.originImage = image;
        editor.autoDectorCorner = YES;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:editor];
        nav.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:nav animated:YES completion:nil];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - WDOpenCVEditingViewControllerDelegate

- (void)editingController:(WDOpenCVEditingViewController *)editor didFinishCropping:(UIImage *)finalCropImage {
    UIImageView *imageView = (UIImageView *)[self.view viewWithTag:500];
    imageView.image = finalCropImage;
}

@end
