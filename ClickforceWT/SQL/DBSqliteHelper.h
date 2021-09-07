//
//  DBSqliteHelper.h
//  ClickforceWT
//
//  Created by Eric Chen on 2020/8/25.
//  Copyright © 2020 Eric Chen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface DBSqliteHelper : NSObject{
    sqlite3 *workdb;
}

- (BOOL)openDB;

- (BOOL)getUserInfo;

- (NSDictionary *)getUserData;

- (BOOL)insertUserInfo:(NSString *) userId name:(NSString *) userName response:(NSString *) userResponse;

- (NSString *)getUserStatusType;

- (BOOL)insertUserStatusType:(NSString *)type date:(NSString *)tDate timeIn:(NSString *)tIn timeOut:(NSString *)tOut response:(NSString *)tResponse;

- (void)closeDB;

- (BOOL) delUserStatus;
@end
