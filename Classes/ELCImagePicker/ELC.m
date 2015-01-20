#import "ELC.h"

static BOOL _alwaysUseMainBundle = NO;

@implementation ELC

+ (void)setAlwaysUseMainBundle:(BOOL)alwaysUseMainBundle {
    _alwaysUseMainBundle = alwaysUseMainBundle;
}

+ (NSBundle *)bundle {
    if (_alwaysUseMainBundle) {
        return [NSBundle mainBundle];
    }
    return [NSBundle bundleWithPath:[[NSBundle mainBundle]
                     pathForResource: @"ELCImagePickerController"
                     ofType: @"bundle"]];
}

+ (NSString *)LocalizedString:(NSString *)key {
    return NSLocalizedStringFromTableInBundle(
               key,
               @"ELCImagePickerController",
               [ELC bundle],
               nil);
}

@end
