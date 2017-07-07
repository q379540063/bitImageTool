//
//  ViewController.m
//  位图图像原图修改
//
//  Created by 陈晓军 on 2017/7/6.
//  Copyright © 2017年 陈晓军. All rights reserved.
//

#import "ViewController.h"
#import "ImageDealTool.h"
@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *backImageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImage * image =[UIImage imageNamed:@"back.jpg"];
    
    [[ImageDealTool shareTools] dealImage:image withSuccess:^(id info) {
        if (![info isKindOfClass:[UIImage class]]) {
            return ;
        }
        UIImage * outPutImage = (UIImage *)info;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.backImageView.image = outPutImage;
        });
    }];
}


@end
