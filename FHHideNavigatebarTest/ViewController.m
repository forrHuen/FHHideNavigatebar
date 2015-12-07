//
//  ViewController.m
//  FHHideNavigatebarTest
//
//  Created by Forr on 15/12/7.
//  Copyright © 2015年 Forr. All rights reserved.
//

#import "ViewController.h"
#import "UIViewController+FHAnimateViewController.h"

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    UILabel *titleView = [[UILabel alloc]initWithFrame:CGRectMake(0, 0,80, 20)];
    titleView.text = @"首页";
    titleView.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleView;
    //
    self.dataSource = [NSMutableArray array];
    for (int i = 0;i < 40;i++)
    {
        [self.dataSource addObject:[NSString stringWithFormat:@"%zd",i]];
    }
    
    [self setupTableView];
}

- (void)setupTableView
{
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) style:UITableViewStylePlain];
    tableView.dataSource = self;
    tableView.delegate = self;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    [self bindingAnimateScrollView:self.tableView];
}

#pragma mark -tableView delegate-

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentitfer = @"cellIdentitfer";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentitfer];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentitfer];
    }
    cell.textLabel.text = self.dataSource[indexPath.row];
    return cell;
}


- (void)dealloc{
    [self removeBindingScrollView];
}

@end
