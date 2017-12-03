//
//  UIAlertController+Extensions.h
//  ELCImagePickerDemo
//
//  Created by Alin Baciu on 03/12/2017.
//  Copyright © 2017 ELC Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertController (Extensions)

+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)message cancelButton:(NSString *)cancel fromController:(UIViewController*)controller;

@end
