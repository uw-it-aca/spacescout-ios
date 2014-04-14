//
//  UITextFieldWithKeypress.m
//  SpaceScout
//
//  Created by pmichaud on 4/13/14.
//
//

#import "UITextFieldWithKeypress.h"

@implementation UITextFieldWithKeypress

@synthesize kp_delegate;
@synthesize hide_cursor;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)showCursor {
    self.hide_cursor = FALSE;
}

-(void)hideCursor {
    self.hide_cursor = TRUE;
}

- (CGRect)caretRectForPosition:(UITextPosition *)position {
    if (self.hide_cursor) {
        return CGRectZero;
    }
    return [super caretRectForPosition:position];
}

-(void)deleteBackward {
    [self.kp_delegate preChangeKeyEvent:self];
    [super deleteBackward];
}


-(void)insertText:(NSString *)text {
    [self.kp_delegate preChangeKeyEvent:self];
    [super insertText:text];
}

// Having the tap listener in the table view wasn't reliable, maybe 20-50% effective
-(void)addGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
    [super addGestureRecognizer:gestureRecognizer];
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        UITapGestureRecognizer *tgr = (UITapGestureRecognizer *)gestureRecognizer;
        if ([tgr numberOfTapsRequired] == 1 &&
            [tgr numberOfTouchesRequired] == 1) {
            // If found then add self to its targets/actions
            [tgr addTarget:self action:@selector(handleTap:)];
        }
    }
}

-(void)handleTap:(id)selector {
    [self.kp_delegate onTouchEvent:self];
}

// Keep the formatting menu from showing up:
-(BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (action == @selector(paste:)) {
        return TRUE;
    }
    return FALSE;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
