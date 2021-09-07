//
//  Historytableview.m
//  ClickforceWT
//
//  Created by Eric Chen on 2020/8/31.
//  Copyright © 2020 Eric Chen. All rights reserved.
//

#import "Historytableview.h"
#import "ParsJson.h"

@interface Historytableview()<UITableViewDataSource,UITableViewDelegate>{
    UIView *background;
    UIButton *closeBtn;
    UIImageView *image;
    ParsJson *parsJson;
    
    NSArray *dataItem;
}
@end

@implementation Historytableview

- (instancetype)init
{
    self = [super init];
    if (self) {
        background = [[UIView alloc] init];
    }
    return self;
}

- (void)setContentValue:(NSData *)jData setController:(UIViewController *)view{
    parsJson = [[ParsJson alloc] initWithValue:jData];
    dataItem = [parsJson item];
    if ([parsJson result] == 1 && dataItem.count != 0) {
        CGFloat superViewW = view.view.frame.size.width;
            CGFloat superViewH = view.view.frame.size.height;
            CGFloat toolBarH = [UIApplication sharedApplication].statusBarFrame.size.height;
            
            //set Background
        //    background.frame = CGRectMake(superViewW / 2 - (superViewW - 20) / 2, superViewH / 2 + toolBarH - (superViewH - 40) / 2, superViewW - 20, superViewH - 40);
            background.frame = CGRectMake(0, 0, superViewW, superViewH);
            [background setBackgroundColor:[UIColor grayColor]];
            background.alpha = 0.75;
            background.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            
            //set Background Imageview
            image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"activity_history_black"]];
            image.frame = CGRectMake(superViewW / 2 - (superViewW - 20) / 2, superViewH / 2 + toolBarH - (superViewH - 40) / 2, superViewW - 20, superViewH - 40 - toolBarH * 2);
            image.userInteractionEnabled = YES;
            
            [view.view addSubview:background];
            [image bringSubviewToFront:background];
            [view.view addSubview:image];
            
            //set History Tittle
            UILabel *historyTittle = [[UILabel alloc] initWithFrame:CGRectMake(7.5, 10, image.frame.size.width - 15, 30)];
            [historyTittle setText:@"HISTORY"];
            [historyTittle setTextAlignment:NSTextAlignmentCenter];
            [historyTittle setTextColor:[UIColor redColor]];
            [image addSubview:historyTittle];
            
            //set Name and ID Container
            UIStackView *nameAndIdcontainer = [[UIStackView alloc] initWithFrame:CGRectMake(historyTittle.frame.origin.x + 5,
                                                                                            historyTittle.frame.origin.y + historyTittle.frame.size.height,
                                                                                            historyTittle.frame.size.width - 10,
                                                                                            30)];
            nameAndIdcontainer.alignment = UIStackViewAlignmentFill;
            nameAndIdcontainer.distribution = UIStackViewDistributionFillEqually;
            
            //set Name
            UILabel *uname = [[UILabel alloc] init];
            [uname setText:[NSString stringWithFormat:@"姓名: %@", [[parsJson item][0] objectForKey:@"name"] ]];
            [uname setTextAlignment:NSTextAlignmentCenter];
            [uname setBackgroundColor:[UIColor whiteColor]];
            [uname setFont:[UIFont boldSystemFontOfSize:20]];
            
            //set ID
            UILabel *uid = [[UILabel alloc] init];
            [uid setText:[NSString stringWithFormat:@"ID: %@", [[parsJson item][0] objectForKey:@"cua_id"]]];
            [uid setTextAlignment:NSTextAlignmentCenter];
            [uid setTextColor:[UIColor redColor]];
            [uid setBackgroundColor:[UIColor whiteColor]];
            [uid setFont:[UIFont boldSystemFontOfSize:20]];
            
            [nameAndIdcontainer addArrangedSubview:uname];
            [nameAndIdcontainer addArrangedSubview:uid];
            [image addSubview:nameAndIdcontainer];
            
            UITableView *allDataList = [[UITableView alloc] initWithFrame:CGRectMake(nameAndIdcontainer.frame.origin.x + 2.5,
                                                                                     nameAndIdcontainer.frame.origin.y + nameAndIdcontainer.frame.size.height + 5,
                                                                                     nameAndIdcontainer.frame.size.width - 5,
                                                                                     image.frame.size.height - (nameAndIdcontainer.frame.origin.y + nameAndIdcontainer.frame.size.height) - 45)];
            
           
            [allDataList setBackgroundColor:[UIColor whiteColor]];
            [image addSubview:allDataList];
            allDataList.delegate = self;
            allDataList.dataSource = self;
            
            //Close Button
            closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(image.frame.size.width-50, -10, 50, 50)];
            [image addSubview:closeBtn];
            [closeBtn setBackgroundImage:[UIImage imageNamed:@"closebutton"] forState:UIControlStateNormal];
            [closeBtn addTarget:self action:@selector(removeHistoryView:) forControlEvents: UIControlEventTouchUpInside];
            closeBtn.userInteractionEnabled = YES;
    } else {
        
        [self showToast:@"No Data." setVC:view];
        
    }
    
}

- (void)removeHistoryView:(UIButton *)sender {
//    NSLog(@"%s",__PRETTY_FUNCTION__);
    if(background != nil) [background removeFromSuperview];
    if(image != nil) [image removeFromSuperview];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dataItem.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"Cell2"];
    
    int result = [parsJson result];
    if (result == 1) {
        NSDictionary *mdic = [parsJson item][indexPath.row];
        ParsJson *tempParsJson = [[ParsJson alloc] initWithNSDictionary:mdic];
        
//        NSLog(@"date: %@, clockIn: %@, clockOut: %@", [tempParsJson date], [tempParsJson clockin], [tempParsJson clockout]);
        
        //最外的框
        UIStackView *container = [[UIStackView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 50)];
        container.axis = UILayoutConstraintAxisVertical;
        container.alignment = UIStackViewAlignmentFill;
        container.distribution = UIStackViewDistributionFillEqually;
        
        //顯示日期
        UILabel *date = [[UILabel alloc] init];
        [date setText:[tempParsJson date]];
        [date setFont:[UIFont boldSystemFontOfSize:20]];
        [date setTextColor:[UIColor blackColor]];
        [date setBackgroundColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:211/255.0 alpha:1]];

        [container addArrangedSubview:date];
        
        //上班時間的外框
        UIStackView *workIn = [[UIStackView alloc] init];
        workIn.alignment = UIStackViewAlignmentCenter;
        workIn.distribution = UIStackViewDistributionFillEqually;
        
        UILabel *workinTittle = [[UILabel alloc] init];
        [workinTittle setText:@"上班:"];
        [workinTittle setTextAlignment:NSTextAlignmentLeft];
        [workinTittle setTextColor:[UIColor colorWithRed:191/255.0 green:13/255.0 blue:13/255.0 alpha:1]];
        [workinTittle setBackgroundColor:[UIColor whiteColor]];
        
        UILabel *workinTime = [[UILabel alloc] init];
        [workinTime setText:[tempParsJson clockin]];
        [workinTime setTextAlignment:NSTextAlignmentLeft];
        [workinTime setTextColor:[UIColor blackColor]];
        [workinTime setBackgroundColor:[UIColor whiteColor]];
        
        [workIn addArrangedSubview:workinTittle];
        [workIn addArrangedSubview:workinTime];
        
        //下班時間的外誆
        UIStackView *workOut = [[UIStackView alloc] init];
        workOut.alignment = UIStackViewAlignmentCenter;
        workOut.distribution = UIStackViewDistributionFillEqually;
        
        UILabel *workoutTittle = [[UILabel alloc] init];
        [workoutTittle setText:@"下班:"];
        [workoutTittle setTextAlignment:NSTextAlignmentLeft];
        [workoutTittle setTextColor:[UIColor colorWithRed:0/255.0 green:133/255.0 blue:119/255.0 alpha:1]];
        [workoutTittle setBackgroundColor:[UIColor whiteColor]];
        
        UILabel *workoutTime = [[UILabel alloc] init];
        [workoutTime setText:[tempParsJson clockout]];
        [workoutTime setTextAlignment:NSTextAlignmentLeft];
        [workoutTime setTextColor:[UIColor blackColor]];
        [workoutTime setBackgroundColor:[UIColor whiteColor]];
        
        [workOut addArrangedSubview:workoutTittle];
        [workOut addArrangedSubview:workoutTime];
        
        //上班及下班時間包起來的外框
        UIStackView *workInAndworkOut = [[UIStackView alloc] init];
        workInAndworkOut.alignment = UIStackViewAlignmentLeading;
        workInAndworkOut.distribution = UIStackViewDistributionFillEqually;
        
        [workInAndworkOut addArrangedSubview:workIn];
        [workInAndworkOut addArrangedSubview:workOut];
        
        [container addArrangedSubview:workInAndworkOut];
        
        [cell.contentView setBackgroundColor:[UIColor whiteColor]];
        [cell.contentView addSubview: container];
    
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

//顯示提示訊息
- (void) showToast:(NSString *) msg setVC:(UIViewController *)v{
    UILabel *showLable = [[UILabel alloc] initWithFrame:CGRectMake(v.view.frame.size.width/2 - 100, v.view.frame.size.height-100, 200, 35)];
    showLable.text = msg;
    showLable.backgroundColor = [UIColor whiteColor];
    [showLable setTextAlignment:NSTextAlignmentCenter];
    showLable.layer.cornerRadius = 10;
    showLable.layer.borderWidth = 2;
    showLable.layer.borderColor = [UIColor redColor].CGColor;
    showLable.clipsToBounds = YES;
    [v.view addSubview:showLable];
    [UIView animateWithDuration: 5.0 delay: 0.1 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        showLable.alpha = 0.0;
    } completion:^(BOOL finished) {
        [showLable removeFromSuperview];
    }];
}


@end
