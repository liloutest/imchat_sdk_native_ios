//
//  ZMDatabaseManager.h
//  imchat
//
//  Created by Lilou on 2024/10/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 @brief DB manager
 */
@interface ZMDatabaseManager : NSObject
/// Singleton
+ (instancetype)sharedInstance;

/// init DB
- (void)setupDatabaseWithPassword:(NSString *)password;

/// Insert new Object
- (void)insertObject:(id)object;

/// Update Object
- (void)updateObject:(id)object;

- (void)dropAllTables;
- (void)updateAllMsgRead;

/// Delete Object
- (void)deleteObject:(id)object;

- (BOOL)deleteWithModelClass:(Class)object where:(NSString *)where;

- (NSInteger)count:(Class)object withWhere:(NSString *)whereStr;

/// Query Object
- (NSArray *)queryObjectsOfClass:(Class)cls withWhere:(NSString *)whereStr orderBy:(NSString *)orderBy;

- (NSArray<ZMMessage *> *)loadAllDatas;
@end

NS_ASSUME_NONNULL_END
