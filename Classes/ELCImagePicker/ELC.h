@interface ELC : NSObject

+ (void)setAlwaysUseMainBundle:(BOOL)alwaysUseMainBundle;
+ (NSBundle *)bundle;
+ (NSString *)LocalizedString:(NSString *)key;

@end
