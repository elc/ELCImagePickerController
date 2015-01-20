NSString *ELCLocalizedString(NSString *key) {
    return NSLocalizedStringFromTableInBundle(
               key,
               @"ELCImagePickerController",
               [NSBundle bundleWithPath:[[NSBundle mainBundle]
                                         pathForResource:@"ELCImagePickerController"
                                         ofType:@"bundle"]],
               nil);
}
