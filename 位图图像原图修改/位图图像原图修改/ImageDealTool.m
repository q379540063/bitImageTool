//
//  ImageDealTool.m
//  位图图像原图修改
//
//  Created by 陈晓军 on 2017/7/6.
//  Copyright © 2017年 陈晓军. All rights reserved.
//

// 启发文章地址   https://www.raywenderlich.com/69855/image-processing-in-ios-part-1-raw-bitmap-modification

#import "ImageDealTool.h"

static ImageDealTool * tool;

@interface ImageDealTool()

@property(nonatomic,copy) SuccessCallBack callBack;

@end

@implementation UIImage(ToolImage)

- (UIImage *)imageWithFixedOrientation {
    if (self.imageOrientation == UIImageOrientationUp) return self;
    
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    [self drawInRect:(CGRect){0, 0, self.size}];
    UIImage *normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return normalizedImage;
}


@end

@implementation ImageDealTool

+(instancetype)shareTools{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tool = [[self alloc]init];
    });
    return tool;
}

-(void)dealImage:(UIImage *)inputImage withSuccess:(SuccessCallBack)callBack{
    if (!inputImage) {
        return;
    }
    inputImage = [inputImage imageWithFixedOrientation];
    self.callBack = callBack;
    [self dealImage:inputImage];
}

#pragma mark - Private

#define Mask8(x) ( (x) & 0xFF )
#define R(x) ( Mask8(x) )
#define G(x) ( Mask8(x >> 8 ) )
#define B(x) ( Mask8(x >> 16) )
#define A(x) ( Mask8(x >> 24) )
#define RGBAMake(r, g, b, a) ( Mask8(r) | Mask8(g) << 8 | Mask8(b) << 16 | Mask8(a) << 24 )

-(void)dealImage:(UIImage *)inputImage{
    UInt32 * inputPixels;
    CGImageRef inputCGImg = [inputImage CGImage];
    NSUInteger inputWidth = CGImageGetWidth(inputCGImg);
    NSUInteger inputHeight = CGImageGetHeight(inputCGImg);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    NSUInteger bytesPerPixel = 4;
    NSUInteger bitsPerCompent = 8; //通道长度
    NSUInteger inputBytesPerRow = bytesPerPixel * inputWidth;
    
    inputPixels = calloc(inputWidth * inputHeight, sizeof(UInt32));
    
    CGContextRef context = CGBitmapContextCreate(inputPixels, inputWidth, inputHeight, bitsPerCompent, inputBytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGContextDrawImage(context, CGRectMake(0, 0, inputWidth, inputHeight), inputCGImg);
    
    UIImage * ghostimage = [UIImage imageNamed:@"ghost.png"];
    CGImageRef ghostCGimage = [ghostimage CGImage];
    
    CGFloat ghostImageAspectRatio = ghostimage.size.width / ghostimage.size.height;
    
    NSInteger targetGhostWidth = inputWidth * 0.25;
    
    CGSize ghostSize = CGSizeMake(targetGhostWidth, targetGhostWidth/ghostImageAspectRatio);
    
    CGPoint ghostOrign =  CGPointMake(inputWidth * 0.7, inputHeight * 0.4);
    
    
    UInt32 * ghostPixels = (UInt32 *)calloc(ghostSize.width * ghostSize.height,sizeof(UInt32));
    
    CGContextRef ghostContext = CGBitmapContextCreate(ghostPixels, ghostSize.width, ghostSize.height, bitsPerCompent, bytesPerPixel * ghostSize.width, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGContextDrawImage(ghostContext, CGRectMake(0, 0, ghostSize.width, ghostSize.height), ghostCGimage);
    //第一个ghost 的数组位置
    NSUInteger offsetPixelCountForInput = ghostOrign.y * inputWidth + ghostOrign.x;
    
    for(NSInteger j =0;j<ghostSize.height ;j++){
        for (NSUInteger i =0 ; i<ghostSize.width; i++) {
            
            UInt32 * inputPixel = inputPixels + j * inputWidth + i + offsetPixelCountForInput;
            //input中 ghost 的坐标的像素点
            UInt32 inputColor = * inputPixel;
            
            UInt32 * ghostPixel = ghostPixels + j *(int)ghostSize.width +i;
            //ghost 中的像素点
            UInt32 ghostColor = * ghostPixel;
            CGFloat ghostAlpha = 1.0f * (A(ghostColor)/255.0);
            UInt32 newR = R(inputColor) * (1 - ghostAlpha) + R(ghostColor) * ghostAlpha;
            UInt32 newG = G(inputColor) * (1 - ghostAlpha) + R(ghostColor) * ghostAlpha;
            UInt32 newB = B(inputColor) * (1 - ghostAlpha) + B(ghostColor) * ghostAlpha;
            newR = MAX(0,MIN(255, newR));
            newG = MAX(0,MIN(255, newG));
            newB = MAX(0,MIN(255, newB));
            *inputPixel = RGBAMake(newR, newG, newB, A(inputColor));
            
        }
    }
    
    for(NSUInteger j=0;j<inputHeight;j++){
        for(NSUInteger i =0;i<inputWidth;i++){
            UInt32 * currentPixel = inputPixels + j* inputWidth + i;
            UInt32 color = * currentPixel;
            UInt32 averageColor = (R(color) + G(color) +B(color))/3.0;
            * currentPixel = RGBAMake(averageColor, averageColor, averageColor, A(color));
        }
        
        
    }
    
    CGImageRef newCGImage = CGBitmapContextCreateImage(context);
    UIImage * toolImg = [UIImage imageWithCGImage:newCGImage];
    if (toolImg && self.callBack) {
        self.callBack(toolImg);
    }
}
@end
