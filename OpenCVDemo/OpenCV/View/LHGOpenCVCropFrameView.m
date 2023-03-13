//
//  LHGOpenCVCropFrameView.m
//  OpenCVDemo
//
//  Created by lihuaguang on 2020/8/4.
//  Copyright © 2020 lihuaguang. All rights reserved.
//

#import "LHGOpenCVCropFrameView.h"
#import "LHGOpenCVCropCornerView.h"

#define kCropButtonSize 20
#define kCropButtonMargin 40

@interface LHGOpenCVCropFrameView () <UIGestureRecognizerDelegate>

@property (nonatomic, strong, readwrite) LHGOpenCVCropCornerView *topLeftView;
@property (nonatomic, strong, readwrite) LHGOpenCVCropCornerView *topRightView;
@property (nonatomic, strong, readwrite) LHGOpenCVCropCornerView *bottomLeftView;
@property (nonatomic, strong, readwrite) LHGOpenCVCropCornerView *bottomRightView;
@property (nonatomic, weak) LHGOpenCVCropCornerView *activeCornerView;
@property (nonatomic, copy) NSArray <UIView*> *allCornerViews;

@end

@implementation LHGOpenCVCropFrameView
@synthesize lineSuccessColor = _lineSuccessColor;
@synthesize cornerFillColor = _cornerFillColor;

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = NO;
        self.userInteractionEnabled = YES;
        self.contentMode = UIViewContentModeRedraw;
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        
        UIPanGestureRecognizer *singlePan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(singlePan:)];
        singlePan.maximumNumberOfTouches = 1;
        singlePan.delegate = self;
        [self addGestureRecognizer:singlePan];
        
        for (UIView *cornerView in self.allCornerViews) {
            [self addSubview:cornerView];
        }
        [self resetDefaultPoints];
    }
    return self;
}

- (void)resetDefaultPoints {
    CGFloat offset = kCropButtonMargin;
    self.topLeftView.point = CGPointMake(offset, offset);
    self.topRightView.point = CGPointMake(self.bounds.size.width - offset, offset);
    self.bottomLeftView.point = CGPointMake(offset, self.bounds.size.height - offset);
    self.bottomRightView.point = CGPointMake(self.bounds.size.width - offset, self.bounds.size.height - offset);
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context) {
        CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
        self.isQuadEffective = ([self checkForNeighbouringPoints] >= 0);
        if (self.isQuadEffective) {
            CGContextSetStrokeColorWithColor(context, self.lineSuccessColor.CGColor);
        } else {
            CGContextSetStrokeColorWithColor(context, self.lineFailureColor.CGColor);
        }
        
        CGContextSetLineJoin(context, kCGLineJoinRound);
        CGContextSetLineWidth(context, 2.0f);
        
        CGRect boundingRect = CGContextGetClipBoundingBox(context);
        CGContextAddRect(context, boundingRect);
        CGContextFillRect(context, boundingRect);
        
        CGMutablePathRef pathRef = CGPathCreateMutable();
        
        CGPathMoveToPoint(pathRef, NULL, self.bottomLeftView.center.x, self.bottomLeftView.center.y);
        CGPathAddLineToPoint(pathRef, NULL, self.bottomRightView.center.x, self.bottomRightView.center.y);
        CGPathAddLineToPoint(pathRef, NULL, self.topRightView.center.x, self.topRightView.center.y);
        CGPathAddLineToPoint(pathRef, NULL, self.topLeftView.center.x, self.topLeftView.center.y);
        
        CGPathCloseSubpath(pathRef);
        CGContextAddPath(context, pathRef);
        CGContextStrokePath(context);
        
        CGContextSetBlendMode(context, kCGBlendModeClear);
        
        CGContextAddPath(context, pathRef);
        CGContextFillPath(context);
        
        CGContextSetBlendMode(context, kCGBlendModeNormal);
        
        CGPathRelease(pathRef);
    }
}

- (double)checkForNeighbouringPoints {
    CGPoint p1;
    CGPoint p2;
    CGPoint p3;
    for (LHGOpenCVCropCornerView *cornerView in self.allCornerViews) {
        switch (cornerView.cornerType) {
            case LHGOpenCVCornerTypeTopLeft:{
                p1 = self.topLeftView.point;
                p2 = self.topRightView.point;
                p3 = self.bottomLeftView.point;
                break;
            }
            case LHGOpenCVCornerTypeTopRight:{
                p1 = self.topRightView.point;
                p2 = self.bottomRightView.point;
                p3 = self.topLeftView.point;
                break;
            }
            case LHGOpenCVCornerTypeBottomRight:{
                p1 = self.bottomRightView.point;
                p2 = self.bottomLeftView.point;
                p3 = self.topRightView.point;
                break;
            }
            case LHGOpenCVCornerTypeBottomLeft:{
                p1 = self.bottomLeftView.point;
                p2 = self.topLeftView.point;
                p3 = self.bottomRightView.point;
                break;
            }
            default:{
                break;
            }
        }
        
        CGPoint ab = CGPointMake (p2.x - p1.x, p2.y - p1.y);
        CGPoint cb = CGPointMake( p2.x - p3.x, p2.y - p3.y);
        float dot = (ab.x * cb.x + ab.y * cb.y); // dot product
        float cross = (ab.x * cb.y - ab.y * cb.x); // cross product
        float alpha = atan2(cross, dot);
        
        if ((-1*(float) floor(alpha * 180. / 3.14 + 0.5)) < 0) {
            return -1*(float) floor(alpha * 180. / 3.14 + 0.5);
        }
    }
    return 0;
}

- (void)singlePan:(UIPanGestureRecognizer *)gesture {
    CGPoint location = [gesture locationInView:self];
    if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled) {
        self.activeCornerView.hidden = NO;
        self.activeCornerView = nil;
    }
    
    CGFloat newX = location.x;
    CGFloat newY = location.y;
    
    //cap off possible values
    if (newX < self.bounds.origin.x) {
        newX = self.bounds.origin.x;
    } else if (newX > self.frame.size.width) {
        newX = self.frame.size.width;
    }
    if (newY < self.bounds.origin.y) {
        newY = self.bounds.origin.y;
    } else if (newY > self.frame.size.height) {
        newY = self.frame.size.height;
    }
    location = CGPointMake(newX, newY);
    self.activeCornerView.point = location;
    [self setNeedsDisplay];
    
    if ([self.delegate respondsToSelector:@selector(cropFrameView:didMoveToPoint:state:)]) {
        [self.delegate cropFrameView:self didMoveToPoint:location state:gesture.state];
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    CGPoint location = [touch locationInView:self];
    for (LHGOpenCVCropCornerView *cornerView in self.allCornerViews) {
        CGPoint covertPoint = [self convertPoint:location toView:cornerView];
        if (CGRectContainsPoint(cornerView.bounds, covertPoint)) {
            self.activeCornerView = cornerView;
            self.activeCornerView.hidden = YES;
            break;
        }
    }
//    CVLogDebug(@"OpenCV Crop shouldReceiveTouch: %@, cornerView: %@", @(location), self.activeCornerView);
    return YES;
}

#pragma mark - Public

- (void)updatePointValue:(CGPoint)point cornerType:(LHGOpenCVCornerType)cornerType {
    switch (cornerType) {
        case LHGOpenCVCornerTypeTopLeft: {
            self.topLeftView.point = point;
            [self setNeedsDisplay];
            break;
        }
        case LHGOpenCVCornerTypeTopRight: {
            self.topRightView.point = point;
            [self setNeedsDisplay];
            break;
        }
        case LHGOpenCVCornerTypeBottomLeft: {
            self.bottomLeftView.point = point;
            [self setNeedsDisplay];
            break;
        }
        case LHGOpenCVCornerTypeBottomRight: {
            self.bottomRightView.point = point;
            [self setNeedsDisplay];
            break;
        }
        default: {
            break;
        }
    }
}

- (CGPoint)pointValueWithCornerType:(LHGOpenCVCornerType)cornerType {
    switch (cornerType) {
        case LHGOpenCVCornerTypeTopLeft: {
            return self.topLeftView.point;
        }
        case LHGOpenCVCornerTypeTopRight: {
            return self.topRightView.point;
        }
        case LHGOpenCVCornerTypeBottomLeft: {
            return self.bottomLeftView.point;
        }
        case LHGOpenCVCornerTypeBottomRight: {
            return self.bottomRightView.point;
        }
        default: {
            return self.center;;
        }
    }
}

#pragma mark - Setters

- (void)setlineSuccessColor:(UIColor *)lineSuccessColor {
    _lineSuccessColor = lineSuccessColor;
    self.topLeftView.layer.borderColor = lineSuccessColor.CGColor;
    self.topRightView.layer.borderColor = lineSuccessColor.CGColor;
    self.bottomLeftView.layer.borderColor = lineSuccessColor.CGColor;
    self.bottomRightView.layer.borderColor = lineSuccessColor.CGColor;
    [self setNeedsDisplay];
}

- (void)setCornerFillColor:(UIColor *)cornerFillColor {
    _cornerFillColor = cornerFillColor;
    self.topLeftView.layer.backgroundColor = cornerFillColor.CGColor;
    self.topRightView.layer.backgroundColor = cornerFillColor.CGColor;
    self.bottomLeftView.layer.backgroundColor = cornerFillColor.CGColor;
    self.bottomRightView.layer.backgroundColor = cornerFillColor.CGColor;
    [self setNeedsDisplay];
}

#pragma mark - Getters

- (LHGOpenCVCropCornerView *)topLeftView {
    if (!_topLeftView) {
        _topLeftView = [self cornerView];
        _topLeftView.cornerType = LHGOpenCVCornerTypeTopLeft;
    }
    return _topLeftView;
}

- (LHGOpenCVCropCornerView *)topRightView {
    if (!_topRightView) {
        _topRightView = [self cornerView];
        _topRightView.cornerType = LHGOpenCVCornerTypeTopRight;
    }
    return _topRightView;
}

- (LHGOpenCVCropCornerView *)bottomLeftView {
    if (!_bottomLeftView) {
        _bottomLeftView = [self cornerView];
        _bottomLeftView.cornerType = LHGOpenCVCornerTypeBottomLeft;
    }
    return _bottomLeftView;
}

- (LHGOpenCVCropCornerView *)bottomRightView {
    if (!_bottomRightView) {
        _bottomRightView = [self cornerView];
        _bottomRightView.cornerType = LHGOpenCVCornerTypeBottomRight;
    }
    return _bottomRightView;
}

- (LHGOpenCVCropCornerView *)cornerView {
    LHGOpenCVCropCornerView *cornerView = [[LHGOpenCVCropCornerView alloc] init];
    cornerView.frame = CGRectMake(0, 0, kCropButtonSize, kCropButtonSize);
//    cornerView.alpha = 0.5;
    cornerView.layer.backgroundColor = self.cornerFillColor.CGColor;
    cornerView.layer.cornerRadius = kCropButtonSize/2;
    cornerView.layer.borderWidth = 1.0;
    cornerView.layer.borderColor = self.lineSuccessColor.CGColor;
    cornerView.layer.masksToBounds = YES;
    return cornerView;
}

- (NSArray<UIView *> *)allCornerViews {
    if (!_allCornerViews) {
        _allCornerViews = @[self.topLeftView, self.topRightView, self.bottomRightView, self.bottomLeftView];
    }
    return _allCornerViews;
}

- (UIColor *)cornerFillColor {
    if (!_cornerFillColor) {
        _cornerFillColor = [UIColor whiteColor];
    }
    return _cornerFillColor;
}

- (UIColor *)lineSuccessColor {
    if (!_lineSuccessColor) {
        _lineSuccessColor = [UIColor blueColor];
    }
    return _lineSuccessColor;
}

- (UIColor *)lineFailureColor {
    if (!_lineFailureColor) {
        _lineFailureColor = [UIColor redColor];
    }
    return _lineFailureColor;
}

@end
