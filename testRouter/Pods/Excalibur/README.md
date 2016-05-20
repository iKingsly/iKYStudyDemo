## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

### Register Scheme for Class

Method1: Use Macro Definition, **recommend**

```Objective-C
#import <Excalibur/ECBCalibur.h>

@implementation Class

ECB_EXCALIBUR_ROUTE_SCHEME_FOR_SELF_CLASS(@"scheme")

@end
```

Method2: Use ECB Method

```Objective-C
[ECBCalibur registerScheme:@"scheme" forClass:[ClassName class]];
```

### Mapping
```Objective-C
// Get Class With Scheme(Registered Before)
Class aClass = [ECBCalibur classForScheme:@"scheme"];

// Get Scheme With Class(Registered Before)
NSString *scheme = [ECBCalibur schemeForClass:[ClassName class]];

// Get Instance With Scheme
ClassName *instance = [ECBCalibur instanceForClassScheme:@"scheme"];

// Get Shared Instance With Scheme
ClassName *sharedInstance = [ECBCalibur sharedInstanceForClassScheme:@"scheme"];
```

### Transition

Use ECB Method **recommend**
**Attention**
*pass parameters with dictionary unsupport keypath, do not named key like "view.backgroundColor" etc.*

```Objective-C
[ECBCalibur pushFromNavigationController:self.navigationController
                toViewControllerByScheme:@"scheme"
                              withParams:nil
                                animated:YES];

[ECBCalibur presentViewControllerFromVC:self
               toViewControllerByScheme:@"scheme"
                             withParams:nil
                               animated:YES
                             completion:nil];
```

Use Category Method

```Objective-C
[self.navigationController ecbPushViewControllerByScheme:@"scheme"
                                                animated:YES];

[self ecbPresentViewControllerByScheme:@"scheme"
                              animated:YES
                            completion:nil];
```

## Requirements
* iOS 7.0+

## Installation

Excalibur is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "Excalibur"
```

## Author

cendywang, zhaocheng.wang@ele.me

## License

Excalibur is available under the MIT license. See the LICENSE file for more info.
