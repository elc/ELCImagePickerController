//
//  UIAlertController+Extensions.m
//  ELCImagePickerDemo
//
//  Created by Alin Baciu on 03/12/2017.
//  Copyright © 2017 ELC Technologies. All rights reserved.
//

#import "UIAlertController+Extensions.h"


@implementation UIAlertController (Extensions)

+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)message cancelButton:(NSString *)cancel fromController:(UIViewController*)controller {
    UIAlertController* alertView = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    if (cancel.length > 0) {
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancel style:UIAlertActionStyleCancel handler:nil];
        [alertView addAction:cancelAction];
    }
    
    [alertView showAlertFromController:controller completion:nil];
}

- (void)showAlertFromController:(UIViewController *)controller completion:(void (^)(void))completion {
    self.popoverPresentationController.sourceView = controller.view;
    self.popoverPresentationController.sourceRect = controller.view.frame;
    self.popoverPresentationController.permittedArrowDirections = 0;
    [controller presentViewController:self animated:YES completion:completion];
}

@end
