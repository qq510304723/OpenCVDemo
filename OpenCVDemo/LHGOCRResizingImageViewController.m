//
//  LHGOCRResizingImageViewController.m
//  OpenCVDemo
//
//  Created by lihuaguang on 2020/8/3.
//  Copyright © 2020 lihuaguang. All rights reserved.
//

#import "LHGOCRResizingImageViewController.h"
#import "LHGOCRResizingImageView.h"
#import "Masonry.h"

@interface LHGOCRResizingImageViewController ()

@property (nonatomic, strong) LHGOCRResizingImageView *imageView;
@property (nonatomic, assign) BOOL needLayout;

@end

@implementation LHGOCRResizingImageViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.needLayout = YES;
    }
    return self;
}

- (instancetype)init {
    return [self initWithImage:nil];
}

- (instancetype)initWithImage:(UIImage *)image {
    self = [super init];
    if (self) {
        self.image = image;
    }
    return self;
}

- (void)setImage:(UIImage *)image {
    _image = image;
    self.imageView.originImage = image;
    self.needLayout = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor blackColor];
    
    [self.view addSubview:self.imageView];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if (self.needLayout) {
        self.needLayout = NO;
        self.imageView.quadVertexes = [self calculateQuadVertexesWithImage:self.image];
    }
}

- (NSArray *)calculateQuadVertexesWithImage:(UIImage *)image {
    CGSize imageSize = image.size;
    if (imageSize.width <= 0 || imageSize.height <= 0) {
        return nil;
    }
    
    // 获取默认四个顶点
    NSArray *vertexes = @[
        [NSValue valueWithCGPoint:CGPointMake(0, 0)],
        [NSValue valueWithCGPoint:CGPointMake(0, imageSize.height)],
        [NSValue valueWithCGPoint:CGPointMake(imageSize.width, imageSize.height)],
        [NSValue valueWithCGPoint:CGPointMake(imageSize.width, 0)],
    ];
    return vertexes;
}

#pragma mark - Getters

- (LHGOCRResizingImageView *)imageView {
    if (!_imageView) {
        _imageView = [[LHGOCRResizingImageView alloc] init];
    }
    return _imageView;
}

@end
