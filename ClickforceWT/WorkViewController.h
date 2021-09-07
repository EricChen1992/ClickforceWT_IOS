//
//  WorkViewController.h
//  ClickforceWT
//
//  Created by Eric Chen on 2020/8/21.
//  Copyright © 2020 Eric Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WorkViewController : UIViewController
@property (strong, nonatomic) IBOutlet UILabel *textTypemode;
@property (strong, nonatomic) IBOutlet UILabel *textName;
@property (strong, nonatomic) IBOutlet UILabel *textDate;
@property (strong, nonatomic) IBOutlet UILabel *textTimeclockin;
@property (strong, nonatomic) IBOutlet UILabel *textTimeclockout;
@property (strong, nonatomic) IBOutlet UIImageView *typeView;
@property (strong, nonatomic) IBOutlet UIButton *actionButton;
@end

NS_ASSUME_NONNULL_END
