//
//  UIBlockSwitch.m
//
//  Created by Josh Pressnell on 3/7/12.
//  Copyright (c) 2012 Verietas Software. All rights reserved.
//

#import "UIBlockSwitch.h"

@interface UIBlockSwitch()
{
    SwitchBlock changeBlock;
}

@property (nonatomic,copy) SwitchBlock changeBlock;

@end

@implementation UIBlockSwitch

@synthesize changeBlock;

- (void)dealloc
{
    self.changeBlock = nil;
    [super dealloc];
}

+ (UIBlockSwitch*)switchWithState:(Boolean)initialValue onChange:(SwitchBlock)flipped
{
    UIBlockSwitch* theSwitch = [[[UIBlockSwitch alloc]initWithFrame:CGRectZero]autorelease];
    [theSwitch addTarget:theSwitch action:@selector(switchWasFlipped) forControlEvents:UIControlEventValueChanged];
    theSwitch.on = initialValue;
    theSwitch.changeBlock = flipped;
    return theSwitch;
}

- (void)switchWasFlipped
{
    if( changeBlock != nil )
        changeBlock(self.on);
}

@end
