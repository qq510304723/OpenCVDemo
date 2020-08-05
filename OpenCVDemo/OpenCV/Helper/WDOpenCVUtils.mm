//
//  WDOpenCVUtils.m
//  OpenCVDemo
//
//  Created by lihuaguang on 2020/8/4.
//  Copyright © 2020 lihuaguang. All rights reserved.
//

// OpenCV的头文件应该在所有APPLE的头文件之前导入，不然会抛出异常，把OpenCV的头文件import调到最前面即可
// 加上#ifdef __cpluseplus来表示这是 C++ 文件才会编译的
#ifdef __cplusplus
#include <iostream>
#endif

#include <opencv2/opencv.hpp>
#include <opencv2/core/core.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/imgproc/types_c.h>
#include <opencv2/imgcodecs/ios.h>
#include <algorithm>

#import "WDOpenCVUtils.h"
#import "WDOpenCVDefines.h"

@implementation WDOpenCVUtils

using namespace std;
using namespace cv;

//取坐标交集
static inline cv::Point2f computeIntersect(cv::Vec4i a, cv::Vec4i b) {
    int x1 = a[0], y1 = a[1], x2 = a[2], y2 = a[3];
    int x3 = b[0], y3 = b[1], x4 = b[2], y4 = b[3];

    if (float d = ((float)(x1 - x2) * (y3 - y4)) - ((y1 - y2) * (x3 - x4)))
    {
        cv::Point2f pt;
        pt.x = ((x1*y2 - y1*x2) * (x3 - x4) - (x1 - x2) * (x3*y4 - y3*x4)) / d;
        pt.y = ((x1*y2 - y1*x2) * (y3 - y4) - (y1 - y2) * (x3*y4 - y3*x4)) / d;
        return pt;
    }
    else
        return cv::Point2f(-1, -1);
}

static inline bool IsBadLine(int a, int b) {
    if (a * a + b * b < 100) {
        return true;
    } else {
        return false;
    }
}

//确定四个点的中心线
static inline void sortCorners(std::vector<cv::Point2f>& corners,
    cv::Point2f center) {
    std::vector<cv::Point2f> top, bot;
    vector<Point2f> backup = corners;

    for (int i = 0; i < corners.size(); i++)
    {
        if (corners[i].y < center.y && top.size() < 2)    //这里的小于2是为了避免三个顶点都在top的情况
            top.push_back(corners[i]);
        else
            bot.push_back(corners[i]);
    }
    corners.clear();

    if (top.size() == 2 && bot.size() == 2)
    {
        cout << "log" << endl;
        cv::Point2f tl = top[0].x > top[1].x ? top[1] : top[0];
        cv::Point2f tr = top[0].x > top[1].x ? top[0] : top[1];
        cv::Point2f bl = bot[0].x > bot[1].x ? bot[1] : bot[0];
        cv::Point2f br = bot[0].x > bot[1].x ? bot[0] : bot[1];


        corners.push_back(tl);
        corners.push_back(tr);
        corners.push_back(br);
        corners.push_back(bl);
    }
    else
    {
        corners = backup;
    }
}

//计算最终图像的宽高
static inline cv::Size CalcDstSize(const vector<cv::Point2f>& corners) {
    cv::Size size;
    int h1 = sqrt((corners[0].x - corners[3].x)*(corners[0].x - corners[3].x) + (corners[0].y - corners[3].y)*(corners[0].y - corners[3].y));
    int h2 = sqrt((corners[1].x - corners[2].x)*(corners[1].x - corners[2].x) + (corners[1].y - corners[2].y)*(corners[1].y - corners[2].y));
    size.height = MAX(h1, h2);

    int w1 = sqrt((corners[0].x - corners[1].x)*(corners[0].x - corners[1].x) + (corners[0].y - corners[1].y)*(corners[0].y - corners[1].y));
    int w2 = sqrt((corners[2].x - corners[3].x)*(corners[2].x - corners[3].x) + (corners[2].y - corners[3].y)*(corners[2].y - corners[3].y));
    size.width = MAX(w1, w2);
    
    return size;
}

//找轮廓
static inline cv::Mat findContoursWithMat(cv::Mat img) {
    vector<vector<cv::Point> > contours;
    vector<vector<cv::Point> > f_contours;
    std::vector<cv::Point> approx2;
    
    // 找轮廓（注意第5个参数为CV_RETR_EXTERNAL，只检索外框）
    findContours(img, f_contours, CV_RETR_EXTERNAL, CV_CHAIN_APPROX_NONE);
    
    // 求出面积最大的轮廓
    int max_area = 0;
    int index = -1;
    for (int i = 0; i < f_contours.size(); i++) {
        double tmparea = fabs(contourArea(f_contours[i]));
        if (tmparea > max_area) {
            index = i;
            max_area = tmparea;
        }
    }
    if (index >= 0) {
        contours.push_back(f_contours[index]);
    }
    
    cv::Mat black;
    for (int line_type = 1; line_type <= 3; line_type++) {
        CVLogDebug(@"line_type: %d", line_type);
        black = img.clone();
        black.setTo(0);
        drawContours(black, contours, 0, Scalar(255), line_type);  //注意线的厚度，不要选择太细的
        break; // 如果不break，多次查找线会很粗
    }
    return black;
}

//找顶点
static inline void findVertexWithBlackMat(cv::Mat black, cv::Mat source, vector<cv::Point2f> &vertexes) {
    std::vector<Vec4i> lines;
    std::vector<cv::Point2f> corners;
    std::vector<cv::Point2f> approx;
    cv::Point2f center;
    
    int flag = 0;
    int round = 0;
    for (int para = 10; para < 300; para++) {
        CVLogDebug(@"round: %d", ++round);
        lines.clear();
        corners.clear();
        approx.clear();
        center = Point2f(0, 0);
        cv::HoughLinesP(black, lines, 1, CV_PI / 180, para, 30, 10);
        
        //过滤距离太近的直线
        std::set<int> ErasePt;
        for (int i = 0; i < lines.size(); i++) {
            for (int j = i + 1; j < lines.size(); j++) {
                if (IsBadLine(abs(lines[i][0] - lines[j][0]), abs(lines[i][1] - lines[j][1])) &&
                    IsBadLine(abs(lines[i][2] - lines[j][2]), abs(lines[i][3] - lines[j][3]))) {
                    ErasePt.insert(j); //将该坏线加入集合
                }
            }
        }
        
        int Num = (int)lines.size();
        while (Num != 0) {
            std::set<int>::iterator j = ErasePt.find(Num);
            if (j != ErasePt.end()) {
                lines.erase(lines.begin() + Num - 1);
            }
            Num--;
        }
        if (lines.size() != 4) {
            continue;
        }
        
        //计算直线的交点，保存在图像范围内的部分
        for (int i = 0; i < lines.size(); i++) {
            for (int j = i + 1; j < lines.size(); j++) {
                cv::Point2f pt = computeIntersect(lines[i], lines[j]);
                if (pt.x >= 0 && pt.y >= 0 && pt.x <= source.cols && pt.y <= source.rows) {
                    corners.push_back(pt); //保证交点在图像的范围之内
                }
            }
        }
        if (corners.size() != 4) {
            continue;
        }
        
        bool IsGoodPoints = true;
        
        //保证点与点的距离足够大以排除错误点
        for (int i = 0; i < corners.size(); i++) {
            for (int j = i + 1; j < corners.size(); j++) {
                int distance = sqrt((corners[i].x - corners[j].x)*(corners[i].x - corners[j].x) + (corners[i].y - corners[j].y)*(corners[i].y - corners[j].y));
                if (distance < 5) {
                    IsGoodPoints = false;
                }
            }
        }
        if (!IsGoodPoints) {
            continue;
        }
        
        cv::approxPolyDP(cv::Mat(corners), approx, cv::arcLength(cv::Mat(corners), true) * 0.02, true);
        
        if (lines.size() == 4 && corners.size() == 4 && approx.size() == 4) {
            flag = 1;
            break;
        }
    }
    
    // Get mass center
    for (int i = 0; i < corners.size(); i++) {
        center += corners[i];
    }
    center *= (1. / corners.size());

    if (flag) {
        CVLogDebug(@"corners size: %lu", corners.size());
        sortCorners(corners, center);
        
        for (int idx = 0; idx < corners.size(); idx++) {
            cv::Point2f pt = corners[idx];
            CVLogDebug(@"find corner: %f, %f", pt.x, pt.y);
        }
        
        vertexes = corners;
        
    } else {
        CVLogDebug(@"corner not find! ");
    }
}

//获取纠偏后的图像
static inline cv::Mat getCorrectQuadImageWithSourceMat(cv::Mat source, std::vector<cv::Point2f> corners) {
    cv::Size size = CalcDstSize(corners);
    cv::Mat quad = cv::Mat::zeros(size.height, size.width, CV_8UC3);
    std::vector<cv::Point2f> quad_pts;
    quad_pts.push_back(cv::Point2f(0, 0));
    quad_pts.push_back(cv::Point2f(quad.cols, 0));
    quad_pts.push_back(cv::Point2f(quad.cols, quad.rows));
    quad_pts.push_back(cv::Point2f(0, quad.rows));

    cv::Mat transmtx = cv::getPerspectiveTransform(corners, quad_pts);
    cv::warpPerspective(source, quad, transmtx, quad.size());

    /*如果需要二值化就解掉注释把*/
    /*
    Mat local,gray;
    cvtColor(quad, gray, CV_RGB2GRAY);
    int blockSize = 25;
    int constValue = 10;
    adaptiveThreshold(gray, local, 255, CV_ADAPTIVE_THRESH_MEAN_C, CV_THRESH_BINARY, blockSize, constValue);
    UIImage *grayImg = MatToUIImage(local);
    */
    
    return quad;
}

#pragma mark - Public

/**
 轮廓提取
 二值化+高斯滤波+膨胀+canny边缘提取
 参考：https://www.cnblogs.com/skyfsm/p/7324346.html
 githubb: https://github.com/AstarLight/my_scanner
 */
+ (UIImage *)getContoursWithImage:(UIImage *)image {
    if (!image) {
        CVLogDebug(@"image is nil");
        return nil;
    }
    
    cv::Mat cvImage;
    UIImageToMat(image, cvImage);
    
    if (cvImage.empty()) {
        CVLogDebug(@"cvImage is empty");
        return nil;
    }
    
    // 二值化
    cvtColor(cvImage, cvImage, CV_RGB2GRAY);
    
    // 高斯滤波
    GaussianBlur(cvImage, cvImage, cv::Size(5, 5), 0, 0);
    
    // 获取自定义核（第一个参数MORPH_RECT表示矩形的卷积核，当然还可以选择椭圆形的、交叉型的）
    cv::Mat element = getStructuringElement(MORPH_RECT, cv::Size(3, 3));
    
    // 膨胀操作（实现过程中发现，适当的膨胀很重要）
    dilate(cvImage, cvImage, element);
    
    // 边缘提取
    Canny(cvImage, cvImage, 30, 120, 3);
    
    UIImage *ret = MatToUIImage(cvImage);
    return ret;
}

/**
 二值化
 */
+ (UIImage *)RGB2GrayWithImage:(UIImage *)image {
    if (!image) {
        CVLogDebug(@"image is nil");
        return nil;
    }
    
    cv::Mat cvImage;
    UIImageToMat(image, cvImage);
    
    if (cvImage.empty()) {
        CVLogDebug(@"cvImage is empty");
        return nil;
    }
    
    cvtColor(cvImage, cvImage, CV_RGB2GRAY);
    UIImage *ret = MatToUIImage(cvImage);
    
    return ret;
}

/**
 高斯滤波
 */
+ (UIImage *)gaussianBlurWithImage:(UIImage *)image {
    if (!image) {
        CVLogDebug(@"image is nil");
        return nil;
    }
    
    cv::Mat cvImage;
    UIImageToMat(image, cvImage);
    
    if (cvImage.empty()) {
        CVLogDebug(@"cvImage is empty");
        return nil;
    }
    
    // 高斯滤波
    GaussianBlur(cvImage, cvImage, cv::Size(5, 5), 0, 0);
    
    UIImage *ret = MatToUIImage(cvImage);
    return ret;
}

/**
 膨胀操作
 */
+ (UIImage *)dilateWithImage:(UIImage *)image {
    if (!image) {
        CVLogDebug(@"image is nil");
        return nil;
    }
    
    cv::Mat cvImage;
    UIImageToMat(image, cvImage);
    
    if (cvImage.empty()) {
        CVLogDebug(@"cvImage is empty");
        return nil;
    }
    
    // 获取自定义核（第一个参数MORPH_RECT表示矩形的卷积核，当然还可以选择椭圆形的、交叉型的）
    cv::Mat element = getStructuringElement(MORPH_RECT, cv::Size(3, 3));
    
    // 膨胀操作（实现过程中发现，适当的膨胀很重要）
    dilate(cvImage, cvImage, element);
    
    UIImage *ret = MatToUIImage(cvImage);
    return ret;
}

/**
 边缘提取
 */
+ (UIImage *)cannyExtractionWithImage:(UIImage *)image {
    if (!image) {
        CVLogDebug(@"image is nil");
        return nil;
    }
    
    cv::Mat cvImage;
    UIImageToMat(image, cvImage);
    
    if (cvImage.empty()) {
        CVLogDebug(@"cvImage is empty");
        return nil;
    }
    
    // 边缘提取
    Canny(cvImage, cvImage, 30, 120, 3);
    
    UIImage *ret = MatToUIImage(cvImage);
    return ret;
}

/**
 轮廓查找并筛选
 */
+ (UIImage *)showContoursWithImage:(UIImage *)image {
    if (!image) {
        CVLogDebug(@"image is nil");
        return nil;
    }
    
    cv::Mat cvImage;
    UIImageToMat(image, cvImage);
    
    if (cvImage.empty()) {
        CVLogDebug(@"cvImage is empty");
        return nil;
    }
    
    cv::Mat black = findContoursWithMat(cvImage);
    
    UIImage *ret = MatToUIImage(black);
    return ret;
}

/**
 找四边形轮廓四个顶点
 */
+ (NSArray *)findContoursVertexWithBlackContourImage:(UIImage *)contourImage sourceImage:(UIImage *)sourceImage {
    if (!contourImage || !sourceImage) {
        CVLogDebug(@"image is nil");
        return nil;
    }
    
    cv::Mat black;
    UIImageToMat(contourImage, black);
    
    cv::Mat src;
    UIImageToMat(sourceImage, src);
    
    if (black.empty() || src.empty()) {
        CVLogDebug(@"cvImage is empty");
        return nil;
    }
    
    vector<cv::Point2f> corners;
    findVertexWithBlackMat(black, src, corners);
    
    NSMutableArray *vertexes = [NSMutableArray array];
    for (int i = 0; i < corners.size(); i++) {
        cv::Point2f pt = corners[i];
        CGPoint point = CGPointMake(pt.x, pt.y);
        [vertexes addObject:[NSValue valueWithCGPoint:point]];
    }
    return vertexes;
}

/**
 获取纠偏后的图像
 */
+ (UIImage *)getCorrectQuadImageWithImage:(UIImage *)image vertexes:(NSArray <NSValue*> *)vertexes {
    if (!image) {
        CVLogDebug(@"image is nil");
        return nil;
    }
    
    cv::Mat cvImage;
    UIImageToMat(image, cvImage);
    
    if (cvImage.empty()) {
        CVLogDebug(@"cvImage is empty");
        return image;
    }
    
    std::vector<cv::Point2f> corners;
    for (NSValue *value in vertexes) {
        CGPoint point = value.CGPointValue;
        cv::Point2f pt;
        pt.x = point.x;
        pt.y = point.y;
        corners.push_back(pt);
    }
    
    cv::Mat quad = getCorrectQuadImageWithSourceMat(cvImage, corners);
    UIImage *ret = MatToUIImage(quad);
    if (!ret) {
        ret = image;
    }
    return ret;
}

@end
