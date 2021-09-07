//
//  ConnectPost.m
//  ClickforceWT
//
//  Created by Eric Chen on 2020/8/22.
//  Copyright © 2020 Eric Chen. All rights reserved.
//

#import "ConnectPost.h"
@interface ConnectPost()<NSURLSessionDelegate>{
    NSURLSession *session;
    NSDate *data;
    NSMutableURLRequest *request;
    NSMutableData *responseData;
    NSURLSessionTask *task;
}
@end

@implementation ConnectPost
@synthesize delegate;

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        sessionConfig.timeoutIntervalForRequest = 10;
        sessionConfig.timeoutIntervalForResource = 10;
        session = [NSURLSession sessionWithConfiguration:sessionConfig];
//        session = [NSURLSession sharedSession];
        [self setParamsValue];
    }
    return self;
}

- (void) setParamsValue{
//    _WorkUrl = @"http://192.168.1.116/laravelEric/public/api/";//Test URL
    _WorkUrl = @"https://cua-new.holmesmind.com/api/";//Could URL
    _WorkCua = @"getcua";
    _WorkCheckStatus = @"getstatus";
    _WorkIn = @"worktimein";
    _WorkOut = @"worktimeout";
    _WorkAlldate = @"getUserAllData";
}

- (void)excute:(NSString *)postUrl{
    [self showMsg:[NSString stringWithFormat:@"PostUrl-> %@",postUrl]];
    [self showMsg:[NSString stringWithFormat:@"PostParams-> %@",[[NSString alloc] initWithData:self.postParams encoding:NSUTF8StringEncoding]]];
    
    NSURL *url = [NSURL URLWithString:postUrl];
    request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.HTTPBodyStream = [NSInputStream inputStreamWithData:self.postParams];
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString *reponseCode = [NSString stringWithFormat: @"%ld", [(NSHTTPURLResponse *)response statusCode]];
        
        if ([reponseCode  isEqual: @"200"]) {
            if (self.delegate != nil) {
                if ([self.delegate respondsToSelector:@selector(onRequestSuccessData:)]) {
//                    NSLog(@"%s",__PRETTY_FUNCTION__);
                    
                    [self.delegate onRequestSuccessData:data];
                }
//                NSLog(@"result -> %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            } else {
                if ([self.delegate respondsToSelector:@selector(onRequesFailtError)]) {
                    [self showMsg:[NSString stringWithFormat:@"Reponse-> %@ Error-> %@", reponseCode, error]];
                    [self.delegate onRequesFailtError];
                }
            }
        } else {
            if ([self.delegate respondsToSelector:@selector(onRequesFailtError)]) {
                [self showMsg:error];
                [self.delegate onRequesFailtError];
            }
        }
//        NSLog(@"data-> %@, \n response-> %li, \n errpr-> %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding], (long)[(NSHTTPURLResponse *)response statusCode], error);
    }];
    
    [task resume];
}
//- (NSData *)excute2:(NSString *)postUrl{
//    [self showMsg:[NSString stringWithFormat:@"PostUrl-> %@",postUrl]];
//        [self showMsg:[NSString stringWithFormat:@"PostParams-> %@",[[NSString alloc] initWithData:self.postParams encoding:NSUTF8StringEncoding]]];
//
//        NSURL *url = [NSURL URLWithString:postUrl];
//        request = [NSMutableURLRequest requestWithURL:url];
//        request.HTTPMethod = @"POST";
//        request.HTTPBodyStream = [NSInputStream inputStreamWithData:self.postParams];
//        [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
//        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
//        task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//            NSString *reponseCode = [NSString stringWithFormat: @"%ld", [(NSHTTPURLResponse *)response statusCode]];
//
//            if ([reponseCode  isEqual: @"200"]) {
//                return data;
//            } else {
//
//            }
//        }];
//
//        [task resume];
//}

- (void)excute:postUrl postBlockData:(void (^)(NSData * _Nullable))block_data{
    [self showMsg:[NSString stringWithFormat:@"PostUrl-> %@",postUrl]];
    [self showMsg:[NSString stringWithFormat:@"PostParams-> %@",[[NSString alloc] initWithData:self.postParams encoding:NSUTF8StringEncoding]]];

    NSURL *url = [NSURL URLWithString:postUrl];
    request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.HTTPBodyStream = [NSInputStream inputStreamWithData:self.postParams];
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString *reponseCode = [NSString stringWithFormat: @"%ld", [(NSHTTPURLResponse *)response statusCode]];

        if ([reponseCode  isEqual: @"200"]) {
            block_data(data);
        } else {
            [self showMsg:@"Request Fail."];
            block_data(NULL);
        }
    }];

    [task resume];
}

- (void) showMsg:(NSObject *) msg{
    NSLog(@"ConnectPost: %@", msg);
}


@end
