//
//  ViewController.m
//  studyRAC
//
//  Created by 郑钦洪 on 16/5/22.
//  Copyright © 2016年 iKingsly. All rights reserved.
//

#import "ViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 1. 输出 ABCDEFG
//    RACSignal *signal = [@"A B C D E F G" componentsSeparatedByString:@" "].rac_sequence.signal;
//    
//    [signal subscribeNext:^(NSString *x) {
//        NSLog(@"%@",x);
//    }];
//
    // 每个信号只会在被订阅的时候发送一次
    {
//    __block unsigned subscription = 0;
//    RACSignal *changeSubscription = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
//        subscription++;
//        [subscriber sendCompleted];
//        return nil;
//    }];
//    
//    // output: 1
//    [changeSubscription subscribeCompleted:^{
//        NSLog(@"%d",subscription);
//    }];
//    
//    // output: 2
//    [changeSubscription subscribeCompleted:^{
//        NSLog(@"%d",subscription);
//    }];
        
    }
    
    // map
    // 输出AA BB CC EE DD FF GG
    {
//       RACSequence *signal = [@"A B C D E F G" componentsSeparatedByString:@" "].rac_sequence;
//       signal = [signal map:^id(NSString* value) {
//           return [value stringByAppendingString:value];
//       }];
//        
//        [signal.signal subscribeNext:^(NSString *value) {
//            NSLog(@"%@",value);
//        }];
    }
    
    // Filtering
    // output : 2 4 6 8
    {
//        RACSequence *numbers = [@"1 2 3 4 5 6 7 8 9" componentsSeparatedByString:@" "].rac_sequence;
//        numbers = [numbers filter:^BOOL(NSString *value) {
//            return value.intValue % 2 == 0;
//        }];
//        
//        [numbers.signal subscribeNext:^(NSString* x) {
//            NSLog(@"%@",x);
//        }];
    }
    
    // Concatenating
    // Output : ABC123
    {
//        RACSequence *letters = [@"A B C" componentsSeparatedByString:@" "].rac_sequence;
//        RACSequence *numbers = [@"1 2 3" componentsSeparatedByString:@" "].rac_sequence;
//        
//        RACSequence *concat = [letters concat:numbers];
//        
//        [concat.signal subscribeNext:^(NSString *x) {
//            NSLog(@"%@",x);
//        }];
    }
    
    //Flattening
    // output: ABC123

//    RACSequence *letters = [@"A B C" componentsSeparatedByString:@" "].rac_sequence;
//    RACSequence *numbers = [@"1 2 3" componentsSeparatedByString:@" "].rac_sequence;
//    RACSequence *combine = @[letters,numbers].rac_sequence;
//    RACSequence *flatten = [combine flatten];
//    [flatten.signal subscribeNext:^(NSString *x) {
//        NSLog(@"%@",x);
//    }];
    
    //next:
    // output : A1BC2
//    RACSubject *letters = [RACSubject subject];
//    RACSubject *numbers = [RACSubject subject];
//    RACSignal *signalOfSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
//        [subscriber sendNext:letters];
//        [subscriber sendNext:numbers];
//        [subscriber sendCompleted];
//        return nil;
//    }];
//    
//    RACSignal *flattend = [signalOfSignal flatten];
//    
//    [signalOfSignal subscribeNext:^(NSString *x) {
//        NSLog(@"%@",x);
//    }];
//    [letters sendNext:@"A"];
//    [numbers sendNext:@"1"];
//    [letters sendNext:@"B"];
//    [letters sendNext:@"C"];
//    [numbers sendNext:@"2"];
    
    // Mapping and flattening
//    RACSequence *numbers = [@"1 2 3 4 5 6 7 8 9" componentsSeparatedByString:@" "].rac_sequence;
//    RACSequence *extended = [numbers map:^RACStream *(NSString *value) {
//        return @[value ,value].rac_sequence;
//    }];
//    
//    RACSequence *newNumbers = [numbers flattenMap:^RACStream *(NSString* value) {
//        if (value.intValue % 2 == 0) {
//            return [RACSequence empty];
//        }else{
//            NSString *num = [value stringByAppendingString:@"_"];
//            return [RACSequence return:num];
//        }
//    }];
//    
//    [extended.signal subscribeNext:^(NSString *next) {
//        NSLog(@"%@",next);
//    }];
//
    
//    RACSignal *letters = [@"A B C D E F G H I " componentsSeparatedByString:@" "].rac_sequence.signal;
//    
//    // 将副作用block注入到之前发送的信号中
//    RACSignal *sequenced = [[letters doNext:^(NSString *letter) {
//        NSLog(@"%@",letters);
//    }]
//    then:^RACSignal *{
//        return [@"1 2 3 4 5 6 7 8 9" componentsSeparatedByString:@" "].rac_sequence.signal;
//    }];
    
//    [letters subscribeNext:^(NSString *x) {
//        NSLog(@"%@",x);
//    }];
    
//    [sequenced subscribeNext:^(NSString *x) {
//        NSLog(@"%@",x);
//    }];
    
    // Merging
//    RACSubject *letters = [RACSubject subject];
//    RACSubject *numbers = [RACSubject subject];
//    RACSignal *merged = [RACSignal merge:@[letters, numbers]];
//    
//    // Output: A 1 B C 2
//    [merged subscribeNext:^(id x) {
//        NSLog(@"%@",x);
//    }];
//    
//    [letters sendNext:@"A"];
//    [numbers sendNext:@"1"];
//    [letters sendNext:@"B"];
//    [letters sendNext:@"C"];
//    [numbers sendNext:@"2"];
    
    //Combining latest values
    // OutPut: B1 B2 C2 C3
//    RACSubject * letters = [RACSubject subject];
//    RACSubject * numbers = [RACSubject subject];
//    RACSignal *combine = [RACSignal combineLatest:@[letters, numbers] reduce:^id(NSString *text , NSString *number){
//        return [text stringByAppendingString:number];
//    }];
//    
//    [combine subscribeNext:^(id x) {
//        NSLog(@"%@",x);
//    }];
//    
//    [letters sendNext:@"A"];
//    [letters sendNext:@"B"];
//    [numbers sendNext:@"1"];
//    [numbers sendNext:@"2"];
//    [letters sendNext:@"C"];
//    [numbers sendNext:@"3"];
    
    // Switching
    // Output: A B 1 D
    /*
     The -switchToLatest operator is applied to
     a signal-of-signals, and always forwards the values from the latest signal:
     Switching 会将其信号中发送的信号，并且总是发送那个最新的信号
     */
//    RACSubject *letters = [RACSubject subject];
//    RACSubject *numbers = [RACSubject subject];
//    RACSubject *signalOfSignals = [RACSubject subject];
//    
//    RACSignal *switched = [signalOfSignals switchToLatest];
//    
//    [switched subscribeNext:^(id x) {
//        NSLog(@"%@",x);
//    }];
//    
//    [signalOfSignals sendNext:letters];
//    [letters sendNext:@"A"];
//    [letters sendNext:@"B"];
//    
//    [signalOfSignals sendNext:numbers];
//    [numbers sendNext:@"1"];
//    [letters sendNext:@"C"];
//    
//    [signalOfSignals sendNext:letters];
//    [numbers sendNext:@"2"];
//    [letters sendNext:@"D"];
    
//    RACSignal *letters = [@"A B C D E F G H I" componentsSeparatedByString:@" "].rac_sequence.signal;
//    // 新的信号包含: 1 2 3 4 5 6 7 8 9
//    //
//    // 但是当订阅产生时,他会打印: A B C D E F G H I
//    RACSignal *sequenced = [[letters
//                             doNext:^(NSString *letter) {
//                                 NSLog(@"%@", letter);
//                             }]
//                            then:^{
//                                return [@"1 2 3 4 5 6 7 8 9" componentsSeparatedByString:@" "].rac_sequence.signal;
//                            }];
//    RACSignal *letters = [@"A B C D E F G H" componentsSeparatedByString:@" "].rac_sequence.signal;
//    letters = [letters doNext:^(id x) {
//        NSLog(@"%@ do next",x);
//    }];
//    
//    [letters subscribeNext:^(NSString *x) {
//        NSLog(@"%@",x);
//    }];
    
//    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
//        [subscriber sendCompleted];
//        return nil;
//    }];
//    signal = [signal doCompleted:^{
//        NSLog(@"the signal complete");
//    }];
//    
//    [signal subscribeNext:^(id x) {
//        
//    }];
//
    
//    RACSubject *letters = [RACSubject subject];
//    RACSubject *numbers = [RACSubject subject];
//    RACSignal *signalOfSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
//        [subscriber sendNext:letters];
//        [subscriber sendNext:numbers];
//        [subscriber sendCompleted];
//        return nil;
//    }];
//
//    RACSignal *flattend = [signalOfSignal flatten];
//
//    [signalOfSignal subscribeNext:^(NSString *x) {
//        NSLog(@"%@",x);
//    }];
//    [letters sendNext:@"A"];
//    [numbers sendNext:@"1"];
//    [letters sendNext:@"B"];
//    [letters sendNext:@"C"];
//    [numbers sendNext:@"2"];
    // 冷信号转化为热信号
//    RACSignal *coldSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
//        NSLog(@"Cold Signal be subscibed");
//        [[RACScheduler mainThreadScheduler] afterDelay:1.5 schedule:^{
//            [subscriber sendNext:@"A"];
//        }];
//        
//        [[RACScheduler mainThreadScheduler] afterDelay:3 schedule:^{
//            [subscriber sendNext:@"B"];
//        }];
//        
//        [[RACScheduler mainThreadScheduler] afterDelay:5 schedule:^{
//            [subscriber sendCompleted];
//        }];
//        
//        return nil;
//    }];
    
    // 1
//    RACSubject *subject = [RACSubject subject];
//    NSLog(@"Subject Created");
//    [[RACScheduler mainThreadScheduler] afterDelay:2 schedule:^{
//        [coldSignal subscribe:subject];
//    }];
//    
//    [subject subscribeNext:^(id x) {
//        NSLog(@"subscribe 1 Receiver value : %@.",x);
//    }];
//    
//    [[RACScheduler mainThreadScheduler] afterDelay:4 schedule:^{
//       [subject subscribeNext:^(id x) {
//           NSLog(@"subscribe 2 Receiver value : %@",x);
//       }];
//    }];
    
    // 2
//    RACSubject *subject = [RACSubject subject];
//    NSLog(@"subject create");
//    
//    RACMulticastConnection *multicastConnection = [coldSignal multicast:subject];
//    RACSignal *hotSignal = multicastConnection.autoconnect;
//    
//    [[RACScheduler mainThreadScheduler] afterDelay:2 schedule:^{
//       [hotSignal subscribeNext:^(id x) {
//           NSLog(@"subscribe 1 Receiver value : %@.",x);
//       }];
//    }];
//   
//    [[RACScheduler mainThreadScheduler] afterDelay:4 schedule:^{
//       [subject subscribeNext:^(id x) {
//           NSLog(@"subscribe 2 Receiver value : %@",x);
//       }];
//    }];
//    
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Alert" delegate:nil cancelButtonTitle:@"YES" otherButtonTitles:@"NO", nil];
//    [[alertView rac_buttonClickedSignal] subscribeNext:^(NSNumber *indexNumber) {
//        if ([indexNumber intValue] == 1) {
//            NSLog(@"You touch no button");
//        }else{
//            NSLog(@"You touch Yes button");
//        }
//        
//    }];
////    [alertView show];
//    NSArray *array = @[@(1)];
//    [[array rac_willDeallocSignal] subscribeCompleted:^{
//        NSLog(@"oops, i will be gone");
//    }];
//    array = nil;
//    
//    [self test];
    
//    RACSubject *letters = [RACSubject subject];
//    RACSubject *numbers = [RACSubject subject];
//    RACSignal *signalOfSignals = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
//        [subscriber sendNext:letters];
//        [subscriber sendNext:numbers];
//        [subscriber sendCompleted];
//        return nil;
//    }];
//    [[signalOfSignals flatten] subscribeNext:^(id x) {
//        NSLog(@"%@",x);
//    }];
//    [letters sendNext:@"A"];
//    [numbers sendNext:@1];
//    [letters sendNext:@"B"];
    
    // 避免重复发送消息
//    RACSubject *letters = [RACSubject subject];
//    RACSignal *signal = [letters replay];
//    
//    NSLog(@"subscribe S1");
//    
//    [signal subscribeNext:^(id x) {
//        NSLog(@"S1: %@",x);
//    }];
//    
//    NSLog(@"A Send");
//    [letters sendNext:@"A"];
//    NSLog(@"B Send");
//    [letters sendNext:@"B"];
//    
//    NSLog(@"subscribe S2");
//    
//    [signal subscribeNext:^(id x) {
//        NSLog(@"S2: %@",x);
//    }];
//    
//    [letters sendNext:@"C"];
//    NSLog(@"subscribe S3");
//    [signal subscribeNext:^(id x) {
//        NSLog(@"S3: %@",x);
//    }];
    
//    __block int num = 0;
//    RACSignal *signal = [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
//        num++;
//        NSLog(@"Increment num to : %d", num);
//        [subscriber sendNext:@(num)];
//        return nil;
//    }] replay];
//    
//    NSLog(@"Start subscriptions");
//    
//    // subscriber 1
//    [signal subscribeNext:^(id x) {
//        NSLog(@"S1 : %@", x);
//    }];
//    
//    [signal subscribeNext:^(id x) {
//        NSLog(@"S2 : %@",x);
//    }];
//    
//    [signal subscribeNext:^(id x) {
//        NSLog(@"S3 : %@", x);
//    }];
    
    RACSubject *letters = [RACSubject subject];
    RACSignal *sginal = [letters replayLast];
    NSLog(@"Subscribe S1");
    [sginal subscribeNext:^(id x) {
        NSLog(@"S1 : %@",x);
    }];
    
    NSLog(@"A send");
    [letters sendNext:@"A"];
    NSLog(@"B send");
    [letters sendNext:@"B"];
    
    // subscribe 2
    NSLog(@"subscribe S2");
    [sginal subscribeNext:^(id x) {
        NSLog(@"S2 : %@",x);
    }];
    
    NSLog(@"Send C");
    [letters sendNext:@"C"];
    NSLog(@"Subsribe S3");
     [sginal subscribeNext:^(id x) {
        NSLog(@"S3 : %@",x);
     }];
    
    NSLog(@"Send D");
    [letters sendNext:@"D"];
}

- (void)test{
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        double delayInSeconds = 2.0;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [subscriber sendNext:@"A"];
            [subscriber sendNext:@"B"];
        });
        return nil;
    }];
    
    RACSignal *signalB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"B"];
        [subscriber sendNext:@"other B"];
        [subscriber sendCompleted];
        return nil;
    }];
    
    [self rac_liftSelector:@selector(doA:withB:) withSignals:signalA,signalB, nil];
}

- (void)doA:(NSString *)A withB:(NSString *)B{
    NSLog(@"A %@ B %@",A,B);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
