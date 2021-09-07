//
//  PromptView.m
//  ClickforceWT
//
//  Created by Eric Chen on 2020/9/3.
//  Copyright © 2020 Eric Chen. All rights reserved.
//

#import "PromptView.h"

@interface PromptView(){
    UIView *msgView, *backgroundView;
}

@end

@implementation PromptView
@synthesize delegate;

- (instancetype)init
{
    self = [super init];
    if (self) {
        msgView = [[UIView alloc] init];
        backgroundView = [[UIView alloc] init];
    }
    return self;
}

- (void) setMsgText:(NSString *) msg seOnView:(UIViewController *) v{
    backgroundView.frame = CGRectMake(0, 0, v.view.frame.size.width, v.view.frame.size.height);
    [backgroundView setBackgroundColor:[UIColor blackColor]];
    backgroundView.alpha = 0.75;
    [v.view addSubview: backgroundView];
    
    msgView.frame = CGRectMake(v.view.frame.size.width / 2 - (v.view.frame.size.width - 40) / 2, v.view.frame.size.height / 2 - (v.view.frame.size.height / 5) / 2, v.view.frame.size.width - 40, v.view.frame.size.height / 5);
    [msgView setBackgroundColor:[UIColor whiteColor]];
    [v.view addSubview:msgView];
    
    UIStackView *container = [[UIStackView alloc] initWithFrame:CGRectMake(20, 20, msgView.frame.size.width - 40 , msgView.frame.size.height - 40)];
    container.axis = UILayoutConstraintAxisVertical;
    container.alignment = UIStackViewAlignmentFill;
    container.distribution = UIStackViewDistributionEqualCentering;
    
    UILabel *promptMsg = [[UILabel alloc] init];
    [promptMsg setTextColor:[UIColor blackColor]];
    [promptMsg setText:msg];
    [promptMsg setFont:[UIFont boldSystemFontOfSize:18]];
    [promptMsg setTextAlignment:NSTextAlignmentLeft];
    promptMsg.numberOfLines = 4;
    
    [container addArrangedSubview:promptMsg];
    
    UIStackView *buttonContainer = [[UIStackView alloc] init];
    buttonContainer.alignment = UIStackViewAlignmentFill;
    buttonContainer.distribution = UIStackViewDistributionFill;
    buttonContainer.spacing = 25.0;
    
    UIView *leftView = [[UIView alloc] init];
    leftView.alpha = 0;
    
    UIButton *cancelBtn = [[UIButton alloc] init];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(actionCancel) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *confirmBtn = [[UIButton alloc] init];
    [confirmBtn setTitle:@"確定" forState:UIControlStateNormal];
    [confirmBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [confirmBtn addTarget:self action:@selector(actionConfiem) forControlEvents:UIControlEventTouchUpInside];
    
    [buttonContainer addArrangedSubview:leftView];
    [buttonContainer addArrangedSubview:cancelBtn];
    [buttonContainer addArrangedSubview:confirmBtn];
    
    [container addArrangedSubview:buttonContainer];
    
    [msgView addSubview:container];
    
}

-(void) removePrompt{
    if (backgroundView != nil) [backgroundView removeFromSuperview];
    if (msgView != nil) [msgView removeFromSuperview];
}

-(void) actionConfiem{
    if (self.delegate != nil) {
        if ([self.delegate respondsToSelector:@selector(onConfirm)]) {
            [self.delegate onConfirm];
            [self removePrompt];
        }
    }
}

-(void) actionCancel{
    if (self.delegate != nil) {
        if ([self.delegate respondsToSelector:@selector(onCancel)]) {
            [self.delegate onCancel];
        }
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
