//
//  ZMDatabaseManager.m
//  imchat
//
//  Created by Lilou on 2024/10/14.
//

#import "ZMDatabaseManager.h"
#import <LKDBHelper/LKDBHelper.h>
#import <FMDB/FMDB.h>
@implementation ZMDatabaseManager
+ (instancetype)sharedInstance {
    static ZMDatabaseManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [ZMDatabaseManager new];
//        [instance setupDatabaseWithPassword:@"123456"];
//       LKDBHelper *hl =  [[LKDBHelper alloc] initWithDBPath:[self customDBPath]];
//        [hl setKey:@"123456"];
    });
    return instance;
}

//+ (NSString *)customDBPath {
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    return [paths[0] stringByAppendingPathComponent:@"mySecureDB.sqlite"];
//}

- (void)setupDatabaseWithPassword:(NSString *)password {
    // init db
    LKDBHelper *dbHelper = [LKDBHelper getUsingLKDBHelper];
//    [dbHelper setDBName:@"ZMDB.sqlite"];
    [LKDBHelper setLogError:YES];
    
    //set encrypt key
    [[LKDBHelper getUsingLKDBHelper] setKey:password];
    
}

- (void)updateAllMsgRead{
    ZMMessage *msg = [ZMMessage new];
    msg.sendStatus = ZMMessageSendStatusReaded;
    msg.msgBody.sendStatus = msg.sendStatus;

//   BOOL suc = [[LKDBHelper getUsingLKDBHelper] updateToDB:ZMMessageMsgBody.class set:@{ @"status": @1 }  where:[NSString stringWithFormat:@"sessionId = '%@'",[ZMMessageManager sharedInstance].sessionId]];
//   BOOL suc = [[LKDBHelper getUsingLKDBHelper] updateToDB:msg where:[NSString stringWithFormat:@"sessionId = '%@'",[ZMMessageManager sharedInstance].sessionId]];
    
    NSString *tableName = [ZMMessageMsgBody getTableName];
    NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET status = ? WHERE sessionId = ?" ,tableName];
    BOOL suc = [[LKDBHelper getUsingLKDBHelper] executeSQL:sql arguments:@[@1, [ZMMessageManager sharedInstance].sessionId]];
    NSLog(@"%d",suc);
}


- (void)dropAllTables {
    [[LKDBHelper getUsingLKDBHelper] dropAllTable];
    
}


- (void)insertObject:(id)object {


    [[LKDBHelper getUsingLKDBHelper] insertToDB:object];
}

- (void)updateObject:(id)object {
    [object saveToDB];
//    [[LKDBHelper getUsingLKDBHelper] updateToDB:object where:[NSString stringWithFormat:@"sessionId = '%@'",[ZMMessageManager sharedInstance].sessionId]];
}

- (void)deleteObject:(id)object {
    [[LKDBHelper getUsingLKDBHelper] deleteToDB:object];
}

- (BOOL)deleteWithModelClass:(Class)object where:(NSString *)where {
    return [[LKDBHelper getUsingLKDBHelper] deleteWithClass:object where:where];
//    return  [LKDBHelper getUsingLKDBHelper] deleteWithTableName:<#(nonnull NSString *)#> where:<#(nullable id)#>;
}

- (NSInteger)count:(Class)object withWhere:(NSString *)whereStr {
    return  [[LKDBHelper getUsingLKDBHelper] rowCount:object where:whereStr];
}

- (NSArray *)queryObjectsOfClass:(Class)cls withWhere:(NSString *)whereStr orderBy:(NSString *)orderBy {
    return [[LKDBHelper getUsingLKDBHelper] search:cls where:whereStr orderBy:orderBy offset:0 count:NSIntegerMax];
}

- (NSArray<ZMMessage *> *)loadAllDatas {
    return [[LKDBHelper getUsingLKDBHelper] search:ZMMessage.class where:[NSString stringWithFormat:@"sessionId = '%@'",[ZMMessageManager sharedInstance].sessionId] orderBy:@"createTime ASC" offset:0 count:NSIntegerMax];
}

@end
