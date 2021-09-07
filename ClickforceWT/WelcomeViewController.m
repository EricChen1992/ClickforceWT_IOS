//
//  StartViewController.m
//  ClickforceWT
//
//  Created by Eric Chen on 2020/8/19.
//  Copyright © 2020 Eric Chen. All rights reserved.
//

#import "WelcomeViewController.h"
#import "MainViewController.h"
#import "UIImage+mfanimatedGIF.h"
#import "DBSqliteHelper.h"


@interface WelcomeViewController (){
    DBSqliteHelper *db;
    NSString *vc;
}

@end

@implementation WelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    vc = @"mainViewController";
    db = [[DBSqliteHelper alloc] init];
    if([db openDB] && [db getUserInfo]) vc = @"workViewController";//判斷是否有資料
    
    
    NSString *gifPath = [[NSBundle mainBundle] pathForResource:@"clickforce_logo" ofType:@"gif"];
    NSData *gif = [NSData dataWithContentsOfFile:gifPath];
    
    _clickforceview.image = [UIImage mfanimatedImageWithAnimatedGIFData:gif];
    [db closeDB];//close DB
    [UIView animateWithDuration:3.2 animations:^{
//    [UIView animateWithDuration:0.2 animations:^{//debug
        _clickforceview.alpha = 0;
    } completion:^(BOOL finished) {
//        NSLog(@"Done.");
//        NSLog(@"navigationController=%@",self.navigationController);
        UIStoryboard *board = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        MainViewController *maincv = [board instantiateViewControllerWithIdentifier:vc];
        [self.navigationController pushViewController:maincv animated:NO];
    }];
    self.notification = [[Notification alloc] initWithAuthorization];
    [self.notification requestlocation];
}



@end
