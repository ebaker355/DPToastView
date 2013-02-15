//
//  DPToastView.m
//  DPToastViewDemo
//
//  Created by Baker, Eric on 2/15/13.
//  Copyright (c) 2013 DuneParkSoftware, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "DPToastView.h"

static id _DP_PreviousToastView = nil;

@interface DPToastView ()
@property (strong, nonatomic) UIView *toastView;
@property (assign, nonatomic) BOOL cancelNotifications;
@end

@implementation DPToastView
@synthesize message;
@synthesize textAlignment;
@synthesize lineBreakMode;
@synthesize gravity;
@synthesize duration;
@synthesize textColor, backgroundColor, borderColor, shadowColor;
@synthesize font;
@synthesize borderWidth, cornerRadius, shadowOpacity, shadowRadius, fadeInDuration, fadeOutDuration;
@synthesize shadowOffset;
@synthesize innerEdgeInsets;
@synthesize yOffset;

@synthesize toastView;
@synthesize cancelNotifications;

+ (id)makeToast:(id)message {
    return [[self class] makeToast:message gravity:DPToastGravityBottom duration:DPToastDurationNormal];
}

+ (id)makeToast:(id)message gravity:(DPToastGravity)gravity {
    return [[self class] makeToast:message gravity:gravity duration:DPToastDurationNormal];
}

+ (id)makeToast:(id)message duration:(NSTimeInterval)duration {
    return [[self class] makeToast:message gravity:DPToastGravityBottom duration:duration];
}

+ (id)makeToast:(id)message gravity:(DPToastGravity)gravity duration:(NSTimeInterval)duration {
    return [[[self class] alloc] initWithMessage:message gravity:gravity duration:duration];
}

+ (void)dismissToast {
    if (_DP_PreviousToastView) {
        [[_DP_PreviousToastView toastView] removeFromSuperview];
        [[NSNotificationCenter defaultCenter] postNotificationName:DPToastViewDidDismissNotification object:_DP_PreviousToastView userInfo:@{ DPToastViewUserInfoKey : _DP_PreviousToastView, DPToastViewStringUserInfoKey : [_DP_PreviousToastView messageString] }];
        _DP_PreviousToastView = nil;
    }
}

- (id)initWithMessage:(id)theMessage gravity:(DPToastGravity)theGravity duration:(NSTimeInterval)theDuration {
    if ((self = [super init])) {
        [self setMessage:theMessage];
        [self setTextAlignment:NSTextAlignmentCenter];
        [self setLineBreakMode:NSLineBreakByWordWrapping];
        [self setGravity:theGravity];
        [self setDuration:theDuration];
        [self setTextColor:[UIColor whiteColor]];
        [self setFont:[UIFont systemFontOfSize:16.0]];
        [self setBackgroundColor:[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.8]];
        [self setBorderColor:[[UIColor whiteColor] colorWithAlphaComponent:0.8]];
        [self setBorderWidth:1.5];
        [self setCornerRadius:4.0];
        [self setShadowColor:[UIColor blackColor]];
        [self setShadowOpacity:0.8];
        [self setShadowRadius:5.0];
        [self setShadowOffset:CGSizeZero];
        [self setInnerEdgeInsets:UIEdgeInsetsMake(6, 10, 6, 10)];
        [self setYOffset:60];
        [self setFadeInDuration:0.15];
        [self setFadeOutDuration:0.5];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toastWasDismissed:) name:DPToastViewDidDismissNotification object:self];
        [self setCancelNotifications:NO];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)show {
    UIView *view = [[[[UIApplication sharedApplication] keyWindow] rootViewController] view];
    [self showInView:view];
}

- (void)showInView:(UIView *)view {
    if (nil == view) return;

    if (nil != _DP_PreviousToastView) {
        [DPToastView dismissToast];
        [self setFadeInDuration:0.0];
    }

    [self buildToastViewForView:view];
    if (nil == toastView) return;

    [[NSNotificationCenter defaultCenter] postNotificationName:DPToastViewWillAppearNotification object:self userInfo:@{ DPToastViewUserInfoKey : self, DPToastViewStringUserInfoKey : [self messageString] }];

    [toastView setAlpha:0.0];
    _DP_PreviousToastView = self;
    [UIView animateWithDuration:[self fadeInDuration]
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [toastView setAlpha:1.0];
                     }
                     completion:^(BOOL finished) {
                         if (NO == [self cancelNotifications]) {
                             [[NSNotificationCenter defaultCenter] postNotificationName:DPToastViewDidAppearNotification object:self userInfo:@{ DPToastViewUserInfoKey : self, DPToastViewStringUserInfoKey : [self messageString] }];
                         }

                         if (finished) {
                             [self performSelector:@selector(postWillDisappearNotification:) withObject:self afterDelay:[self duration]];

                             [UIView animateWithDuration:[self fadeOutDuration]
                                                   delay:[self duration]
                                                 options:UIViewAnimationOptionCurveEaseIn
                                              animations:^{
                                                  [toastView setAlpha:0.0];
                                              }
                                              completion:^(BOOL finished) {

                                                  if (finished) {
                                                      [toastView removeFromSuperview];
                                                      _DP_PreviousToastView = nil;
                                                      if (NO == [self cancelNotifications]) {
                                                          [[NSNotificationCenter defaultCenter] postNotificationName:DPToastViewDidDisappearNotification object:self userInfo:@{ DPToastViewUserInfoKey : self, DPToastViewStringUserInfoKey : [self messageString] }];
                                                      }
                                                  }
                                              }];
                         }
                     }];
}

- (NSString *)messageString {
    if ([[self message] isKindOfClass:[NSString class]]) {
        return (NSString *)[self message];
    } else if ([[self message] isKindOfClass:[NSAttributedString class]]) {
        return [(NSAttributedString *)[self message] string];
    }
    return nil;
}

- (void)toastWasDismissed:(NSNotification *)notification {
    [self setCancelNotifications:YES];
}

- (void)postWillDisappearNotification:(id)sender {
    if (NO == [self cancelNotifications]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:DPToastViewWillDisappearNotification object:self userInfo:@{ DPToastViewUserInfoKey : self, DPToastViewStringUserInfoKey : [self messageString] }];
    }
}

#pragma mark - Internal methods

- (UIView *)buildToastViewForView:(UIView *)parentView {
    UILabel *label = nil;
    if ([self message]) {
        if ([[self message] isKindOfClass:[NSString class]]) {
            if ([[(NSString *)message stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] > 0) {
                label = [[UILabel alloc] init];
                [label setText:(NSString *)message];
                [label setTextColor:[self textColor]];
                [label setTextAlignment:[self textAlignment]];
                [label setLineBreakMode:[self lineBreakMode]];
                [label setFont:[self font]];
            }
        } else if ([[self message] isKindOfClass:[NSAttributedString class]]) {
            if ([[[(NSAttributedString *)message string] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] > 0) {
                label = [[UILabel alloc] init];
                [label setAttributedText:(NSAttributedString *)message];
            }
        }
    }
    if (nil == label) return nil;

    [label setBackgroundColor:[UIColor clearColor]];
    [label setNumberOfLines:0];
    [label setUserInteractionEnabled:NO];

    [self setToastView:[[UIView alloc] init]];

    [toastView setBackgroundColor:[self backgroundColor]];
    [toastView setUserInteractionEnabled:NO];
    [toastView.layer setBorderColor:[[self borderColor] CGColor]];
    [toastView.layer setBorderWidth:[self borderWidth]];
    [toastView.layer setCornerRadius:[self cornerRadius]];
    [toastView.layer setShadowColor:[[self shadowColor] CGColor]];
    [toastView.layer setShadowOpacity:[self shadowOpacity]];
    [toastView.layer setShadowRadius:[self shadowRadius]];
    [toastView.layer setShadowOffset:[self shadowOffset]];

    [toastView addSubview:label];
    [parentView addSubview:toastView];
    [parentView bringSubviewToFront:toastView];
    
    [label setTranslatesAutoresizingMaskIntoConstraints:NO];
    [toastView setTranslatesAutoresizingMaskIntoConstraints:NO];

    NSNumber *maxWidth = @(floor(parentView.frame.size.width * 0.9) - self.innerEdgeInsets.left - self.innerEdgeInsets.right - (2.0 * self.borderWidth)), *maxHeight;
    CGSize size = [label sizeThatFits:CGSizeMake([maxWidth floatValue], 0.0)];
    maxWidth = @(size.width);
    maxHeight = @(size.height);

    [toastView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-==%d-[label(==%@)]-==%d-|", (int)self.innerEdgeInsets.left, maxWidth, (int)self.innerEdgeInsets.right]
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(label)]];
    [toastView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-==%d-[label(==%@)]-==%d-|", (int)self.innerEdgeInsets.top, maxHeight, (int)self.innerEdgeInsets.bottom]
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(label)]];

    [parentView addConstraint:[NSLayoutConstraint constraintWithItem:toastView
                                                           attribute:NSLayoutAttributeCenterX
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:parentView
                                                           attribute:NSLayoutAttributeCenterX
                                                          multiplier:1.0
                                                            constant:0.0]];
    switch ([self gravity]) {
        case DPToastGravityTop: {
            [parentView addConstraint:[NSLayoutConstraint constraintWithItem:toastView
                                                                   attribute:NSLayoutAttributeTop
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:parentView
                                                                   attribute:NSLayoutAttributeTop
                                                                  multiplier:1.0
                                                                    constant:ABS(self.yOffset)]];
        }
            break;

        case DPToastGravityCenter: {
            [parentView addConstraint:[NSLayoutConstraint constraintWithItem:toastView
                                                                   attribute:NSLayoutAttributeCenterY
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:parentView
                                                                   attribute:NSLayoutAttributeCenterY
                                                                  multiplier:1.0
                                                                    constant:self.yOffset]];
        }
            break;

        case DPToastGravityBottom: {
            [parentView addConstraint:[NSLayoutConstraint constraintWithItem:toastView
                                                                   attribute:NSLayoutAttributeBottom
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:parentView
                                                                   attribute:NSLayoutAttributeBottom
                                                                  multiplier:1.0
                                                                    constant:(ABS(self.yOffset) * -1)]];
        }
            break;
    }
    
    return toastView;
}

@end
