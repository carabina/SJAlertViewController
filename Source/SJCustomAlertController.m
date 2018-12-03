//
//  SJCustomAlertController.m
//  SJTestDemo
//
//  Created by Mac on 2018/11/26.
//  Copyright © 2018年 S.J. All rights reserved.
//

#import "SJCustomAlertController.h"

@interface SJCustomAlertController ()

@property (nonatomic, strong) SJPresentationController *presentationController;

@property (nonatomic, strong) UIView *alertView;

@end

@implementation SJCustomAlertController
#pragma mark- Life Cycle
/**
 使用自定义view初始化
 
 @param customView 自定义View
 @return 返回实例
 */
- (instancetype)initWithCustomView:(UIView *)customView {
    if (self = [super init]) {
        self.alertView = customView;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // 设置弹出控制器的Size
    self.preferredContentSize = self.alertView.bounds.size;
    // 初始化子视图
    [self configSubviews];
}

- (void)configSubviews {
    [self.view addSubview:self.alertView];
}

#pragma mark- Public method
/**
 模态出当前控制器
 
 @param controller 控制器
 @param type 显示类型
 @param animated 是否有动画
 @param completion 显示完成回调
 */
- (void)presentInController:(UIViewController *)controller type:(SJPresentationType)type animated:(BOOL)animated complete:(void (^)(void))completion {
    SJPresentationController *presentationController NS_VALID_UNTIL_END_OF_SCOPE;
    presentationController = [[SJPresentationController alloc] initWithPresentedViewController:self presentingViewController:controller];
    presentationController.presentationType = type;
    self.presentationController = presentationController;
    [controller presentViewController:self animated:animated completion:completion];
}

#pragma mark- Custom Accessors
- (void)setBackgroundDismissEnable:(BOOL)backgroundDismissEnable {
    _backgroundDismissEnable = backgroundDismissEnable;
    self.presentationController.backgroundDismissEnable = self.backgroundDismissEnable;
}

@end
