/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

/*
 Thanks to Kevin Ballard for suggesting the UITextField as subview approach
 All credit to Kenny TM. Mistakes are mine. 
 To Do: Ensure that only one runs at a time -- is that possible?
 */

#import "ModalAlert.h"
#import <stdarg.h>

#define TEXT_FIELD_TAG	9999

static Boolean allowsNil = YES;

@interface ModalAlertDelegate : NSObject <UIAlertViewDelegate, UITextFieldDelegate> 
{
}
@property (assign) NSUInteger index;
@property (strong) NSString *text;
@property (copy) ResponseBlock responseBlock;
@end

@implementation ModalAlertDelegate

-(id) initWithResponseBlock:(ResponseBlock)block
{
	if (self = [super init])
    {
        self.responseBlock = block;
    }
	return self;
}

// User pressed button. Retrieve results
-(void)alertView:(UIAlertView*)aView clickedButtonAtIndex:(NSInteger)anIndex 
{
	UITextField *tf = (UITextField *)[aView textFieldAtIndex:0];
    if( !allowsNil && (tf.text.length == 0 || anIndex == aView.cancelButtonIndex) )
        return;
    
	if (tf) self.text = tf.text;
	self.index = anIndex;
    if( self.responseBlock != nil )
    {
        if( self.index == 0 )
            self.responseBlock(nil);
        else
            self.responseBlock(self.text);
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	UITextField *tf = (UITextField *)[alertView textFieldAtIndex:0];
    if( !allowsNil && (tf.text.length == 0 || buttonIndex == alertView.cancelButtonIndex) )
    {
        [alertView show];
        [tf becomeFirstResponder];
    }
}

- (BOOL) isLandscape
{
	return ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft) || ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight);
}

// Move alert into place to allow keyboard to appear
- (void) moveAlert: (UIAlertView *) alertView
{
    if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        CGContextRef context = UIGraphicsGetCurrentContext();
        [UIView beginAnimations:nil context:context];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:0.25f];
        if (![self isLandscape])
            alertView.center = CGPointMake(160.0f, 150.0f);
        else 
            alertView.center = CGPointMake(240.0f, 90.0f);
        [UIView commitAnimations];
    }
	
	[[alertView viewWithTag:TEXT_FIELD_TAG] becomeFirstResponder];
}

@end

@implementation ModalAlert

+ (void)setAllowsNilResponse:(Boolean)allowNil
{
    allowsNil = allowNil;
}

+(void) textQueryWith: (NSString *)question prompt: (NSString *)prompt button1: (NSString *)button1 button2:(NSString *) button2 keyboardType:(UIKeyboardType)kbType withAutoCapitalization:(UITextAutocapitalizationType)autoCapType withSecureTextEntry:(Boolean)isSecure initialValue:(NSString *)initialValue onResponse:(ResponseBlock)responseBlock
{
	// Create alert
	ModalAlertDelegate *madelegate = [[ModalAlertDelegate alloc] initWithResponseBlock:responseBlock];
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:question message:@"\n" delegate:madelegate cancelButtonTitle:button1 otherButtonTitles:button2, nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;

	// Build text field
	UITextField *tf = [alertView textFieldAtIndex:0];
	tf.tag = TEXT_FIELD_TAG;
	tf.placeholder = prompt;
	tf.clearButtonMode = UITextFieldViewModeWhileEditing;
	tf.keyboardType = kbType;
	tf.keyboardAppearance = UIKeyboardAppearanceAlert;
	tf.autocapitalizationType = autoCapType;
	tf.autocorrectionType = UITextAutocorrectionTypeNo;
	tf.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    tf.secureTextEntry = isSecure;
    tf.text = initialValue;

	// Show alert and wait for it to finish displaying
	[alertView show];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
	//while (CGRectEqualToRect(alertView.bounds, CGRectZero));
		
	// Set the field to first responder and move it into place
	[madelegate performSelector:@selector(moveAlert:) withObject:alertView afterDelay: 1.0f];
	
    allowsNil = YES;
}

+ (void) ask: (NSString *) question withTextPrompt: (NSString *) prompt withKeyboardType: (UIKeyboardType) kbType withAutoCapitalization:(UITextAutocapitalizationType)autoCapType withSecureTextEntry:(Boolean)isSecure withInitialValue:(NSString *)initialValue onResponse:(ResponseBlock)responseBlock
{
    [ModalAlert textQueryWith:question prompt:prompt button1:@"Cancel" button2:@"OK" keyboardType:kbType withAutoCapitalization:autoCapType withSecureTextEntry:isSecure initialValue:initialValue onResponse:responseBlock];
}

+ (void) ask: (NSString *) question withTextPrompt: (NSString *) prompt withKeyboardType: (UIKeyboardType) kbType withAutoCapitalization:(UITextAutocapitalizationType)autoCapType withSecureTextEntry:(Boolean)isSecure onResponse:(ResponseBlock)responseBlock
{
    [ModalAlert textQueryWith:question prompt:prompt button1:@"Cancel" button2:@"OK" keyboardType:kbType withAutoCapitalization:autoCapType withSecureTextEntry:isSecure initialValue:@"" onResponse:responseBlock];
}

+ (void) ask: (NSString *) question withTextPrompt: (NSString *) prompt withKeyboardType: (UIKeyboardType) kbType withAutoCapitalization:(UITextAutocapitalizationType)autoCapType onResponse:(ResponseBlock)responseBlock
{
    [ModalAlert textQueryWith:question prompt:prompt button1:@"Cancel" button2:@"OK" keyboardType:kbType withAutoCapitalization:autoCapType withSecureTextEntry:NO initialValue:@"" onResponse:responseBlock];
}

+ (void) ask: (NSString *) question withTextPrompt: (NSString *) prompt withKeyboardType: (UIKeyboardType) kbType onResponse:(ResponseBlock)responseBlock
{
	[ModalAlert textQueryWith:question prompt:prompt button1:@"Cancel" button2:@"OK" keyboardType:kbType withAutoCapitalization:UITextAutocapitalizationTypeWords withSecureTextEntry:NO initialValue:@"" onResponse:responseBlock];
}

+ (void) ask: (NSString *) question withTextPrompt: (NSString *) prompt withInitialValue:(NSString *)initialValue onResponse:(ResponseBlock)responseBlock
{
    [[self class] ask:question withTextPrompt:prompt withKeyboardType:UIKeyboardTypeAlphabet withAutoCapitalization:UITextAutocapitalizationTypeWords withSecureTextEntry:NO withInitialValue:initialValue onResponse:responseBlock];
}

+ (void) ask: (NSString *) question withTextPrompt: (NSString *) prompt onResponse:(ResponseBlock)responseBlock
{
    return [[self class] ask:question withTextPrompt:prompt withKeyboardType:UIKeyboardTypeAlphabet onResponse:responseBlock];
}

@end

