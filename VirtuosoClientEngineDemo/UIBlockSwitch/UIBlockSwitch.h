//
//  UIBlockSwitch.h
//
//  Created by Josh Pressnell on 3/7/12.
//  Copyright (c) 2012 Verietas Software. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^SwitchBlock)(Boolean newValue);

@interface UIBlockSwitch : UISwitch

+ (UIBlockSwitch*)switchWithState:(Boolean)initialValue onChange:(SwitchBlock)flipped;

@end
