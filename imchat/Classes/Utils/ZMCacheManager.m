//
//  ZMCacheManager.m
//  imchat
//
//  Created by Lilou on 2024/11/6.
//

#import "ZMCacheManager.h"

@implementation ZMCacheManager
+ (instancetype)sharedManager {
    static ZMCacheManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (UIImage *)getImageWithPath:(NSString *)path {
    UIImage *img = [UIImage imageWithContentsOfFile:@""];
    return img;
}

- (NSString *)getSandboxRealPathWithFileName:(NSString *)fileName {
    if(!fileName)return nil;
    
    NSString *sandboxPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/MediaCache"];

    NSString *destinationPath = [sandboxPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",fileName]];
    
    return destinationPath;
}

- (NSString *)copyFileToSandbox:(NSString *)path {

    if(!path)return nil;
    
    // 2. 沙盒中的目标路径
    // 获取沙盒的 Documents 目录路径
    NSString *sandboxPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/MediaCache"];
    
    NSString *fileName = [path lastPathComponent];
    // 定义目标文件的路径
    NSString *destinationPath = [sandboxPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",fileName]];
    
    // 3. 使用 NSFileManager 进行文件拷贝
    NSError *error = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    

        
    // 如果目标目录不存在，则创建该目录
    if (![fileManager fileExistsAtPath:sandboxPath]) {
        NSError *error = nil;
        BOOL success = [fileManager createDirectoryAtPath:sandboxPath
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:&error];
        if (!success) {
            NSLog(@"创建目录失败: %@", error.localizedDescription);
            return nil;
        }
        NSLog(@"目标目录已创建: %@", sandboxPath);
    }
    
    // 4. 如果目标路径已经存在文件，则可以先删除或覆盖它
    if ([fileManager fileExistsAtPath:destinationPath]) {
        NSError *error = nil;
        [fileManager removeItemAtPath:destinationPath error:&error];
        if (error) {
            NSLog(@"删除目标文件失败: %@", error.localizedDescription);
            return nil;
        }
    }
    
    // 拷贝文件
    BOOL success = [fileManager copyItemAtPath:path toPath:destinationPath error:&error];
    
    if (success) {
        NSLog(@"文件成功拷贝到沙盒: %@", destinationPath);
    } else {
        NSLog(@"文件拷贝失败: %@", error.localizedDescription);
        return nil;
    }
    
    return destinationPath;
}
@end
