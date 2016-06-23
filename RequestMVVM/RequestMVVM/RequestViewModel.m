//
//  RequestViewModel.m
//  RequestMVVM
//
//  Created by 郑钦洪 on 16/6/10.
//  Copyright © 2016年 iKingsly. All rights reserved.
//

#import "RequestViewModel.h"
#import "AFNetworking.h"
#import "Book.h"
@interface RequestViewModel()
@end

@implementation RequestViewModel
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initailBind];
    }
    return self;
}
- (void)initailBind{
    _requestCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        RACSignal *requstSiganal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
            parameters[@"q"] = @"基础";
            [[AFHTTPSessionManager manager] GET:@"https://api.douban.com/v2/book/search" parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                NSLog(@"接受到的数据 %@",responseObject);
                
                // 请求成功，将请求结果传出去
                [subscriber sendNext:responseObject];
                [subscriber sendCompleted];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [subscriber sendError:error];
            }];
            return nil;
        }];
        
        // 在返回数据信号时，把数据中的字典映射成模型信号，传递出去
        return [requstSiganal map:^id(NSDictionary *value) {
            NSMutableArray *array = value[@"books"];
             // 字典转模型，遍历字典中的所有元素，全部映射成模型，并且生成数组
            NSArray *modelArray = [[array.rac_sequence map:^id(id value) {
                return [Book bookWithDictionary:value];
            }] array];
            return modelArray;
        }];
    }];
}

#pragma mark - dataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.models.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *ID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    
    Book *book = self.models[indexPath.row];
    cell.detailTextLabel.text = book.subTitle;
    cell.textLabel.text = book.title;
    
    return cell;
}
@end
