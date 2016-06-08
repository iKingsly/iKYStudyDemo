//
//  RWTFlickrSearchImpl.m
//  RWTFlickrSearch
//
//  Created by 郑钦洪 on 16/6/8.
//  Copyright © 2016年 Colin Eberhardt. All rights reserved.
//

#import "RWTFlickrSearchImpl.h"
#import "RWTFlickrSearchResults.h"
#import "RWTFlickrPhoto.h"
#import <objectiveflickr/ObjectiveFlickr.h>
#import <LinqToObjectiveC/NSArray+LinqExtensions.h>
@interface RWTFlickrSearchImpl ()<OFFlickrAPIRequestDelegate>
@property (strong, nonatomic) NSMutableSet *requests;
@property (strong, nonatomic) OFFlickrAPIContext *flickrContext;
@end
@implementation RWTFlickrSearchImpl
- (instancetype)init{
    self = [super init];
    if (self) {
        NSString *OFSampleAppAPIKey = @"dee359bb664eee186702c8a4d122e051";
        NSString *OFSampleAppAPISharedSecret = @"8f6bd3160559a6a2";
        
        _flickrContext = [[OFFlickrAPIContext alloc] initWithAPIKey:OFSampleAppAPIKey
                                                       sharedSecret:OFSampleAppAPISharedSecret];
        _requests = [NSMutableSet new];
    }
    return self;
}
- (RACSignal *)flickrSeachSignal:(NSString *)searchString{
    return [self signalFromAPIMethod:@"flickr.photos.search"
                           arguments:@{@"text": searchString,
                                       @"sort": @"interestingness-desc"}
                           transform:^id(NSDictionary *response) {
                               RWTFlickrSearchResults *result = [RWTFlickrSearchResults new];
                               result.searchString = searchString;
                               result.totalResults = [[response valueForKeyPath:@"photos.total"] integerValue];
                               
                               NSArray *photos = [response valueForKeyPath:@"photos.photo"];
                               result.photos = [photos linq_select:^id(NSDictionary *jsonPhoto) {
                                   RWTFlickrPhoto *photo = [RWTFlickrPhoto new];
                                   photo.title = [jsonPhoto objectForKey:@"title"];
                                   photo.identifier = [jsonPhoto objectForKey:@"id"];
                                   photo.url = [self.flickrContext photoSourceURLFromDictionary:jsonPhoto size:OFFlickrSmallSize];
                                   return photo;
                               }];
                               return result;
                           }];
}

- (RACSignal *)signalFromAPIMethod:(NSString *)method arguments:(NSDictionary *)args transform:(id(^)(NSDictionary *response)) block{
    // 1. create a signal for this request
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
       // 2. Create a Flick request object
        OFFlickrAPIRequest *flickrRequest = [[OFFlickrAPIRequest alloc] initWithAPIContext:self.flickrContext];
        flickrRequest.delegate = self;
        [self.requests addObject:flickrRequest];
        
        // 3. create a signal from the delegate method
        RACSignal *successSignal = [self rac_signalForSelector:@selector(flickrAPIRequest:didCompleteWithResponse:) fromProtocol:@protocol(OFFlickrAPIRequestDelegate)];
        
        // 4. handle the response
        [[[successSignal map:^id(RACTuple *tuple) {
            return tuple.second;
        }] map:block] subscribeNext:^(id x) {
            [subscriber sendNext:x];
            [subscriber sendCompleted];
        }];
        
        // 5. Make the request
        [flickrRequest callAPIMethodWithGET:method arguments:args];
        
        // 6 when we are done remove the reference to this request
        return [RACDisposable disposableWithBlock:^{
            [self.requests removeObject:flickrRequest];
        }];
    }];
}
@end
