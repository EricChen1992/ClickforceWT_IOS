//
//  MainViewController.m
//  ClickforceWT
//
//  Created by Eric Chen on 2020/8/20.
//  Copyright © 2020 Eric Chen. All rights reserved.
//

#import "MainViewController.h"
#import "ConnectPost.h"
#import "ParsJson.h"
#import "DBSqliteHelper.h"

@interface MainViewController ()<UITextFieldDelegate, ConnectPostDelegate, CLLocationManagerDelegate>{
    ConnectPost *post;
    ParsJson *parsjson;
    DBSqliteHelper *db;
    BOOL isOpenDB;
    int closeNb;
}

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _userAccount.delegate = self;
    _userPassword.delegate = self;
    closeNb = 0;
    db = [[DBSqliteHelper alloc] init];
    isOpenDB = [db openDB];
    [self setFieldTextRightViewButton:_userPassword];
}

//當編輯完畢按下return收起鍵盤
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == _userAccount) {
        [_userPassword becomeFirstResponder];
    }else if (textField == _userPassword){
        [textField resignFirstResponder];
    }
    return false;
}


//設定點擊空白處關閉鍵盤
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

//設定Password FieldText Right view
- (void) setFieldTextRightViewButton:(UITextField *) tempTextField{
    tempTextField.secureTextEntry = YES;
    tempTextField.clearButtonMode = UITextFieldViewModeNever;
    
    UIButton *Button_ShowPassword = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 20)];
    Button_ShowPassword.imageEdgeInsets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 5.0f);//Image view設定邊框距離
    [Button_ShowPassword setImage:[UIImage imageNamed:@"eye"] forState:UIControlStateNormal];
    
    //顯示密碼
    [Button_ShowPassword addTarget:nil action:@selector(showPassword:) forControlEvents:UIControlEventTouchUpInside];

    tempTextField.rightView = Button_ShowPassword;
    tempTextField.rightViewMode = UITextFieldViewModeAlways;
}

//顯示密碼與隱藏密碼 跟 顯示圖示
- (IBAction)showPassword:(id)sender{
    UIButton *temp = sender;
    _userPassword.secureTextEntry = !_userPassword.isSecureTextEntry;
    if (_userPassword.isSecureTextEntry) {
        [temp setImage:[UIImage imageNamed:@"closeeye"] forState:UIControlStateNormal];
    } else {
        [temp setImage:[UIImage imageNamed:@"eye"] forState:UIControlStateNormal];
    }
}

- (IBAction)loginAuth:(id)sender {
    NSString *useraccount = [[_userAccount text] containsString:@"@"] ? [_userAccount text] : [NSString stringWithFormat:@"%@%@",[_userAccount text], @"@clickforce.com.tw"];
    NSString *userpassword = [_userPassword text];
//    NSLog(@"Email-> %@\n Password-> %@", useraccount, userpassword);
    
    //判斷兩欄位是否空白，如果空白帶入提示字元
    if ([useraccount length] == 0 || [userpassword length] == 0) {
        NSLog(@"請輸入Account or Password.");
        [self setAccountandPasswordIsEmpty:_userAccount changeString:@"請輸入帳號"];
        [self setAccountandPasswordIsEmpty:_userPassword changeString:@"請輸入密碼"];
        return;
    }
    //Login auth
    NSDictionary *dict=@{@"cuaemail" : useraccount, @"cuapassword" : userpassword};
    post = [[ConnectPost alloc] init];
    post.delegate = self;
    post.postParams = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    [post excute:[NSString stringWithFormat:@"%@%@", post.WorkUrl, post.WorkCua]];
    
    [self.view endEditing:YES];//關閉鍵盤
}
- (IBAction)cancelAuth:(id)sender {
    closeNb++;
    if (closeNb == 1) {
        [self showToast:@"提示:再一次取消就退出App摟!!"];
    } else {
        exit(0);
    }
}

//如輸入都為空白帶入提示字元並更改顏色
- (void) setAccountandPasswordIsEmpty:(UITextField *) modifyTextField changeString:(NSString *)strValue{
    UIColor *color = [UIColor redColor];
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:strValue];
    [str addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, str.length)];
    modifyTextField.attributedPlaceholder = str;
}

- (void)onRequestSuccessData:(NSData *)reponseValue{
//    NSLog(@"%s",__PRETTY_FUNCTION__);
//    NSError *error = nil;
//    NSLog(@"%@", [[NSString alloc] initWithData:reponseValue encoding:NSUTF8StringEncoding]);
    
//    parsjson = [[ParsJson alloc] initWithValue:[NSJSONSerialization JSONObjectWithData:reponseValue options:kNilOptions error:&error]];
    parsjson = [[ParsJson alloc] initWithValue:reponseValue];
    if (parsjson != nil && [parsjson status] != 0) {
        if (isOpenDB) {
            BOOL result = [db insertUserInfo:[NSString stringWithFormat:@"%d",[parsjson userId]] name:[parsjson userName] response:[[NSString alloc] initWithData:reponseValue encoding:NSUTF8StringEncoding]];
            NSLog(result ? @"Insert Success." : @"Insert Fail");
            [db closeDB];
        }
        
        //需要開一個線程Push至下一個VC，不然會卡頓
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Login");
            [self moveWorkView];
        });
        
    } else {
        NSLog(@"Not Login.");
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showToast:[parsjson msg]];
        });
//        NSLog(@"%@",[parsjson msg]);
    }
//    NSLog(@"ParsJson-> %@\n status-> %d\n id-> %d\n name-> %@\n email-> %@",parsjson, [parsjson status], [parsjson userId], [parsjson userName], [parsjson userEmail]);
    
}

- (void)moveWorkView{
    //Update new VC
        UIStoryboard *board = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        MainViewController *workcv = [board instantiateViewControllerWithIdentifier:@"workViewController"];
        [self.navigationController pushViewController:workcv animated:NO];
}

//顯示提示訊息
- (void) showToast:(NSString *) msg {
    UILabel *showLable = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 100, self.view.frame.size.height-100, 200, 35)];
    showLable.text = msg;
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
@end
