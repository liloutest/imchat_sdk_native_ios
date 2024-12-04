//
//  ZMLanguageManager.h
//  imchat
//
//  Created by Lilou on 2024/10/15.
//

#import <Foundation/Foundation.h>

/**
 @brief iOS dynamic multi-language solution implementation
 */
@interface ZMLanguageManager : NSObject
/// Current language code
@property (nonatomic, strong, readonly) NSString *currentLanguage;
/// Current language string data
@property (nonatomic, strong, readonly) NSDictionary *currentLanguagePack;

/**
 * Returns the shared instance of ZMLanguageManager.
 * @return The singleton instance.
 */
+ (instancetype)sharedInstance;

/**
 * Sets the current language.
 * @param languageCode The language code to set.
 */
- (void)setCurrentLanguage:(NSString *)languageCode;

/**
 * Gets the localized string for a given key with variable parameters.
 * @param key The key for the localized string.
 * @param ... Variable arguments to be inserted into the localized string.
 * @return The localized string with parameters inserted.
 */
- (NSString *)localizedStringForKey:(NSString *)key, ...;

/**
 * Updates the language pack from the remote server.
 * @param completion A block to be executed when the update is complete.
 */
- (void)updateLanguagePackFromServer:(void(^)(BOOL success, NSError *error))completion;


/**
 * Gets the current device system language.
 * @return The current device language code.
 */
- (NSString *)getCurrentDeviceLanguage;

@end
