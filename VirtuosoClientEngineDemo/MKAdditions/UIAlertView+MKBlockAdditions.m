//
//  UIAlertView+MKBlockAdditions.m
//  UIKitCategoryAdditions
//
//  Created by Mugunth on 21/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UIAlertView+MKBlockAdditions.h"

static DismissBlock _dismissBlock;
static CancelBlock _cancelBlock;
static Boolean _isTextQuery;

@implementation UIAlertView (Block)

+ (UIAlertView*) alertViewWithTitle:(NSString*) title                    
                    message:(NSString*) message 
          cancelButtonTitle:(NSString*) cancelButtonTitle
          otherButtonTitles:(NSArray*) otherButtons
                  onDismiss:(DismissBlock) dismissed                   
                   onCancel:(CancelBlock) cancelled
{
    _isTextQuery = NO;
    
    [_cancelBlock release];
    _cancelBlock  = [cancelled copy];

    [_dismissBlock release];
    _dismissBlock  = [dismissed copy];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:[self class]
                                          cancelButtonTitle:cancelButtonTitle
                                          otherButtonTitles:nil];
    
    for(NSString *buttonTitle in otherButtons)
        [alert addButtonWithTitle:buttonTitle];
    
    [alert show];
    return [alert autorelease];
}

+ (UIAlertView*) alertViewWithTitle:(NSString*) title
                            message:(NSString*) message
                       textBoxQuery:(NSString*) query
                        initialText:(NSString*) initialText
                        secureEntry:(Boolean) secure
                       keyboardType:(UIKeyboardType)keyboardType
             autocapitalizationType:(UITextAutocapitalizationType)autocapitalizationType
                  cancelButtonTitle:(NSString*) cancelButtonTitle
                  otherButtonTitles:(NSArray*) otherButtons
                          onDismiss:(DismissBlock) dismissed
                           onCancel:(CancelBlock) cancelled
{
    _isTextQuery = YES;
    
    [_cancelBlock release];
    _cancelBlock  = [cancelled copy];
    
    [_dismissBlock release];
    _dismissBlock  = [dismissed copy];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:[self class]
                                          cancelButtonTitle:cancelButtonTitle
                                          otherButtonTitles:nil];
    
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField* text = [alert textFieldAtIndex:0];
    text.placeholder = query;
    text.text = initialText;
    text.secureTextEntry = secure;
    text.keyboardType = keyboardType;
    text.autocapitalizationType = autocapitalizationType;
    
    for(NSString *buttonTitle in otherButtons)
        [alert addButtonWithTitle:buttonTitle];
    
    [alert show];
    return [alert autorelease];
}

+ (UIAlertView*) alertViewWithTitle:(NSString*) title 
                    message:(NSString*) message
{
    _isTextQuery = NO;
    return [UIAlertView alertViewWithTitle:title 
                                   message:message 
                         cancelButtonTitle:NSLocalizedString(@"Dismiss", @"")];
}

+ (UIAlertView*) alertViewWithTitle:(NSString*) title 
                    message:(NSString*) message
          cancelButtonTitle:(NSString*) cancelButtonTitle
{
    _isTextQuery = NO;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:cancelButtonTitle
                                          otherButtonTitles: nil];
    [alert show];
    return [alert autorelease];
}

+ (void)alertView:(UIAlertView*) alertView didDismissWithButtonIndex:(NSInteger) buttonIndex
{
	if(buttonIndex == [alertView cancelButtonIndex])
	{
		_cancelBlock();
	}
    else
    {
        _dismissBlock(alertView,(int)(buttonIndex - 1)); // cancel button is button 0
    }
}

@end
