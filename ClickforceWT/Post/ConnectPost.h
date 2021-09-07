//
//  ConnectPost.h
//  ClickforceWT
//
//  Created by Eric Chen on 2020/8/22.
//  Copyright © 2020 Eric Chen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <WebKit/WKWebView.h>


//extern PostParameter const WorkUrl = {@"http://192.168.1.112/laravelEric/public/api/"};
//extern PostParameter const WorkCua = {@"getcua"};
//extern PostParameter const WorkIn = {@"worktimein"};
//extern PostParameter const WorkOut = {@"worktimeout"};
//extern PostParameter const WorkAlldate = {@"getUserAllData"};

@protocol ConnectPostDelegate <NSObject>

@optional
/**
取得廣告請求 response Data

@param reponseValue Response Data
*/
- (void)onRequestSuccessData:(NSData *)reponseValue;

/**
 請求廣告失敗
 */
- (void)onRequesFailtError;


@end

@interface ConnectPost : NSObject
@property (nonatomic, copy) NSData *postParams;
@property (readonly, nonatomic, weak) NSString *WorkUrl;
@property (readonly, nonatomic, weak) NSString *WorkCua;
@property (readonly, nonatomic, weak) NSString *WorkCheckStatus;
@property (readonly, nonatomic, weak) NSString *WorkIn;
@property (readonly, nonatomic, weak) NSString *WorkOut;
@property (readonly, nonatomic, weak) NSString *WorkAlldate;
@property(nonatomic, assign)id<ConnectPostDelegate>delegate;

- (id) init;

- (void) excute:(NSString *)postUrl;

- (void) excute:(NSString *)postUrl postBlockData:(nullable void (^)(NSData * __nullable data))block_data;

@end
