//
//  InputText.m
//  ClickforceWT
//
//  Created by Eric Chen on 2020/8/21.
//  Copyright © 2020 Eric Chen. All rights reserved.
//

#import "InputText.h"
IBInspectable
@implementation InputText

- (void)drawRect:(CGRect)rect{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect inputFrame = self.bounds;
    CGContextSetLineWidth(context, _linewidth);
    CGRectInset(inputFrame, 5, 5);
    [_fillColor set];
    UIRectFrame(inputFrame);
}

- (void)setLeftView:(UIView *)leftView{
    
    UIImageView *leftImageView = [[UIImageView alloc] init];
    leftImageView.contentMode = UIViewContentModeScaleAspectFit;
    leftImageView.frame = CGRectMake(self.frame.size.height * 0.1, self.frame.size.height*0.1, self.frame.size.height*0.8, self.frame.size.height*0.8);
    self.leftView = leftImageView;
    self.leftViewMode = UITextFieldViewModeAlways;
}

//-(void) set{
//    leftImageView = [[UIImageView alloc] init];
//    leftImageView.contentMode = UIViewContentModeScaleAspectFit;
//    leftImageView.frame = CGRectMake(self.frame.size.height * 0.1, self.frame.size.height*0.1, self.frame.size.height*0.8, self.frame.size.height*0.8);
//    self.leftView = leftImageView;
//    self.leftViewMode = UITextFieldViewModeAlways;
//}
//
//-(UIImage *) get{
//    if (leftImageView == self.leftView){
//        return leftImageView.image;
//    }
//    return nil;
//}

@end
