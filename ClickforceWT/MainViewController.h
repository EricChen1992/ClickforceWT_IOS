//
//  MainViewController.h
//  ClickforceWT
//
//  Created by Eric Chen on 2020/8/20.
//  Copyright © 2020 Eric Chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>



@interface MainViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIButton *loginBtn;
@property (strong, nonatomic) IBOutlet UIButton *cancelBtn;
@property (strong, nonatomic) IBOutlet UITextField *userAccount;
@property (strong, nonatomic) IBOutlet UITextField *userPassword;

@end

