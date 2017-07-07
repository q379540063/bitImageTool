//
//  ImageDealTool.h
//  位图图像原图修改
//
//  Created by 陈晓军 on 2017/7/6.
//  Copyright © 2017年 陈晓军. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^SuccessCallBack)(id info);

@interface ImageDealTool : NSObject

+(instancetype)shareTools;

-(void)dealImage:(UIImage *)inputImage withSuccess:(SuccessCallBack)callBack;

@end
