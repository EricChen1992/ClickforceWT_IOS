//
//  WorkViewController.m
//  ClickforceWT
//
//  Created by Eric Chen on 2020/8/21.
//  Copyright © 2020 Eric Chen. All rights reserved.
//

#import "WorkViewController.h"
#import "DBSqliteHelper.h"
#import "ConnectPost.h"
#import "ParsJson.h"
#import "Historytableview.h"
#import "PromptView.h"
#import "EventKit/EventKit.h"
#import "EventKit/EKAlarm.h"
#import "Notification.h"

@interface WorkViewController ()<ConnectPostDelegate, PromptViewDelegate>{
    ConnectPost *post;
    DBSqliteHelper *workDB;
    NSDictionary *userInfo;
    PromptView *promt;
    int clicknb;
    NSArray *workOutString;
    NSString *workOutMsg;
}

@end

@implementation WorkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    workDB = [[DBSqliteHelper alloc] init];
    post = [[ConnectPost alloc] init];
    post.delegate = self;
    clicknb = 0;
    [self setRandomWorkOutMsg];
    _actionButton.userInteractionEnabled = NO;
    if ([workDB openDB]){
        userInfo = [workDB getUserData];
        if (userInfo != nil) {
            NSString *status = [workDB getUserStatusType];
            if (status != nil) {
                
                ParsJson *par = [[ParsJson alloc] initWithValue:[status dataUsingEncoding:NSUTF8StringEncoding]];
                if ([[par date] isEqualToString:[self getDate]]) {//判斷手機時間是否跟DB一致，不一致刪除DB資料
                    
//                    [self setLableView:[status dataUsingEncoding:NSUTF8StringEncoding] checkInsert:0];//不儲存DB
                    [self setLableViewForParsJson:par data:[status dataUsingEncoding:NSUTF8StringEncoding] checkInsert:0];
                    
                } else {
                    
                    [workDB delUserStatus];//刪除裡面資料
                    //getUserStatus 到後端拿資料
                    [self postValue:@{@"cua_id" : [userInfo valueForKey:@"userId"], @"cua_name" : [userInfo valueForKey:@"userName"]} setParameter:post.WorkCheckStatus];
                }
                
            } else {
                //getUserStatus 到後端拿資料
                [self postValue:@{@"cua_id" : [userInfo valueForKey:@"userId"], @"cua_name" : [userInfo valueForKey:@"userName"]} setParameter:post.WorkCheckStatus];
            }
            
            [self setLableText:_textName setText:[userInfo valueForKey:@"userName"]];
        }
    }
}

- (void) setLableText:(UILabel *)view setText:(NSString *) username {
    view.text = username;
}

- (IBAction)showHistory:(id)sender {
    if ([workDB openDB]){
        userInfo = [workDB getUserData];
        if (userInfo != nil) {
            post.postParams = [NSJSONSerialization dataWithJSONObject:@{@"cua_id" : [userInfo valueForKey:@"userId"], @"cua_name" : [userInfo valueForKey:@"userName"]} options:NSJSONWritingPrettyPrinted error:nil];
            [post excute:[NSString stringWithFormat:@"%@%@", post.WorkUrl, post.WorkAlldate] postBlockData:^(NSData * _Nullable data) {
                if (data != NULL) {
//                    NSLog(@"result = %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        Historytableview *historyview = [[Historytableview alloc] init];
                        [historyview setContentValue:data setController:self];
                        [self.view addSubview:historyview];
                    });
                }
            }];
        }
    }
//    [self notification];
}

- (IBAction)clickAction:(id)sender {
    ParsJson *parsjson = [[ParsJson alloc] initWithValue:[[workDB getUserStatusType] dataUsingEncoding:NSUTF8StringEncoding]];
    userInfo = [workDB getUserData];
    if (userInfo != nil) {
        if ([parsjson result] == 0 && [[parsjson type] isEqualToString:@""] && [[parsjson clockin] isEqualToString:@""]) {//上班
            
            NSLog(@"type: %@, clockin: %@, clockout: %@",[parsjson type], [parsjson clockin], [parsjson clockout]);
            NSDictionary *dic = @{@"cua_id" : [userInfo valueForKey:@"userId"], @"name" : [userInfo valueForKey:@"userName"], @"type" : @"1" };
            [self postValue:dic setParameter:post.WorkIn];
            
        } else if ([parsjson result] == 1 && [[parsjson type] isEqualToString:@"1"] && ![[parsjson clockin] isEqualToString:@""]){//下班
            [self showDoubleConfirmDialog:[parsjson clockin]];
//            if([self showDoubleConfirmDialog:[parsjson clockin]]){
//                NSLog(@"type: %@, clockin: %@, clockout: %@",[parsjson type], [parsjson clockin], [parsjson clockout]);
//                NSDictionary *dic = @{@"cua_id" : [userInfo valueForKey:@"userId"], @"name" : [userInfo valueForKey:@"userName"], @"type" : @"0" };
//                [self postValue:dic setParameter:post.WorkOut];
//            }
            
            
        } else if ([parsjson result] == 1 && [[parsjson type] isEqualToString:@"0"] && ![[parsjson clockin] isEqualToString:@""] && ![[parsjson clockout] isEqualToString:@""]){//下班後再點擊
            clicknb++;
            if(clicknb == 10) {
                NSLog(@"點夠了嗎?已經下班了");
                [self showToast:@"點夠了嗎?已經下班了"];
                clicknb = 0;
            }
        }
    }
    
}

//Check User Status
- (void) postValue:(NSDictionary *) dict setParameter:(NSString *) parameter{
    post.postParams = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    [post excute:[NSString stringWithFormat:@"%@%@", post.WorkUrl, parameter] postBlockData:^(NSData * _Nullable data) {
        if (data != NULL) {
            NSLog(@"result = %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            dispatch_async(dispatch_get_main_queue(), ^{
                ParsJson *parsjson = [[ParsJson alloc] initWithValue:data];
//                [self setLableView:data checkInsert:1];
                [self setLableViewForParsJson:parsjson data:data checkInsert:1];
            });
        }
    }];
}

//判斷及顯示上班日期、時間、圖示
- (void) setLableViewForParsJson:(ParsJson *)pJsonData data:(NSData *)data checkInsert:(int) check{
    if ([pJsonData result] == 1) {
        
        if ([[pJsonData type] isEqualToString:@"1"]) {
            
            if (check == 1) [workDB insertUserStatusType:[pJsonData type] date:[pJsonData date] timeIn:[pJsonData clockin] timeOut:[pJsonData clockout] response:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
            [self setLableText:_textTypemode setText:@"上班..."];
            [self setLableText:_textDate setText:[pJsonData date]];
            [self setLableText:_textTimeclockin setText:[pJsonData clockin]];
            if (check == 1) [self setWorkOutAlarm:[pJsonData clockin] setToday:[pJsonData date]];//加入行事曆
            _typeView.hidden = NO;
            [_typeView setImage:[UIImage imageNamed:@"activity_bottom3"]];
            
        } else if([[pJsonData type] isEqualToString:@"0"]){
            
            if (check == 1) [workDB insertUserStatusType:[pJsonData type] date:[pJsonData date] timeIn:[pJsonData clockin] timeOut:[pJsonData clockout] response:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
            [self setLableText:_textTypemode setText:@"下班..."];
            [self setLableText:_textDate setText:[pJsonData date]];
            [self setLableText:_textTimeclockin setText:[pJsonData clockin]];
            [self setLableText:_textTimeclockout setText:[pJsonData clockout]];
            _typeView.hidden = NO;
            [_typeView setImage:[UIImage imageNamed:@"activity_bottom7"]];
        }
        
    } else {
        
        if (check == 1) [workDB insertUserStatusType:[pJsonData type] date:[pJsonData date] timeIn:[pJsonData clockin] timeOut:[pJsonData clockout] response:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
        [self setLableText:_textTypemode setText:@"尚未打卡"];
        [self setLableText:_textDate setText:[pJsonData date]];
    }
    if (![[_textDate text] isEqualToString:@""]) {
        _actionButton.userInteractionEnabled = YES;
    }
}

//- (void) setLableView:(NSData *)data checkInsert:(int) check{
//    ParsJson *parsjson = [[ParsJson alloc] initWithValue:data];
//    if ([parsjson result] == 1) {
//
//        if ([[parsjson type] isEqualToString:@"1"]) {
//
//            if (check == 1) [workDB insertUserStatusType:[parsjson type] date:[parsjson date] timeIn:[parsjson clockin] timeOut:[parsjson clockout] response:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
//            [self setLableText:_textTypemode setText:@"上班..."];
//            [self setLableText:_textDate setText:[parsjson date]];
//            [self setLableText:_textTimeclockin setText:[parsjson clockin]];
//            _typeView.hidden = NO;
//            [_typeView setImage:[UIImage imageNamed:@"activity_bottom3"]];
//        } else if([[parsjson type] isEqualToString:@"0"]){
//
//            if (check == 1) [workDB insertUserStatusType:[parsjson type] date:[parsjson date] timeIn:[parsjson clockin] timeOut:[parsjson clockout] response:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
//            [self setLableText:_textTypemode setText:@"下班..."];
//            [self setLableText:_textDate setText:[parsjson date]];
//            [self setLableText:_textTimeclockin setText:[parsjson clockin]];
//            [self setLableText:_textTimeclockout setText:[parsjson clockout]];
//            _typeView.hidden = NO;
//            [_typeView setImage:[UIImage imageNamed:@"activity_bottom7"]];
//        }
//
//    } else {
//
//        if (check == 1) [workDB insertUserStatusType:[parsjson type] date:[parsjson date] timeIn:[parsjson clockin] timeOut:[parsjson clockout] response:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
//        [self setLableText:_textTypemode setText:@"尚未打卡"];
//        [self setLableText:_textDate setText:[parsjson date]];
//    }
//
//}

//顯示提示訊息
- (void) showToast:(NSString *) msg {
    UILabel *showLable = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 100, self.view.frame.size.height-100, 200, 35)];
    showLable.text = msg;
    [showLable setTextColor:[UIColor blackColor]];
    showLable.backgroundColor = [UIColor whiteColor];
    [showLable setTextAlignment:NSTextAlignmentCenter];
    showLable.layer.cornerRadius = 10;
    showLable.layer.borderWidth = 1;
    showLable.layer.borderColor = [UIColor redColor].CGColor;
    showLable.clipsToBounds = YES;
    [self.view addSubview:showLable];
    [UIView animateWithDuration: 5.0 delay: 0.1 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        showLable.alpha = 0.0;
    } completion:^(BOOL finished) {
        [showLable removeFromSuperview];
    }];
}

//抓取現在手機時間
-(NSString *) getDate{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_Hant_TW"]];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Taipei"]];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    // Date to string
    NSDate *now = [NSDate date];
    NSString *currentDateString = [formatter stringFromDate:now];
//    NSLog(@"currentDate=%@", currentDateString);
    return currentDateString;
}

-(void) showDoubleConfirmDialog:(NSString *) clockTime {
    promt = [[PromptView alloc] init];//顯示提示view
    promt.delegate = self;
    [promt setMsgText:[self compareDate:clockTime] seOnView:self];
    [self.view addSubview:promt];
}

- (void)onConfirm{
    ParsJson *parsjson = [[ParsJson alloc] initWithValue:[[workDB getUserStatusType] dataUsingEncoding:NSUTF8StringEncoding]];
//    NSLog(@"type: %@, clockin: %@, clockout: %@",[parsjson type], [parsjson clockin], [parsjson clockout]);
    NSDictionary *dic = @{@"cua_id" : [userInfo valueForKey:@"userId"], @"name" : [userInfo valueForKey:@"userName"], @"type" : @"0" };
    [self postValue:dic setParameter:post.WorkOut];

    // set tomorrow workIn time notification
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    [self setNotificationForWorkIn:[dateFormatter dateFromString:[parsjson date]]];
}

- (void)onCancel{
    if (promt != nil) {
        [promt removePrompt];
    }
}

- (NSString *) compareDate:(NSString *)dbClockInTime{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_Hant_TW"]];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Taipei"]];
    [formatter setDateFormat:@"HH:mm:ss"];
    // Date to string
    NSDate *now = [NSDate date];
    NSString *currentTimeString = [formatter stringFromDate:now];
//    NSLog(@"%@ ,%@", dbClockInTime,currentTimeString);
    
    NSArray *db_clock_in = [dbClockInTime componentsSeparatedByString:@":"];
    NSArray *current_time = [currentTimeString componentsSeparatedByString:@":"];
    
    int canClockOutH = [db_clock_in[0] intValue] + 9;
    int canClockOutM = [db_clock_in[1] intValue] + 30;
    
    if (canClockOutM >= 60) {
        canClockOutM = canClockOutM - 60;
        canClockOutH = canClockOutH + 1;
    }
    
    //將分鐘調整 個位數顯示前面加 0
    NSString *tempM;
    if (canClockOutM < 10) {
        tempM = [NSString stringWithFormat:@"%@%d",@"0",canClockOutM];
    } else {
        tempM =  [NSString stringWithFormat:@"%d", canClockOutM];
    }
    
    if ([current_time[0] intValue] > canClockOutH || (canClockOutH == [current_time[0] intValue] && [current_time[1] intValue] > canClockOutM) || canClockOutH > 19) {
        return @"確定要下班了嗎?";
    } else {
        return [NSString stringWithFormat:@"您確定要下班了嗎？\n您下班時間為 %d:%@ 唷", canClockOutH, tempM];
    }
    
    return @"";
}

-(void) setWorkOutAlarm:(NSString *)dbClockInTime setToday:(NSString *) today{
    EKEventStore *eventStore = [[EKEventStore alloc]init];
    if([eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)]) {
        //iOS 6 and later
        [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if (granted){

            //for IOS> 6.0
            EKEvent *event = [EKEvent eventWithEventStore:eventStore];
            [event setCalendar:[eventStore defaultCalendarForNewEvents]];

            //no need to fill all fill which one u want to set
            NSDate *setworkdate = [self setWorkOutDate:dbClockInTime today:today];
            [self setNotificationForWorkOut:[[NSCalendar currentCalendar] components:NSCalendarUnitWeekday | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear  | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:setworkdate]];
            event.startDate = setworkdate;//set date
            event.endDate = setworkdate;
            
            event.title =[NSString stringWithFormat:@"ClickForce-%@-下班",today];
//            event.location = @"eventLocation";
            if (nil != workOutMsg) {
                event.notes = workOutMsg;//行事曆內容
            } else {
                event.notes = @"現在可以下班摟，快跑啊～";//行事曆內容
            }
           
            // event.URL = [NSURL URLWithString:@"url"];
            
            //加入提示
            EKAlarm *alaram = [[EKAlarm alloc]init];
            [alaram setAbsoluteDate:event.startDate];
            [event addAlarm:alaram];

            //for alert set the aleram and notify the user rest is taken care by calendar for u

//            switch (evetReminder) {//set alaram for 5mins, 15mins, 20mins etc
//                case 0:
//                    selectedAlertSetting = @"None";
//                    break;
//
//                case 1:
//                {
//                    EKAlarm *alaram = [[EKAlarm alloc]init];
//                    [alaram setAbsoluteDate:event.startDate];
//                    [event addAlarm:alaram];
////                    [alaram release];
//                    break;
//                }
//                case 2:
//                {
//                    NSTimeInterval aInterval = -5 *60;
//                    EKAlarm *alaram = [EKAlarm alarmWithRelativeOffset:aInterval];
//                    [event addAlarm:alaram];
//                    break;
//                }
//                case 3:
//                {
//                    NSTimeInterval aInterval = -15 * 60;
//                    EKAlarm *alaram = [EKAlarm alarmWithRelativeOffset:aInterval];
//                    [event addAlarm:alaram];
//                    break;
//                }
//
//                default:
//                    break;
//            }

            //finally add it to calendar
            NSError *err = nil;
            BOOL complete = [eventStore saveEvent:event span:EKSpanThisEvent error:&err];
            if(err)
            {
                NSLog(@"error in storing event");
            }
            else
            {
                NSLog(@"successfully added");
            }
                
            if(complete)
            {
                NSLog(@"successfully added");
            }
            else
            {
                NSLog(@"error in storing event");
            }

//            [eventStore release];

        }

        }];

    }
    else
    {
        //for IOS <6.0
        //perform same action hear
        EKEvent *event = [EKEvent eventWithEventStore:eventStore];
        [event setCalendar:[eventStore defaultCalendarForNewEvents]];

        //no need to fill all fill which one u want to set
        NSDate *setworkdate = [self setWorkOutDate:dbClockInTime today:today];
        event.startDate = setworkdate;//set date
        event.endDate = setworkdate;
        
        event.title =[NSString stringWithFormat:@"ClickForce-%@-下班",today];
//            event.location = @"eventLocation";
        
        event.notes = @"現在可以下班摟，快跑啊～";//行事曆內容
//        event.URL = [NSURL URLWithString:@"url"];

        EKAlarm *alaram = [[EKAlarm alloc]init];
        [alaram setAbsoluteDate:event.startDate];
        [event addAlarm:alaram];

        //for alert set the aleram and notify the user rest is taken care by calendar for u

//        switch (evetReminder) {//set alaram for 5mins, 15mins, 20mins etc
//            case 0:
//                selectedAlertSetting = @"None";
//                break;
//
//            case 1:
//            {
//                EKAlarm *alaram = [[EKAlarm alloc]init];
//                [alaram setAbsoluteDate:event.startDate];
//                [event addAlarm:alaram];
////                [alaram release];
//                break;
//            }
//            case 2:
//            {
//                NSTimeInterval aInterval = -5 *60;
//                EKAlarm *alaram = [EKAlarm alarmWithRelativeOffset:aInterval];
//                [event addAlarm:alaram];
//                break;
//            }
//            case 3:
//            {
//                NSTimeInterval aInterval = -15 * 60;
//                EKAlarm *alaram = [EKAlarm alarmWithRelativeOffset:aInterval];
//                [event addAlarm:alaram];
//                break;
//            }
//            case 4:
//            {
//                NSTimeInterval aInterval = -30 * 60;
//                EKAlarm *alaram = [EKAlarm alarmWithRelativeOffset:aInterval];
//                [event addAlarm:alaram];
//                break;
//            }
//            case 5:
//            {
//                NSTimeInterval aInterval = -1 * 60 * 60;
//                EKAlarm *alaram = [EKAlarm alarmWithRelativeOffset:aInterval];
//                [event addAlarm:alaram];
//                break;
//            }
//            case 6:
//            {
//                NSTimeInterval aInterval = -2 * 60 * 60;
//                EKAlarm *alaram = [EKAlarm alarmWithRelativeOffset:aInterval];
//                [event addAlarm:alaram];
//                break;
//            }
//            case 7:
//            {
//                NSTimeInterval aInterval = -1 * 24 * 60 * 60;
//                EKAlarm *alaram = [EKAlarm alarmWithRelativeOffset:aInterval];
//                [event addAlarm:alaram];
//                break;
//            }
//            case 8:
//            {
//                NSTimeInterval aInterval = -2 * 24 * 60 * 60;
//                EKAlarm *alaram = [EKAlarm alarmWithRelativeOffset:aInterval];
//                [event addAlarm:alaram];
//                break;
//            }
//
//            default:
//                break;
//        }

        //finally add it to calendar
        NSError *err = nil;
        BOOL complete = [eventStore saveEvent:event span:EKSpanThisEvent error:&err];
        if(err)
        {
            NSLog(@"error in storing event");
        }
        else
        {
            NSLog(@"successfully added");
        }

        if(complete)
        {
            NSLog(@"successfully added");
        }
        else
        {
            NSLog(@"error in storing event");
        }



//        [eventStore release];
    }
}

-(NSDate *) setWorkOutDate:(NSString *) workIn today:(NSString *)today{
    
    NSString *newWorkIn = [NSString stringWithFormat:@"%@ %@",today,workIn];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *workInDate = [dateFormatter dateFromString:newWorkIn];
    
    
    NSDate *newWorkOutDate = [self addDate:workInDate];//上班時間加九小時半
//    [comps setMinute:1];
    
    NSString *newWorkInDate = [dateFormatter stringFromDate:newWorkOutDate];
    
    NSString *referenceAfterTime = [NSString stringWithFormat:@"%@ %@",today,@"19:30:59"];//最晚下班時間提醒
    NSDate *referenceAfterDate = [dateFormatter dateFromString:referenceAfterTime];
    NSString *referencestr = [dateFormatter stringFromDate:referenceAfterDate];
//    NSLog(@"newWorkInDate: %@ referencestr:%@",newWorkInDate,referencestr);
    
    NSString *referenceBeforeTime = [NSString stringWithFormat:@"%@ %@", today, @"08:30:00"];
    NSDate *referenceBeforeDate = [dateFormatter dateFromString:referenceBeforeTime];
    NSString *referenceBeforestr = [dateFormatter stringFromDate:referenceBeforeDate];
    
    //如果超過19:30就 return 19:30
    NSComparisonResult resultAfter = [newWorkOutDate compare:referenceAfterDate];//如果下班時間早於晚上七點半
    if (resultAfter != NSOrderedAscending || resultAfter == NSOrderedSame) { //如果判斷不早於下班時間回傳 晚上七點半
        return referenceAfterDate;
    }
    
    //如果早於08:30就 return 18:00
    NSComparisonResult resultBefore = [workInDate compare:referenceBeforeDate];
    if (resultBefore == NSOrderedAscending || resultBefore == NSOrderedSame) {
        return [self addDate:referenceBeforeDate];
    }
    return newWorkOutDate;
}

-(NSDate *) addDate:(NSDate *) date{
    //處理Date 上班時間加上九小時三十分
    NSCalendar *calender = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setHour:9];
    [comps setMinute:30];
    return [calender dateByAddingComponents:comps toDate:date options:0];//Date 加九個半小
}

-(void) setNotificationForWorkIn:(NSDate *)date{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setDay:1];
    NSDate *addOneDay = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:date options:0];
    NSDateComponents *checkDate = [[NSCalendar currentCalendar] components:NSCalendarUnitWeekday | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear  | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:addOneDay];
    
    if ([checkDate weekday] == 1 || [checkDate weekday] == 7) {
        //設定下禮拜一打卡
        [dateComponents setDay:3];
        NSDate *addNextWeekDay = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:date options:0];
        NSDateComponents *nextWeek = [[NSCalendar currentCalendar] components:NSCalendarUnitWeekday | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear  | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:addNextWeekDay];
        nextWeek.hour = 10;
        nextWeek.minute = 00;
        nextWeek.second = 00;
        NSString *tittleStr =  [NSString stringWithFormat:@"Clickforce-%ld-%@-%@", nextWeek.year,
                                nextWeek.month > 10 ? [NSString stringWithFormat:@"%ld", (long)nextWeek.month] : [NSString stringWithFormat:@"0%ld", nextWeek.month],
                                nextWeek.day > 10 ? [NSString stringWithFormat:@"%ld", (long)nextWeek.day] : [NSString stringWithFormat:@"0%ld", nextWeek.day]];
        
        [self setNotificationDate:nextWeek setTittle:tittleStr setBody:@"你尚未打卡上班唷" setType:0];
//        NSLog(@"nextWeek: %@",nextWeek);
    } else {
        //設定隔天通知打卡
        checkDate.hour = 10;
        checkDate.minute = 00;
        checkDate.second = 00;
        NSString *tittleStr =  [NSString stringWithFormat:@"Clickforce-%ld-%@-%@", checkDate.year,
                            checkDate.month > 10 ? [NSString stringWithFormat:@"%ld", (long)checkDate.month] : [NSString stringWithFormat:@"0%ld", checkDate.month],
                            checkDate.day > 10 ? [NSString stringWithFormat:@"%ld", (long)checkDate.day] : [NSString stringWithFormat:@"0%ld", checkDate.day]];
        [self setNotificationDate:checkDate setTittle:tittleStr setBody:@"你尚未打卡上班唷" setType:0];
//        NSLog(@"checkDate: %@",checkDate);
    }
    
}

-(void) setNotificationForWorkOut:(NSDateComponents *)date{
    //判斷 月、日 顯示補兩位數
    NSString *tittleStr =  [NSString stringWithFormat:@"Clickforce-%ld-%@-%@", date.year,
                 date.month > 10 ? [NSString stringWithFormat:@"%ld", (long)date.month] : [NSString stringWithFormat:@"0%ld", date.month],
                 date.day > 10 ? [NSString stringWithFormat:@"%ld", (long)date.day] : [NSString stringWithFormat:@"0%ld", date.day]];
    
   
    if (nil != workOutMsg) {
        [self setNotificationDate:date setTittle:tittleStr setBody:workOutMsg setType:1];
    } else {
        [self setNotificationDate:date setTittle:tittleStr setBody:@"現在可以下班摟，快跑啊～" setType:1];
    }
}
 /**
  Type
  0.上班
  1.下班
  **/
-(void)setNotificationDate:(NSDateComponents *)date setTittle:(NSString *) tittle setBody:(NSString *) body setType:(int) type{
    [[[Notification alloc] init] removeAllNotification];//每次下通知時清除所有通知
    
    Notification *notification = [[Notification alloc] init];
    if (type == 0){
        [notification addNotificationWhitCalendar:date identifier:notification.nextWorkInRequest tittle:tittle subtittle:@"上班" body:body];//10點尚未打卡
        [notification addNotificationWithLocation:tittle subtittle:@"上班" body:@"您進公司了嗎？您尚未打上班卡唷！" identifier:notification.nowWorkInRequest];//進入範圍尚未打卡
    } else if (type == 1) {
        [notification addNotificationWhitCalendar:date identifier:notification.dateRequest tittle:tittle subtittle:@"下班" body:body];
        
        NSDateComponents *date5 = [[NSDateComponents alloc] init];
        date5.year = date.year;
        date5.month = date.month;
        date5.day = date.day;
        if (date.minute + 5 >= 60) {
            date5.hour = date.hour + 1;
            date5.minute = date.minute + 5 - 60;
        } else {
            date5.hour = date.hour;
            date5.minute = date.minute + 5;
        }
        date5.second = 00;
        [notification addNotificationWhitCalendar:date5 identifier:notification.date5Request tittle:tittle subtittle:@"下班" body:@"尚未打卡唷，五分鐘前已經可以下班摟"];
        
        
        [notification addNotificationWithLocation:tittle subtittle:@"下班" body:@"您離開公司了？您尚未打下班卡唷！" identifier:notification.nowWorkOutRequest];
        
//        NSDateComponents *date10 = [[NSDateComponents alloc] init];
//        date10.year = date.year;
//        date10.month = date.month;
//        date10.day = date.day;
//        if (date.minute + 10 >= 60) {
//            date10.hour = date.hour + 1;
//            date10.minute = date.minute + 10 - 60;
//        } else {
//            date10.hour = date.hour;
//            date10.minute = date.minute + 10;
//        }
//        date10.second = 00;
//        [notification addNotificationWhitCalendar:date10 identifier:notification.date10Request tittle:tittle subtittle:@"下班" body:@"十分鐘前已經可以下班摟"];
//        NSLog(@"date = %@",date);
//        NSLog(@"date5 = %@",date5);
//        NSLog(@"date10 = %@",date10);
    }
    
}

-(void) setRandomWorkOutMsg{
    workOutString = [NSArray arrayWithObjects:@"還不下班在等什麼？", @"現在命令你下班了！", @"Go Home! Go~ Go~", @"親～下班時間到摟！", @"484很想加班呀？", @"哭啊！今納西花太！", nil];
    if (nil != workOutString) {
        NSInteger rnd = arc4random() % [workOutString count];
        workOutMsg = [workOutString objectAtIndex:rnd];
    }
}

-(void) notification{
    [[[Notification alloc] init] getAllNotification];
//    NSString *newWorkIn = @"2021-08-20 15:20:00";
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//    NSDate *workInDate = [dateFormatter dateFromString:newWorkIn];
//    NSDateComponents *dateContent = [[NSCalendar currentCalendar] components: NSCalendarUnitYear | NSCalendarUnitDay  | NSCalendarUnitHour | NSCalendarUnitMonth | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitWeekday fromDate:workInDate];
//    [self setNotificationDate:dateContent setTittle:@"Test Tittle" setBody:@"Test Body" setType:0];

//    NSString *newWorkIn = @"2021-08-20 15:20:00";
//    Notification *nt = [[Notification alloc] init];
//    [nt addNotificationWithLocation:newWorkIn subtittle:@"下班" body:@"您離開公司了？您尚未打下班卡唷！" identifier:nt.nowWorkOutRequest];
//    [nt addNotificationWithLocation:newWorkIn subtittle:@"上班" body:@"您進公司了？您尚未打上班卡唷！" identifier:nt.nextWorkInRequest];
//    [self setNotificationForWorkOut:[[NSCalendar currentCalendar] components:NSCalendarUnitWeekday | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear  | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:workInDate]];
//    [self setNotificationForWorkIn:workInDate];
    
//    NSDateComponents *dateContent = [[NSCalendar currentCalendar] components: NSCalendarUnitYear | NSCalendarUnitDay  | NSCalendarUnitHour | NSCalendarUnitMonth | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitWeekday fromDate:workInDate];
//    NSString *tittleStr = @"";
//    tittleStr = [NSString stringWithFormat:@"Clickforce-%ld-%@-%@", dateContent.year,
//                 dateContent.month > 10 ? [NSString stringWithFormat:@"%ld", (long)dateContent.month] : [NSString stringWithFormat:@"0%ld", dateContent.month],
//                 dateContent.day > 10 ? [NSString stringWithFormat:@"%ld", (long)dateContent.day] : [NSString stringWithFormat:@"0%ld", dateContent.day]];
//    NSLog(@"tittleStr: %@",tittleStr);
    
//    NSDateComponents *date = [[NSDateComponents alloc] init];
//    date.year = dateContent.year;
//    date.month = dateContent.month;
//    date.day = dateContent.day + 1;
//    date.hour = 18;
//    date.minute = 34;
//    date.second = 00;
//    date.weekday = dateContent.weekday + 1;
//    date = dateContent;
//    date.day = date.day + 1;
//    NSLog(@"date: %@",dateContent);
//    NSLog(@"date2: %@", [NSDate]);
//    [notification addNotificationWhitCalendar:date identifier:notification.dateRequest tittle:tittleStr subtittle:@"下班" body:workOutMsg];
//    [[[Notification alloc] init] addNotificationWhitCalendar:date identifier:notification.dateRequest tittle:tittleStr subtittle:@"下班" body:workOutMsg];
//    
//    NSDateComponents *date2 = [[NSDateComponents alloc] init];
//    date2.year = 2021;
//    date2.month = 8;
//    date2.day = 12;
//    date2.hour = 15;
//    date2.minute = 30;
//    date2.second = 10;
//    NSLog(@"date2: %@",date2);
////    date.second = date.second+10;
//    [notification addNotificationWhitCalendar:date2 identifier:notification.date5Request tittle:tittleStr subtittle:@"您五分鐘前就可下班摟" body:workOutMsg];
//    
//    NSDateComponents *date3 = [[NSDateComponents alloc] init];
//    date3.year = 2021;
//    date3.month = 8;
//    date3.day = 12;
//    date3.hour = 15;
//    date3.minute = 30;
//    date3.second = 20;
//    NSLog(@"date3: %@",date3);
////    date.second = date.second+10;
//    [notification addNotificationWhitCalendar:date3 identifier:notification.date10Request tittle:tittleStr subtittle:@"您十分鐘前就可下班摟" body:workOutMsg];
//    Notification *no = [[Notification alloc] init];
//    [no addNotificationWithLocation:@"TEST" subtittle:@"Location in" body:@"TEST BODY" identifier:no.nowWorkOutRequest];
//    [[[Notification alloc] init] addNotificationWhitTimeInterval:5 tittle:tittleStr subtittle:@"您五分鐘前就可下班摟" body:workOutMsg];
//    [[[Notification alloc] init] addNotificationWhitTimeInterval:10 tittle:@"TEST" subtittle:@"您十分鐘前就可下班摟" body:@"TEST BODY"];
//    [[[Notification alloc] init] addNotificationWithLocation:@"20210806 10:00" subtittle:@"上班" body:@"你還不打卡嗎？"];
//    [[[Notification alloc]init]addNotificationWithLocation:@"20210806 10:00" subtittle:@"上班" body:@"你還不打卡嗎？"];
    
    
}


@end
