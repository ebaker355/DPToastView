//
//  DPToastView.h
//  DPToastViewDemo
//
//  Created by Baker, Eric on 2/15/13.
//  Copyright (c) 2013 DuneParkSoftware, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    DPToastGravityTop = 0,
    DPToastGravityCenter,
    DPToastGravityBottom
} DPToastGravity;

typedef enum {
    DPToastDurationShort = 2,
    DPToastDurationNormal = 4,
    DPToastDurationLong = 10,
    DPToastDurationInfinite = NSIntegerMax
} DPToastDuration;

#define DPToastViewWillAppearNotification       @"DPToastViewWillAppearNotificatio"
#define DPToastViewDidAppearNotification        @"DPToastViewDidAppearNotification"
#define DPToastViewWillDisappearNotification    @"DPToastViewWillDisappearNotification"
#define DPToastViewDidDisappearNotification     @"DPToastViewDidDisappearNotification"
#define DPToastViewDidDismissNotification       @"DPToastViewDidDismissNotification"

#define DPToastViewUserInfoKey                  @"DPToastViewUserInfoKey"
#define DPToastViewStringUserInfoKey            @"DPToastViewStringUserInfoKey"

@interface DPToastView : NSObject

@property (strong, nonatomic) id message;
@property (assign, nonatomic) NSTextAlignment textAlignment;
@property (assign, nonatomic) NSLineBreakMode lineBreakMode;
@property (assign, nonatomic) DPToastGravity gravity;
@property (assign, nonatomic) NSTimeInterval duration;
@property (strong, nonatomic) UIColor *textColor, *backgroundColor, *borderColor, *shadowColor;
@property (strong, nonatomic) UIFont *font;
@property (assign, nonatomic) CGFloat borderWidth, cornerRadius, shadowOpacity, shadowRadius, fadeInDuration, fadeOutDuration;
@property (assign, nonatomic) CGSize shadowOffset;
@property (assign, nonatomic) UIEdgeInsets innerEdgeInsets;
@property (assign, nonatomic) NSInteger yOffset;

+ (id)makeToast:(id)message;
+ (id)makeToast:(id)message gravity:(DPToastGravity)gravity;
+ (id)makeToast:(id)message duration:(NSTimeInterval)duration;
+ (id)makeToast:(id)message gravity:(DPToastGravity)gravity duration:(NSTimeInterval)duration;

+ (void)dismissToast;

- (void)show;
- (void)showInView:(UIView *)view;

@end
