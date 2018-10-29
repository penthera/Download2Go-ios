//
//  MKBlockAdditions.h
//  UIKitCategoryAdditions
//
//  Created by Mugunth on 21/03/11.
//  Copyright 2011 Steinlogic All rights reserved.
//

typedef void (^VoidBlock)(void);

typedef void (^DismissBlock)(id obj, int buttonIndex);
typedef void (^CancelBlock)(void);
typedef void (^PhotoPickedBlock)(UIImage *chosenImage);

#define kPhotoActionSheetTag 10000
