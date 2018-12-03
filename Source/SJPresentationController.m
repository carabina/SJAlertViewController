//
//  SJPresentationController.m
//  SJTestDemo
//
//  Created by Mac on 2018/11/21.
//  Copyright © 2018年 S.J. All rights reserved.
//

#import "SJPresentationController.h"
#define CORNER_RADIUS  0.f

@interface SJPresentationController () <UIViewControllerAnimatedTransitioning>
@property (nonatomic, strong) UIView *dimmingView;
@property (nonatomic, strong) UIView *presentationWrappingView;
@end

@implementation SJPresentationController

- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController presentingViewController:(UIViewController *)presentingViewController {
    self = [super initWithPresentedViewController:presentedViewController presentingViewController:presentingViewController];
    if (self) {
        presentedViewController.modalPresentationStyle = UIModalPresentationCustom;
        presentedViewController.transitioningDelegate = self;
    }
    return self;
}

- (UIView*)presentedView {
    // Return the wrapping view created in -presentationTransitionWillBegin.
    return self.presentationWrappingView;
}

- (void)presentationTransitionWillBegin {
    UIView *presentedViewControllerView = [super presentedView];
    {
        UIView *presentationWrapperView = [[UIView alloc] initWithFrame:self.frameOfPresentedViewInContainerView];
        self.presentationWrappingView = presentationWrapperView;
        
        UIView *presentationRoundedCornerView = [[UIView alloc] initWithFrame:UIEdgeInsetsInsetRect(presentationWrapperView.bounds, UIEdgeInsetsMake(0, 0, 0, 0))];
        presentationRoundedCornerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        presentationRoundedCornerView.layer.cornerRadius = CORNER_RADIUS;
        presentationRoundedCornerView.layer.masksToBounds = YES;
        
        UIView *presentedViewControllerWrapperView = [[UIView alloc] initWithFrame:UIEdgeInsetsInsetRect(presentationRoundedCornerView.bounds, UIEdgeInsetsMake(0, 0, 0, 0))];
        presentedViewControllerWrapperView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        // Add presentedViewControllerView -> presentedViewControllerWrapperView.
        presentedViewControllerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        presentedViewControllerView.frame = presentedViewControllerWrapperView.bounds;
        [presentedViewControllerWrapperView addSubview:presentedViewControllerView];
        
        // Add presentedViewControllerWrapperView -> presentationRoundedCornerView.
        [presentationRoundedCornerView addSubview:presentedViewControllerWrapperView];
        // Add presentationRoundedCornerView -> presentationWrapperView.
        [presentationWrapperView addSubview:presentationRoundedCornerView];
    }
    // back view
    {
        UIView *dimmingView = [[UIView alloc] initWithFrame:self.containerView.bounds];
        dimmingView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
        dimmingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [dimmingView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dimmingViewTapped:)]];
        self.dimmingView = dimmingView;
        [self.containerView addSubview:dimmingView];

        // fade in the dimmingView alongside the presentation animation.
        id<UIViewControllerTransitionCoordinator> transitionCoordinator = self.presentingViewController.transitionCoordinator;
        self.dimmingView.alpha = 0.f;
        [transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
            self.dimmingView.alpha = 0.5f;
        } completion:NULL];
    }
}

- (void)presentationTransitionDidEnd:(BOOL)completed {
    if (completed == NO) {
        self.presentationWrappingView = nil;
        self.dimmingView = nil;
    }
}

- (void)dismissalTransitionWillBegin {
    id<UIViewControllerTransitionCoordinator> transitionCoordinator = self.presentingViewController.transitionCoordinator;
    [transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        self.dimmingView.alpha = 0.f;
    } completion:NULL];
}

- (void)dismissalTransitionDidEnd:(BOOL)completed {
    if (completed == YES) {
        self.presentationWrappingView = nil;
        self.dimmingView = nil;
    }
}

#pragma mark -
#pragma mark Layout
- (void)preferredContentSizeDidChangeForChildContentContainer:(id<UIContentContainer>)container {
    [super preferredContentSizeDidChangeForChildContentContainer:container];
    if (container == self.presentedViewController)
        [self.containerView setNeedsLayout];
}


- (CGSize)sizeForChildContentContainer:(id<UIContentContainer>)container withParentContainerSize:(CGSize)parentSize {
    if (container == self.presentedViewController)
        return ((UIViewController*)container).preferredContentSize;
    else
        return [super sizeForChildContentContainer:container withParentContainerSize:parentSize];
}

// 弹出视图的frame ----------------------------------------------------------------------------
- (CGRect)frameOfPresentedViewInContainerView {
    CGRect containerViewBounds = self.containerView.bounds;
    CGSize presentedViewContentSize = [self sizeForChildContentContainer:self.presentedViewController withParentContainerSize:containerViewBounds.size];
    // The presented view extends presentedViewContentSize.height points from
    // the bottom edge of the screen.
    CGRect presentedViewControllerFrame = containerViewBounds;
    if (self.presentationType == SJPresentationTypeBottom) {
        presentedViewControllerFrame.size.height = presentedViewContentSize.height;
        presentedViewControllerFrame.origin.y = CGRectGetMaxY(containerViewBounds) - presentedViewContentSize.height;
    }
    else if (self.presentationType == SJPresentationTypeCenter) {
        presentedViewControllerFrame.size.width = presentedViewContentSize.width;
        presentedViewControllerFrame.size.height = presentedViewContentSize.height;
        presentedViewControllerFrame.origin.y = containerViewBounds.size.height * 0.5 - presentedViewContentSize.height * 0.5;
        presentedViewControllerFrame.origin.x = containerViewBounds.size.width * 0.5 - presentedViewContentSize.width * 0.5;
    }
    return presentedViewControllerFrame;
}

- (void)containerViewWillLayoutSubviews {
    [super containerViewWillLayoutSubviews];
    self.dimmingView.frame = self.containerView.bounds;
    self.presentationWrappingView.frame = self.frameOfPresentedViewInContainerView;
}

#pragma mark -
#pragma mark Tap Gesture Recognizer
- (IBAction)dimmingViewTapped:(UITapGestureRecognizer*)sender {
    if (self.backgroundDismissEnable) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
    }
}

#pragma mark -
#pragma mark UIViewControllerAnimatedTransitioning

// 动画执行时间
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return [transitionContext isAnimated] ? .3 : 0;
}

// 显示和消失是的饿动画
- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

    UIView *containerView = transitionContext.containerView;
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    BOOL isPresenting = (fromViewController == self.presentingViewController);

    CGRect __unused fromViewInitialFrame = [transitionContext initialFrameForViewController:fromViewController];
    CGRect fromViewFinalFrame = [transitionContext finalFrameForViewController:fromViewController];
    CGRect toViewInitialFrame = [transitionContext initialFrameForViewController:toViewController];
    CGRect toViewFinalFrame = [transitionContext finalFrameForViewController:toViewController];
    [containerView addSubview:toView];
    if (isPresenting) {
        if (self.presentationType == SJPresentationTypeCenter) {
            toViewInitialFrame.origin = CGPointMake(CGRectGetMaxX(containerView.bounds) * 0.5, CGRectGetMaxY(containerView.bounds) * 0.5);
            toViewInitialFrame.size = CGSizeZero;
            toView.frame = toViewInitialFrame;
        }
        else if (self.presentationType == SJPresentationTypeBottom) {
            toViewInitialFrame.origin = CGPointMake(CGRectGetMinX(containerView.bounds), CGRectGetMaxY(containerView.bounds));
            toViewInitialFrame.size = toViewFinalFrame.size;
            toView.frame = toViewInitialFrame;
        }
        else {}
    } else {
        if (self.presentationType == SJPresentationTypeCenter) {
            fromViewFinalFrame.origin = CGPointMake(CGRectGetMaxX(containerView.bounds) * 0.5, CGRectGetMaxY(containerView.bounds) * 0.5);
            fromViewFinalFrame.size = CGSizeZero;
        }
        else if (self.presentationType == SJPresentationTypeBottom) {
            fromViewFinalFrame = CGRectOffset(fromView.frame, 0, CGRectGetHeight(fromView.frame));
        }
        else {}
    }
    // 执行动画的时间
    NSTimeInterval transitionDuration = [self transitionDuration:transitionContext];
    // 弹簧动画，参数分别为：时长，延时，弹性（越小弹性越大），初始速度
    CGFloat damping = self.presentationType == SJPresentationTypeCenter?0.6:1;
    CGFloat velocity = self.presentationType == SJPresentationTypeCenter?0.3:1;
    [UIView animateWithDuration:transitionDuration delay:0 usingSpringWithDamping:damping initialSpringVelocity:velocity options:0 animations:^{
        if (isPresenting) {
            toView.frame = toViewFinalFrame;
        }
        else {
            fromView.frame = fromViewFinalFrame;
        }
        if (self.presentationType == SJPresentationTypeCenter) {
            [toView.superview layoutIfNeeded];
            [fromView.superview layoutIfNeeded];
        }
    } completion:^(BOOL finished) {
        BOOL wasCancelled = [transitionContext transitionWasCancelled];
        [transitionContext completeTransition:!wasCancelled];
    }];
}

#pragma mark -
#pragma mark UIViewControllerTransitioningDelegate
- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source {
    NSAssert(self.presentedViewController == presented, @"You didn't initialize %@ with the correct presentedViewController.  Expected %@, got %@.",
             self, presented, self.presentedViewController);
    return self;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return self;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return self;
}

#pragma mark- setter/getter
- (void)setBackgroundDismissEnable:(BOOL)backgroundDismissEnable {
    _backgroundDismissEnable = backgroundDismissEnable;
}

@end
