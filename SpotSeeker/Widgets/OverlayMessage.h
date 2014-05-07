//
//  OverlayMessage.h
//  SpaceScout
//
//  Created by Patrick Michaud on 3/12/14.
//
//

#import <UIKit/UIKit.h>

@interface OverlayMessage : NSObject {
    
}

-(void)addTo:(UIView *)view;
-(void)showOverlay:(NSString *)text animateDisplay:(BOOL)animate_display afterShowBlock:(void (^)(void))showCallback;
-(void)hideOverlayAfterDelay:(NSTimeInterval)delay animateHide:(BOOL)animate_hide afterHideBlock:(void (^)(void))hideCallback;
-(void)setImage:(UIImage *)image;
-(void)showActivityIndicator;
-(void)hideActivityIndicator;

@property (nonatomic, retain) UIView *overlay;

@end
