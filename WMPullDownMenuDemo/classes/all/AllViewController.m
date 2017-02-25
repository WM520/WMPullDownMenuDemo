//
//  AllViewController.m
//  WMPullDownMenuDemo
//
//  Created by wangmiao on 2017/2/25.
//  Copyright © 2017年 wangmiao. All rights reserved.
//

#import "AllViewController.h"
#import "UIView+WMCategory.h"

extern NSString * const WMUpdateMenuTitleNote;
static NSString * const categoryID = @"categoryID";
static NSString * const categoryDetailID = @"categoryDetailID";

@interface AllViewController ()<UITableViewDelegate, UITableViewDataSource>

/**
 *  分类tableView
 */
@property (weak, nonatomic) IBOutlet UITableView *categoryTableView;
/**
 *  分类详情tableView
 */
@property (weak, nonatomic) IBOutlet UITableView *categoryDetailTableView;

@property (strong, nonatomic) NSString *selectedCategory;


@end

@implementation AllViewController

#pragma mark - 懒加载
- (UITableView *)categoryTableView
{
    if (!_categoryTableView) {
        UITableView *categoryTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width / 2, self.view.height) style:UITableViewStylePlain];
        categoryTableView.delegate = self;
        categoryTableView.dataSource = self;
        [categoryTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:categoryID];
        [self.view addSubview:categoryTableView];
        _categoryTableView = categoryTableView;
    }
    return _categoryTableView;
}

- (UITableView *)categoryDetailTableView
{
    if (!_categoryDetailTableView) {
        UITableView *categoryDetailTableView = [[UITableView alloc] initWithFrame:CGRectMake(self.view.width / 2, 0, self.view.width / 2, self.view.height) style:UITableViewStylePlain];
        categoryDetailTableView.delegate = self;
        categoryDetailTableView.dataSource = self;
        [categoryDetailTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:categoryDetailID];
        [self.view addSubview:categoryDetailTableView];
        _categoryDetailTableView = categoryDetailTableView;
    }
    return _categoryDetailTableView;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    (void)self.categoryTableView;
    (void)self.categoryDetailTableView;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    [self.categoryTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    [self tableView:self.categoryTableView didSelectRowAtIndexPath:indexPath];

}

#pragma mark - <UITableViewDataSource>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.categoryTableView) {
        // 左边的类别表格 👈
        return 5;
        
    } else {
        // 右边的类别详情表格 👉
        return 10;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.categoryTableView) {
        // 左边的类别表格 👈
        UITableViewCell *cell =  [tableView dequeueReusableCellWithIdentifier:categoryID];
        cell.textLabel.text = [NSString stringWithFormat:@"小学%ld",indexPath.row];
        return cell;
    }
    
    // 右边的类别详情表格 👉
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:categoryDetailID];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ : 详%ld",_selectedCategory,indexPath.row];
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.categoryTableView) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        // 左边的类别表格 👈
        _selectedCategory = cell.textLabel.text;
        
        // 刷新右边数据
        [self.categoryDetailTableView reloadData];
        
        return;
    }
    
    // 右边的类别详情表格 👉
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    // 更新菜单标题
    [[NSNotificationCenter defaultCenter] postNotificationName:WMUpdateMenuTitleNote object:self userInfo:@{@"title":cell.textLabel.text}];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
