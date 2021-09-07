//
//  PromptView.h
//  ClickforceWT
//
//  Created by Eric Chen on 2020/9/3.
//  Copyright © 2020 Eric Chen. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol PromptViewDelegate <NSObject>

@optional
/**
按下確認
*/
- (void)onConfirm;

/**
按下取消
*/
- (void)onCancel;



@end

@interface PromptView : UIView
@property(nonatomic, assign)id<PromptViewDelegate>delegate;

- (id)init;

- (void) setMsgText:(NSString *) msg seOnView:(UIViewController *) v;

- (void) removePrompt;
@end
