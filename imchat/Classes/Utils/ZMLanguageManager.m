//
//  ZMLanguageManager.m
//  imchat
//
//  Created by Lilou on 2024/10/15.
//

#import "ZMLanguageManager.h"
#import "Constant.h"
@implementation ZMLanguageManager

+ (instancetype)sharedInstance {
    static ZMLanguageManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [ZMLanguageManager new];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _currentLanguage = [self getCurrentDeviceLanguage];
        _currentLanguagePack = [self loadLanguagePackForLanguage:_currentLanguage];
    }
    return self;
}

- (void)setCurrentLanguage:(NSString *)languageCode {
    if (![_currentLanguage isEqualToString:languageCode]) {
        _currentLanguage = languageCode;
        _currentLanguagePack = [self loadLanguagePackForLanguage:languageCode];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kZMLanguageDidChangeNotification object:nil];
    }
}

- (NSString *)localizedStringForKey:(NSString *)key, ... {
    NSString *localizedFormat = self.currentLanguagePack[key];
    if (!localizedFormat) {
        return key;
    }
    
    va_list args;
    va_start(args, key);
    NSString *localizedString = key;
    @try {
        NSArray *formatSpecifiers = [localizedFormat componentsSeparatedByString:@"%"];
        NSUInteger expectedArgCount = formatSpecifiers.count - 1;
        
        if (expectedArgCount > 0) {
//            NSMutableArray *arguments = [NSMutableArray arrayWithCapacity:expectedArgCount];
//            for (NSUInteger i = 0; i < expectedArgCount; i++) {
//                id arg = va_arg(args, id);
//                if (arg) {
//                    [arguments addObject:arg];
//                } else {
//                    [arguments addObject:@""];
//                }
//            }
            localizedString = [[NSString alloc] initWithFormat:localizedFormat arguments:args];
        } else {
            localizedString = localizedFormat;
        }
    } @catch (NSException *exception) {
        NSLog(@"str params format error!!!");
    } @finally {
        va_end(args);
    }
    
    return localizedString;
}

- (void)updateLanguagePackFromServer:(void(^)(BOOL success, NSError *error))completion {
    // Implementation for updating language pack from remote server
    // Here we use a simulated network request
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSDictionary *newLanguagePack = @{
            @"greeting": @"Hello, %@!",
            @"welcome_message": @"Welcome to IM %@, %@. Name is %@."
        };
        [self saveLanguagePack:newLanguagePack forLanguage:self.currentLanguage];
        self->_currentLanguagePack = newLanguagePack;
        if (completion) {
            completion(YES, nil);
        }
    });
}

/**
 * Saves a language pack locally.
 * @param languagePack The language pack dictionary to save.
 * @param languageCode The language code for the pack.
 */
- (void)saveLanguagePack:(NSDictionary *)languagePack forLanguage:(NSString *)languageCode {
    NSString *path = [self languagePackPathForLanguage:languageCode];
    [languagePack writeToFile:path atomically:YES];
}

/**
 * Loads a language pack from local storage.
 * @param languageCode The language code to load.
 * @return The loaded language pack dictionary.
 */
- (NSDictionary *)loadLanguagePackForLanguage:(NSString *)languageCode {
    // First, try to load the language pack set by API
    NSString *path = [self languagePackPathForLanguage:languageCode];
    NSDictionary *languagePack = [NSDictionary dictionaryWithContentsOfFile:path];
    
    if (!languagePack) {
        // If no API-set language pack, try to read the system default language file
        NSBundle *bid = [NSBundle bundleWithIdentifier:@"com.zm.imchat"];
//        NSURL *url = [bid URLForResource:@"Lang" withExtension:@"bundle"];
        NSString *defaultPath = [bid pathForResource:@"en" ofType:@"strings"];
//        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:defaultPath];
//        NSBundle *mBid = [NSBundle bundleWithURL:url];
//        NSString *langBundlePath = [bid pathForResource:url.absoluteString ofType:@"bundle"];
//        NSString *defaultPath = [mBid pathForResource:@"Localizable" ofType:@"strings"];
        if (defaultPath) {
//        NSBundle *bundle = [NSBundle bundleWithPath:defaultPath];
            languagePack = [NSDictionary dictionaryWithContentsOfFile:defaultPath];
        }
        
        // If still no language pack found, read the default Chinese language file
        if (!languagePack) {
//            NSString *chinesePath = [[NSBundle mainBundle] pathForResource:@"zh-Hans" ofType:@"lproj"];
//            if (chinesePath) {
//                NSBundle *chineseBundle = [NSBundle bundleWithPath:chinesePath];
//                languagePack = [NSDictionary dictionaryWithContentsOfFile:[chineseBundle pathForResource:@"Localizable" ofType:@"strings"]];
//            }
        }
    }
    
    return languagePack ?: @{};
}

- (NSString *)languagePackPathForLanguage:(NSString *)languageCode {
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    return [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/lang/%@.plist", languageCode]];
}

- (NSString *)getCurrentDeviceLanguage {
    NSString *languageCode = [[NSLocale preferredLanguages] firstObject];
    // Map language codes as needed, e.g., "zh-Hans-CN" to "zh-Hans"
    if ([languageCode hasPrefix:@"zh-Hans"]) {
        return @"zh-Hans";
    } else if ([languageCode hasPrefix:@"zh-Hant"]) {
        return @"zh-Hant";
    } else if ([languageCode hasPrefix:@"en"]) {
        return @"en";
    }
    // Add mappings for other languages...
    
    return @"zh-Hans"; // Default to Simplified Chinese
}
@end
