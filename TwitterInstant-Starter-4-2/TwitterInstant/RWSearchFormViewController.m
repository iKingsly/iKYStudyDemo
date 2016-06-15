//
//  RWSearchFormViewController.m
//  TwitterInstant
//
//  Created by Colin Eberhardt on 02/12/2013.
//  Copyright (c) 2013 Colin Eberhardt. All rights reserved.
//

#import "RWSearchFormViewController.h"
#import "RWSearchResultsViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACEXTScope.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import "RWTweet.h"
#import "NSArray+LinqExtensions.h"
typedef NS_ENUM(NSUInteger, RWTwitterINsttantError) {
    RWTwitterINsttantErrorAccessDenied,
    RWTwitterINsttantErrorNoTwitterAccounts,
    RWTwitterINsttantErrorInvalidResponse
};
static NSString * const RWTwitterInstantDomain = @"TwitterInstant";
@interface RWSearchFormViewController ()

@property (weak, nonatomic) IBOutlet UITextField *searchText;
@property (strong, nonatomic) ACAccountStore *accountStore;
@property (strong, nonatomic) ACAccountType *twitterAccountType;
@property (strong, nonatomic) RWSearchResultsViewController *resultsViewController;

@end

@implementation RWSearchFormViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.title = @"Twitter Instant";
  
  [self styleTextField:self.searchText];
  
  self.resultsViewController = self.splitViewController.viewControllers[1];
    
    @weakify(self);
    [[[[self.searchText rac_textSignal] map:^id(NSString *text) {
        return @(text.length > 2);
    }] map:^id(NSNumber *valid) {
        return [valid boolValue] ? [UIColor cyanColor] : [UIColor yellowColor];
    }] subscribeNext:^(UIColor *bgColor) {
        @strongify(self);
        self.searchText.backgroundColor = bgColor;
    }];
  
    self.accountStore = [[ACAccountStore alloc] init];
    self.twitterAccountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
//   [[[[[[self requestAccessToTwitterSignal]
//        then:^RACSignal *{
//            @strongify(self)
//            return self.searchText.rac_textSignal;
//        }]
//       filter:^BOOL(NSString *text) {
//           @strongify(self)
//           return [self isValidSearchText:text];
//       }]
//      flattenMap:^RACStream *(NSString *text ) {
//          @strongify(self)
//          return [self signalForSearchWithText:text];
//      }]
//     deliverOn:[RACScheduler mainThreadScheduler]]
//     subscribeNext:^(id x) {
//         NSLog(@"%@", x);
//     } error:^(NSError *error) {
//         NSLog(@"An error occurred: %@", error);
//     }];
    sleep(2);
    [[[[[self.searchText rac_textSignal] filter:^BOOL(id value) {
        return [self isValidSearchText:value];
    }] flattenMap:^RACStream *(id value) {
        @strongify(self);
        return [self signalForSearchWithText:value];
    }]
      deliverOn:[RACScheduler mainThreadScheduler]]
     subscribeNext:^(NSDictionary *jsonSearchResult) {
         NSArray *statuses = jsonSearchResult[@"statuses"];
         NSArray *tweets = [statuses linq_select:^id(id item) {
             return [RWTweet tweetWithStatus:item];
         }];
         [self.resultsViewController displayTweets:tweets];
    }];
}

- (RACSignal *)requestAccessToTwitterSignal {
    // 定义一个错误
    NSError *accessErrot = [NSError errorWithDomain:RWTwitterInstantDomain code:RWTwitterINsttantErrorAccessDenied userInfo:nil];
    
    // 创建并且返回信号
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        [self.accountStore requestAccessToAccountsWithType:self.twitterAccountType options:nil completion:^(BOOL granted, NSError *error) {
            // 1. 处理响应
            if (!granted) {
                [subscriber sendError:accessErrot];
            } else {
                [subscriber sendNext:nil];
                [subscriber sendCompleted];
            }
        }];
        return nil;
    }];
}
- (BOOL)isValidSearchText:(NSString *)text
{
    return text.length > 2;
}

- (void)styleTextField:(UITextField *)textField {
  CALayer *textFieldLayer = textField.layer;
  textFieldLayer.borderColor = [UIColor grayColor].CGColor;
  textFieldLayer.borderWidth = 2.0f;
  textFieldLayer.cornerRadius = 0.0f;
}


- (SLRequest *)requestforTwitterSearchWithText:(NSString *)text
{
    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/search/tweets.json"];
    NSDictionary *params = @{@"q": text};
    
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                            requestMethod:SLRequestMethodGET
                                                      URL:url
                                               parameters:params];
    return request;
}


- (RACSignal *)signalForSearchWithText:(NSString *)text {
    // 定义错误
    NSError *noAccountError = [NSError errorWithDomain:RWTwitterInstantDomain code:RWTwitterINsttantErrorNoTwitterAccounts userInfo:nil];
    
    NSError *invalidResponseError = [NSError errorWithDomain:RWTwitterInstantDomain code:RWTwitterINsttantErrorInvalidResponse userInfo:nil];
    
    // 创建信号block
    @weakify(self)
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        
        // 创建请求
        SLRequest *request = [self requestforTwitterSearchWithText:text];
        
        // 提供Twitter账户
        NSArray *twitterAccounts = [self.accountStore accountsWithAccountType:self.twitterAccountType];
        if (twitterAccounts.count == 0) {
            [subscriber sendError:noAccountError];
        } else {
            [request setAccount:[twitterAccounts lastObject]];
            
            // 执行请求
            [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                if (urlResponse.statusCode == 200) {
                    // 成功，解析响应
                    NSDictionary *timelineData = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:nil];
                    [subscriber sendNext:timelineData];
                    [subscriber sendCompleted];
                } else {
                    // 失败，发送一个错误
                    [subscriber sendError:invalidResponseError];
                }
            }];
        }
        
        return nil;
    }];
}
@end
