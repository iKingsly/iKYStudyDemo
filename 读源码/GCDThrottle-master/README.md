# GCDThrottle
A lightweight GCD wrapper to throttling frequent method calling

# Purpose
Throttling frequent method calling with a threshold time interval, for example text searching.

# Usage

```objc
#import "ViewController.h"
#import "GCDThrottle.h"

@implementation ViewController

- (IBAction)textFieldValueChanged:(UITextField *)sender {
    
    dispatch_throttle(0.3, ^{
        NSLog(@"search: %@", sender.text);
    });
    
    dispatch_throttle_on_queue(0.3, THROTTLE_GLOBAL_QUEUE, ^{
        NSLog(@"search: %@", sender.text);
    });
    
    [GCDThrottle throttle:0.3 block:^{
        NSLog(@"search: %@", sender.text);
    }];
    
    [GCDThrottle throttle:0.3 queue:THROTTLE_GLOBAL_QUEUE block:^{
        NSLog(@"search: %@", sender.text);
    }];
}

@end
```

# That's all
