//
//  UITextFieldWithKeypress.h
//  SpaceScout
//
//  Created by pmichaud on 4/13/14.
//
//

#import <UIKit/UIKit.h>

@protocol UITextFieldKeyPressDelegate;

@interface UITextFieldWithKeypress : UITextField {
}

@property (nonatomic, retain) IBOutlet id <UITextFieldKeyPressDelegate> kp_delegate;
@property (nonatomic) BOOL hide_cursor;
-(void)hideCursor;
-(void)showCursor;

@end

@protocol UITextFieldKeyPressDelegate <NSObject>

-(void)preChangeKeyEvent:(UITextFieldWithKeypress *)textField;
-(void)onTouchEvent:(UITextFieldWithKeypress *)textField;

@end