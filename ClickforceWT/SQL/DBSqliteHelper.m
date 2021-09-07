//
//  DBSqliteHelper.m
//  ClickforceWT
//
//  Created by Eric Chen on 2020/8/25.
//  Copyright © 2020 Eric Chen. All rights reserved.
//

#import "DBSqliteHelper.h"

@implementation DBSqliteHelper


- (BOOL)openDB{
//    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
//    NSString *DBPath = [documentPath stringByAppendingPathComponent:@"work.sqlite"];
//    NSLog(@"DocumentPath: %@", documentPath);
    NSString *DBPath = [self getDataBaseFullPath:@"work.sqlite"];
    NSLog(@"Sqlite file Path: %@", DBPath);
    
    
//    NSLog(@"sqlite3_open_v2: %d",sqlite3_open_v2(DBPath.UTF8String, &workdb, SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE, nil));
//    NSLog(@"sqlite3_open_v2: %d",sqlite3_open_v2(DBPath.UTF8String, &workdb, SQLITE_OPEN_READWRITE, nil));
//    NSLog(@"====================================================================================");
//    [self copyDataBaseIfNeeded:@"work" oftype:@"sqlite"];
//    if (sqlite3_open(DBPath.UTF8String, &workdb) != SQLITE_OK) {
    if (sqlite3_open_v2(DBPath.UTF8String, &workdb, SQLITE_OPEN_READWRITE, nil) != SQLITE_OK) {
//        NSLog(@"Can't find work.sqlite.");
        if (sqlite3_open_v2(DBPath.UTF8String, &workdb, SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE, nil) == SQLITE_OK) {
            NSLog(@"Creat work.sqlite success.");
            return [self creatTable] & [self creatUserStatusTable];//創建NEW DB 需要創建新的Table表
        }
        NSLog(@"Open work.sqlite fail.");
        return NO;
    } else {
//        NSLog(@"YES");
        return YES;
    }
}

- (BOOL) creatTable{
    NSString *creatUserInfo = @"CREATE TABLE if NOT EXISTS 'UserInfo' ('id' integer PRIMARY KEY AUTOINCREMENT, 'cua_id' text NOT NULL , 'cua_name' text NOT NULL, 'cua_response' text NOT NULL);";
    
    return [self execSQL:creatUserInfo];
}

- (BOOL) creatUserStatusTable{
    NSString *creatUserStatus = @"CREATE TABLE if NOT EXISTS 'UserStatus' ('id' integer PRIMARY KEY AUTOINCREMENT, 'user_type' text NOT NULL , 'user_date' text NOT NULL , 'time_clock_in' text NOT NULL, 'time_clock_out' text NOT NULL, 'user_response' text NOT NULL);";
    return [self execSQL:creatUserStatus];
}

//執行指令
- (BOOL) execSQL:(NSString *)SQL{
    return sqlite3_exec(workdb, SQL.UTF8String, nil, nil, nil) == SQLITE_OK;
}

//將抓出系統放置Sqlite位置
-(NSString *)getDataBaseFullPath:(NSString *)fileName
{
    NSArray *fullPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [fullPath objectAtIndex:0];
    NSString *fullPathInDoc = [documentDirectory stringByAppendingPathComponent:fileName];

    return fullPathInDoc;
}

//取得Table是否有資料在裡面
- (BOOL)getUserInfo{
    NSString *getUserInfo = @"SELECT COUNT(*) FROM 'UserInfo';";
    
    sqlite3_stmt *queryResult = nil;
    int count = 0;
    
    if(sqlite3_prepare_v2(workdb, getUserInfo.UTF8String, -1, &queryResult, NULL) == SQLITE_OK){
        if (sqlite3_step(queryResult) == SQLITE_ROW) {
            count = [[NSString stringWithUTF8String:(char *)sqlite3_column_text(queryResult, 0)] intValue];
        }
    }
//    NSLog(@"%d",count);
    sqlite3_finalize(queryResult);
    return count > 0 ? YES : NO;
}

//將登入後資料存在DB
- (BOOL)insertUserInfo:(NSString *)userId name:(NSString *)userName response:(NSString *)userResponse{
    NSString *insterUserInfoData = [NSString stringWithFormat:@"INSERT INTO 'UserInfo' ('cua_id', 'cua_name', 'cua_response') VALUES ('%@', '%@', '%@');", userId, userName, userResponse];
    return [self execSQL:insterUserInfoData];
}

- (NSDictionary *)getUserData {
    NSDictionary *userInfoDict = nil;
    NSString *data = @"select * from UserInfo;";
    sqlite3_stmt *queryResult = nil;
    int temp = sqlite3_prepare_v2(workdb, data.UTF8String, -1, &queryResult, NULL);
    if (temp == SQLITE_OK) {
//        NSLog(@"sqlite3_data_count: %d",sqlite3_data_count(queryResult));
       while (sqlite3_step(queryResult) == SQLITE_ROW) {
    
           NSString *sid, *userId, *userName, *userReponse;
    
           sid = [NSString stringWithUTF8String:(char *)sqlite3_column_text(queryResult, 0)];
           userId = [NSString stringWithUTF8String:(char *)sqlite3_column_text(queryResult, 1)];
           userName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(queryResult, 2)];
           userReponse = [NSString stringWithUTF8String:(char *)sqlite3_column_text(queryResult, 3)];
    
//           NSLog(@"sid: %@ ,userId: %@ ,userName: %@ ,userReponse: %@", sid, userId, userName, userReponse);
           userInfoDict = @{@"userId" : userId, @"userName" : userName, @"userReponse" : userReponse};
       }
    }
    
       //使用完畢後將statement清空
       sqlite3_finalize(queryResult);
    return userInfoDict;
}

- (NSString *)getUserStatusType{
    NSString *result = nil;
    NSString *getUserStatusTypeData = @"SELECT * FROM 'UserStatus';";
//    NSString *getUserStatusTypeData=[NSString stringWithFormat:@"select user_date from UserStatus where user_date='%@'", date];
    sqlite3_stmt *queryResult = nil;
    int rp = sqlite3_prepare_v2(workdb, getUserStatusTypeData.UTF8String, -1, &queryResult, NULL);
    if (rp == SQLITE_OK) {
//        NSLog(@"sqlite3_data_count: %d",sqlite3_data_count(queryResult));
        while (sqlite3_step(queryResult) == SQLITE_ROW) {

               NSString *user_type, *user_date, *time_clock_in, *time_clock_out, *user_response;

               user_type = [NSString stringWithUTF8String:(char *)sqlite3_column_text(queryResult, 1)];
               user_date = [NSString stringWithUTF8String:(char *)sqlite3_column_text(queryResult, 2)];
               time_clock_in = [NSString stringWithUTF8String:(char *)sqlite3_column_text(queryResult, 3)];
               time_clock_out = [NSString stringWithUTF8String:(char *)sqlite3_column_text(queryResult, 4)];
               user_response = [NSString stringWithUTF8String:(char *)sqlite3_column_text(queryResult, 5)];

//                   NSLog(@"userReponse: %@", user_response);
    //        result = @{@"user_type" : user_type, @"user_date" : user_date, @"time_clock_in" : time_clock_in, @"time_clock_out" : time_clock_out, @"user_response" : user_response};
            result = user_response;
        }
    }
    
       //使用完畢後將statement清空
       sqlite3_finalize(queryResult);
     return result;
}

- (BOOL)insertUserStatusType:(NSString *)type date:(NSString *)tDate timeIn:(NSString *)tIn timeOut:(NSString *)tOut response:(NSString *)tResponse{
    //*****（先判斷是否有當日的值存入）*****，如沒有就可以INSTER，如果有的話就判斷狀況UPDATE
    NSString *insterUserInfoData=@"";
    NSString *checkstatus = [self getUserStatusType];
    if ([type isEqualToString:@""]) {
        //Insert
        insterUserInfoData = [NSString stringWithFormat:@"INSERT INTO 'UserStatus' ('user_type', 'user_date', 'time_clock_in', 'time_clock_out', 'user_response') VALUES ('%@', '%@', '%@', '%@', '%@');", type, tDate, tIn, tOut, tResponse];
    } else if([type isEqualToString:@"1"]){
        if (checkstatus == nil) {
            //Insert
            insterUserInfoData = [NSString stringWithFormat:@"INSERT INTO 'UserStatus' ('user_type', 'user_date', 'time_clock_in', 'time_clock_out', 'user_response') VALUES ('%@', '%@', '%@', '%@', '%@');", type, tDate, tIn, tOut, tResponse];
        } else {
            //Update
            insterUserInfoData= [NSString stringWithFormat:@"UPDATE 'UserStatus' SET user_type = '%@', time_clock_in = '%@', user_response = '%@' WHERE user_date = '%@'", type, tIn, tResponse, tDate];
        }
    } else {
        if (checkstatus == nil) {
            //Insert
            insterUserInfoData = [NSString stringWithFormat:@"INSERT INTO 'UserStatus' ('user_type', 'user_date', 'time_clock_in', 'time_clock_out', 'user_response') VALUES ('%@', '%@', '%@', '%@', '%@');", type, tDate, tIn, tOut, tResponse];
        } else {
            //Update
            insterUserInfoData = [NSString stringWithFormat:@"UPDATE 'UserStatus' SET user_type = '%@', time_clock_out = '%@', user_response = '%@' WHERE user_date = '%@' and user_type = '1' ;", type, tOut, tResponse, tDate];
        }
    }
    NSLog(@">>>>>> %@",insterUserInfoData);
    return [self execSQL:insterUserInfoData];
}

-(BOOL) delUserStatus{
    NSString *delTable = @"DELETE FROM UserStatus";
    if ([self execSQL:delTable]) {
        NSString *reSetPrimeKey = @"UPDATE sqlite_sequence SET seq = 0 WHERE name = 'UserStatus';";
        return [self execSQL:reSetPrimeKey];
    }
    
    return nil;
}

- (void)closeDB{
    sqlite3_close(workdb);
}

//判斷是否[]需要複製檔案
//-(void)copyDataBaseIfNeeded:(NSString *)fileName oftype:(NSString *)ofTypeName
//{
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    NSString *enterFileName = [NSString stringWithFormat:@"%@%@%@",fileName,@".",ofTypeName];
//    NSString *pathInDoc = [self getDataBaseFullPath:enterFileName];
//    NSLog(@"fullPath: %@",pathInDoc);
//    NSLog([fileManager fileExistsAtPath:pathInDoc] ? @"Y" : @"N");
////    if([fileManager fileExistsAtPath:pathInDoc] == NO)
////    {
////        NSLog(@"應該copy");
////        NSString *filePath = [[NSBundle mainBundle]pathForResource:fileName ofType:ofTypeName];
////         [fileManager copyItemAtPath:filePath toPath:pathInDoc error:nil];
////    }
////    else
////        NSLog(@"已存在");
//}



@end
