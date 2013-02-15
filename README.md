DPToastView
===========

(Yet another) Highly customizable toast view for iOS. This toast view supports simple strings or attributed strings, word wrap, notifications, and much more.

## Usage

Add the dependency to your `Podfile`:

```ruby
platform :ios
pod 'DPToastView'
...
```

Run `pod install` to install the dependencies.

Import the header file:

```objc
#import "DPToastView.h"
```

Make some toast!

```objc
// Show a simple toast.
DPToastView *toast = [DPToastView makeToast:@"I am just a string."];
[toast show];
```

or...

```objc
// Create an attributed string to display.
NSMutableParagraphStyle *parStyle = [[NSMutableParagraphStyle alloc] init];
[parStyle setAlignment:NSTextAlignmentCenter];
[parStyle setLineBreakMode:NSLineBreakByWordWrapping];

NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"I am an attributed toast that is centered and word wrapped."
                                                                        attributes:@{
                                                   NSForegroundColorAttributeName : [UIColor yellowColor],
                                                    NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle),
                                                              NSFontAttributeName : [UIFont boldSystemFontOfSize:24.0],
                                                    NSParagraphStyleAttributeName : parStyle
                                  }];
DPToastView *toast = [DPToastView makeToast:str];
[toast show];
```

Add some default styling with a category:

```objc
// Category on UIViewController...
@interface UIViewController (CustomDPToast)
- (id)makeRedToast:(NSString *)message gravity:(DPToastGravity)gravity duration:(NSTimeInterval)duration;
@end

@implementation UIViewController (CustomDPToast)
- (id)makeRedToast:(NSString *)message gravity:(DPToastGravity)gravity duration:(NSTimeInterval)duration {
    DPToastView *toastView = [DPToastView makeToast:message gravity:gravity duration:duration];
    // Style the toast...
    [toastView setBackgroundColor:[[UIColor redColor] colorWithAlphaComponent:0.8]];
    [toastView setFont:[UIFont boldSystemFontOfSize:20.0]];
    return toastView;
}
@end

// and finally in your view controller...
DPToastView *toast = [self makeRedToast:@"I am a red toast" gravity:DPToastGravityCenter duration:DPToastDurationNormal];
[toast show];

```
## Requirements

`DPToastView` requires iOS 6.x or greater.
Requires ARC and auto-layout.


## License

Usage is provided under the [MIT License](http://http://opensource.org/licenses/mit-license.php).  See LICENSE for the full details.
