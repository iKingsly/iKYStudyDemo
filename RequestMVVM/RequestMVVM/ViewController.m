//
//  ViewController.m
//  RequestMVVM
//
//  Created by 郑钦洪 on 16/6/10.
//  Copyright © 2016年 iKingsly. All rights reserved.
//

#import "ViewController.h"
#import "RequestViewModel.h"

@interface ViewController ()
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) RequestViewModel *viewModel;
@end

@implementation ViewController
- (RequestViewModel *)viewModel{
    if (!_viewModel) {
        _viewModel = [RequestViewModel new];
    }
    return _viewModel;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    tableView.dataSource = self.viewModel;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    // 执行网络请求
    RACSignal *signal = [self.viewModel.requestCommand execute:nil];
    // 请求网络结果
    @weakify(self);
    [signal subscribeNext:^(NSArray *x) {
        @strongify(self);
        self.viewModel.models = x;
        [self.tableView reloadData];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
