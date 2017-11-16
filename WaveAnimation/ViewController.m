//
//  ViewController.m
//  WaveAnimation
//
//  Created by YLCHUN on 2017/10/26.
//  Copyright © 2017年 YLCHUN. All rights reserved.
//

#import "ViewController.h"
#import "WaveAnimation.h"
#import "UserHeaderView.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view layoutIfNeeded];
    
    UserHeaderView *headerView = [UserHeaderView headerViewWithWidth:self.view.bounds.size.width];
    [self.scrollView addSubview:headerView];

    CGSize size = self.view.bounds.size;
    size.height += CGRectGetHeight(headerView.bounds);
    self.scrollView.contentSize = size;
}


@end
