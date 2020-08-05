//
//  WDOpenCVDefines.h
//  OpenCVDemo
//
//  Created by lihuaguang on 2020/8/4.
//  Copyright © 2020 lihuaguang. All rights reserved.
//

#ifndef WDOpenCVDefines_h
#define WDOpenCVDefines_h

#import <Foundation/Foundation.h>

#ifdef DEBUG
#define CVLogDebug(args, ...) NSLog(args, ##__VA_ARGS__)
#else
#define CVLogDebug(args, ...)
#endif

typedef NS_ENUM(NSUInteger, WDOpenCVCornerType) {
    WDOpenCVCornerTypeTopLeft       = 1,
    WDOpenCVCornerTypeTopRight      = 2,
    WDOpenCVCornerTypeBottomLeft    = 3,
    WDOpenCVCornerTypeBottomRight   = 4,
};

#endif /* WDOpenCVDefines_h */
