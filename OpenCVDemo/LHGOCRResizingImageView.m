//
//  LHGOCRResizingImageView.m
//  OpenCVDemo
//
//  Created by lihuaguang on 2020/8/3.
//  Copyright © 2020 lihuaguang. All rights reserved.
//

#import "LHGOCRResizingImageView.h"
#import "Masonry.h"

static CGFloat kLHGOCRResizingImageMargin = 10.0;

@interface LHGOCRResizingImageView ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

@end

@implementation LHGOCRResizingImageView

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        [self addGestureRecognizer:self.panGesture];
        
        [self addSubview:self.imageView];
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.equalTo(self).offset(kLHGOCRResizingImageMargin);
            make.bottom.right.equalTo(self).offset(-kLHGOCRResizingImageMargin);
        }];
    }
    return self;
}

- (void)updateConstraints {
    [super updateConstraints];
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

#pragma mark - Setters

- (void)setOriginImage:(UIImage *)originImage {
    _originImage = originImage;
    self.imageView.image = originImage;
}

- (void)setQuadVertexes:(NSArray<NSValue *> *)quadVertexes {
    if (quadVertexes.count != 4) {
        return;
    }
    _quadVertexes = quadVertexes;
    
    // 计算图片填充区域大小（图片可能太大或或者太小）
    CGSize imageSize = self.originImage.size;
    CGSize limitSize = CGSizeMake(CGRectGetWidth(self.bounds) - kLHGOCRResizingImageMargin * 2,
                                  CGRectGetHeight(self.bounds) - kLHGOCRResizingImageMargin * 2);
    CGFloat imageScale = fminf(limitSize.width / imageSize.width,
                               limitSize.height / imageSize.height);
    CGSize scaledSize = CGSizeMake(roundf(imageSize.width * imageScale),
                                   roundf(imageSize.height * imageScale));
    CGPoint scaledOrigin = CGPointMake(roundf((limitSize.width - scaledSize.width) / 2),
                                      roundf((limitSize.height - scaledSize.height) / 2));
    
    CGFloat size = 20;
    for (NSValue *value in quadVertexes) {
        CGPoint point = value.CGPointValue;
        point.x *= imageScale;
        point.y *= imageScale;
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = (CGRect){point.x - size / 2 + scaledOrigin.x, point.y - size / 2 + scaledOrigin.y, size, size};
        button.layer.borderColor = [UIColor redColor].CGColor;
        button.layer.borderWidth = 1.0;
        button.layer.cornerRadius = size / 2;
        [self.imageView addSubview:button];
    }
}

- (void)pan:(UIPanGestureRecognizer *)ges {
    
}

#pragma mark - Getters

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imageView;
}

- (UIPanGestureRecognizer *)panGesture {
    if (!_panGesture) {
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    }
    return _panGesture;
}

@end
