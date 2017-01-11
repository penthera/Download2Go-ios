/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

typedef void (^ResponseBlock)(NSString* response);

@interface ModalAlert : NSObject

+(void) textQueryWith: (NSString *)question prompt: (NSString *)prompt button1: (NSString *)button1 button2:(NSString *) button2 keyboardType:(UIKeyboardType)kbType withAutoCapitalization:(UITextAutocapitalizationType)autoCapType withSecureTextEntry:(Boolean)isSecure initialValue:(NSString*)initialValue onResponse:(ResponseBlock)responseBlock;

+ (void) ask: (NSString *) question withTextPrompt: (NSString *) prompt withKeyboardType: (UIKeyboardType) kbType withAutoCapitalization:(UITextAutocapitalizationType)autoCapType withSecureTextEntry:(Boolean)isSecure withInitialValue:(NSString*)initialValue onResponse:(ResponseBlock)responseBlock;

+ (void) ask: (NSString *) question withTextPrompt: (NSString *) prompt withKeyboardType: (UIKeyboardType) kbType withAutoCapitalization:(UITextAutocapitalizationType)autoCapType withSecureTextEntry:(Boolean)isSecure onResponse:(ResponseBlock)responseBlock;

+ (void) ask: (NSString *) question withTextPrompt: (NSString *) prompt withKeyboardType: (UIKeyboardType) kbType withAutoCapitalization:(UITextAutocapitalizationType)autoCapType onResponse:(ResponseBlock)responseBlock;

+ (void) ask: (NSString *) question withTextPrompt: (NSString *) prompt withKeyboardType: (UIKeyboardType) kbType onResponse:(ResponseBlock)responseBlock;

+ (void) ask: (NSString *) question withTextPrompt: (NSString *) prompt onResponse:(ResponseBlock)responseBlock;

+ (void) ask: (NSString *) question withTextPrompt: (NSString *) prompt withInitialValue:(NSString*)initialValue onResponse:(ResponseBlock)responseBlock;

+ (void) setAllowsNilResponse:(Boolean)allowNil;

@end
