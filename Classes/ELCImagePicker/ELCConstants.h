//
//  ELCConstants.h
//  ELCImagePickerDemo
//
//  Created by synerzip on 08/10/15.
//  Copyright © 2015 ELC Technologies. All rights reserved.
//

#ifndef ELCConstants_h
#define ELCConstants_h

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define IS_IOS8 SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")

#endif /* ELCConstants_h */
