//
//  UIViewController+FHAnimateViewController.m
//  FHHideNavigatebarTest
//
//  Created by Forr on 15/12/7.
//  Copyright © 2015年 Forr. All rights reserved.
//

#import "UIViewController+FHAnimateViewController.h"
#import <objc/runtime.h>

#define MAX_DURATION   0.25
static const char *panGestureKey = "panGestureKey";
static const char *scrollViewKey = "scrollViewKey";
static const char *maxNavTopKey = "maxNavTopKey";
static const char *minNavTopKey = "minNavTopKey";
static const char *maxScrollDistanceKey = "maxScrollDistanceKey";
static const char *amassKey = "amassKey";


@implementation UIViewController (FHAnimateViewController)

- (void)setPanGesture:(UIPanGestureRecognizer *)panGesture{
    objc_setAssociatedObject(self, panGestureKey, panGesture, OBJC_ASSOCIATION_RETAIN);
}

- (UIPanGestureRecognizer *)panGesture
{
    return objc_getAssociatedObject(self, panGestureKey);
}

- (void)setScrollView:(UIView *)scrollView
{
    objc_setAssociatedObject(self, scrollViewKey, scrollView, OBJC_ASSOCIATION_RETAIN);
}

- (UIView *)scrollView
{
    return objc_getAssociatedObject(self, scrollViewKey);
}

- (void)setMaxNavTop:(CGFloat)maxNavTop
{
    objc_setAssociatedObject(self, maxNavTopKey,[NSNumber numberWithFloat:maxNavTop], OBJC_ASSOCIATION_RETAIN);
}

- (CGFloat)maxNavTop
{
    return [objc_getAssociatedObject(self, maxNavTopKey) floatValue];
}

- (void)setMinNavTop:(CGFloat)minNavTop
{
    objc_setAssociatedObject(self, minNavTopKey, [NSNumber numberWithFloat:minNavTop], OBJC_ASSOCIATION_RETAIN);
}

- (CGFloat)minNavTop
{
    return [objc_getAssociatedObject(self, minNavTopKey) floatValue];
}

- (void)setMaxScrollDistance:(CGFloat)maxScrollDistance
{
    objc_setAssociatedObject(self, maxScrollDistanceKey,[NSNumber numberWithFloat:maxScrollDistance], OBJC_ASSOCIATION_RETAIN);
}

- (CGFloat)maxScrollDistance
{
    return [objc_getAssociatedObject(self, maxScrollDistanceKey) floatValue];
}

- (void)setAmass:(CGFloat)amass
{
    objc_setAssociatedObject(self, amassKey,[NSNumber numberWithFloat:amass], OBJC_ASSOCIATION_RETAIN);
}

- (CGFloat)amass
{
    return [objc_getAssociatedObject(self,amassKey) floatValue];
}




/**
 *  绑定滚动视图
 *
 *  @param scrollView
 */
- (BOOL)bindingAnimateScrollView:(UIView *)scrollView
{
    if (scrollView && self.navigationController && self.navigationController.navigationBarHidden==NO)
    {
        self.scrollView = scrollView;
        self.panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePanAction:)];
        self.panGesture.maximumNumberOfTouches = 1;
        self.panGesture.delegate = self;
        self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [self.scrollView addGestureRecognizer:self.panGesture];
        [self resetParams];
        return YES;
    }
    return NO;
}


- (void)handlePanAction:(UIPanGestureRecognizer *)panGesture
{
    CGPoint translation = [panGesture translationInView:self.view];
    CGFloat delta = translation.y;
    if ([self checkValue:delta])
    {
        [self updateFrameWithDelta:delta];
    }
    if ([panGesture state] == UIGestureRecognizerStateEnded)
    {
        [self completeFitToSizing];
    }
    [panGesture setTranslation:CGPointZero
                        inView:self.view];
}

//更新导航栏位置和view的位置
- (void)updateFrameWithDelta:(CGFloat)delta
{
    NSLog(@"____ddd = %f",self.amass);
    self.amass = self.amass + delta;
    //保证amass在0～44之间，用于计算透明度的值及记录距离
    self.amass = self.amass < 0.0f ? 0.0f : self.amass;
    self.amass = self.amass > self.maxScrollDistance ? self.maxScrollDistance:self.amass;
    [self updateNavFrameWithDelta:delta];
    [self updateSelfViewFrame];
}

//更新导航栏的位置
- (void)updateNavFrameWithDelta:(CGFloat)delta
{
    CGRect navFrame = self.navigationController.navigationBar.frame;
    navFrame.origin.y = navFrame.origin.y + delta;
    //保证导航栏位置在－24到20范围内
    navFrame.origin.y = navFrame.origin.y > self.maxNavTop ? self.maxNavTop:navFrame.origin.y;
    navFrame.origin.y = navFrame.origin.y < self.minNavTop ? self.minNavTop:navFrame.origin.y;
    self.navigationController.navigationBar.frame = navFrame;
    //更新bar上控件的透明度
    CGFloat alpha = self.maxScrollDistance > 0.0f ? self.amass / self.maxScrollDistance :0.0f;
    [self.navigationItem.leftBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.customView.alpha = alpha;
    }];
    self.navigationItem.leftBarButtonItem.customView.alpha = alpha;
    [self.navigationItem.rightBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.customView.alpha = alpha;
    }];
    self.navigationItem.rightBarButtonItem.customView.alpha = alpha;
    
    self.navigationItem.titleView.alpha = alpha;
}



//更新view的位置
- (void)updateSelfViewFrame
{
    CGFloat top = self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height;
    CGFloat bottom= self.navigationController.view.bounds.size.height;
    if (self.tabBarController)
    {
        bottom = self.tabBarController.tabBar.frame.origin.y;
    }
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y = top;
    viewFrame.size.height = bottom - top;
    self.view.frame = viewFrame;
    //同步更新scrollview的位置大小
    [self.scrollView setNeedsDisplay];
}

//校验滚动是否超过导航栏的一半，调整是否隐藏
- (void)completeFitToSizing
{
    if (self.amass > self.maxScrollDistance *0.5) {
        //显示导航栏
        CGFloat adujstDistance = self.maxScrollDistance < self.amass ? 0.0f : self.maxScrollDistance - self.amass;
        NSTimeInterval duration = (adujstDistance / self.maxScrollDistance) * MAX_DURATION;
        [UIView animateWithDuration:duration animations:^{
            [self updateFrameWithDelta:adujstDistance];
        }];
    }else{
        //隐藏导航栏
        CGFloat adujstDistance = self.amass < 0.0f ? 0.0f:self.amass;
        //距离越短时间越短
        NSTimeInterval duration = (adujstDistance / self.maxScrollDistance) * MAX_DURATION;
        [UIView animateWithDuration:duration animations:^{
            [self updateFrameWithDelta:-adujstDistance];
        }];
    }
}

//校验滑动0～44
- (BOOL)checkValue:(CGFloat)delta{
    if (delta<0)//向上滑动
    {
        if (self.amass > 0)
        {
            return YES;
        }
    }
    else if ( delta > 0 )//向下滑动
    {
        if ( self.amass < self.maxScrollDistance )
        {
            return YES;
        }
    }
    return NO;
}

//设置参数
- (void)resetParams
{
    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    self.maxNavTop = statusBarHeight;
    self.minNavTop = statusBarHeight - self.navigationController.navigationBar.frame.size.height;
    self.maxScrollDistance = self.navigationController.navigationBar.frame.size.height;
    self.amass = self.navigationController.navigationBar.frame.size.height;
    
}

/**
 *  对滚动视图解除绑定，delloe中调用
 *
 *  @return 是否解除成功
 */
- (BOOL)removeBindingScrollView
{
    if (self.scrollView)
    {
        [self.scrollView removeGestureRecognizer:self.panGesture];
        self.scrollView = nil;
        self.panGesture = nil;
        return YES;
    }
    return NO;
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}


@end
