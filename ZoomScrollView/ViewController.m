//
//  ViewController.m
//  ZoomScrollView
//
//  Created by Alexander Kormanovsky on 28.06.2025.
//

#import "ViewController.h"

@interface ViewController ()<UIScrollViewDelegate>

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *zoomingView;
@property (strong, nonatomic) IBOutlet UIView *view1;
@property (strong, nonatomic) IBOutlet UIView *view2;
@property (strong, nonatomic) IBOutlet UIView *centerView;

@end

@implementation ViewController
{
    NSArray<UIView *> *_views;
    CGFloat _prevZoom;
    CGFloat _requiredDistance;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _views = @[self.view1, self.view2];
    _prevZoom = self.scrollView.zoomScale;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _requiredDistance = [self calcDistanceWithView:self.view1];
}

- (CGFloat)invertedZoomScale
{
    return 1.0 / self.scrollView.zoomScale;
}

- (void)updateWithZoom:(CGFloat)zoom
{
    CGFloat zoomDelta = self.scrollView.zoomScale - _prevZoom;
    _prevZoom = zoom;
    
    for (UIView *view in _views) {
        CGFloat width = view.frame.size.width;
        
        CGFloat currentDistance = [self calcDistanceWithView:view];
        CGFloat tx = (width - width * zoom) / 2;
        CGFloat ty = 0;
        
        if ([view isEqual:_views.firstObject]) {
            tx *= -1;
        }
        
        CGAffineTransform scaleTransform = CGAffineTransformMakeScale(self.invertedZoomScale, self.invertedZoomScale);
        CGAffineTransform translationTransform = CGAffineTransformMakeTranslation(tx, ty);
        
        view.transform = CGAffineTransformConcat(scaleTransform, translationTransform);
        
        if ([view isEqual:_views.firstObject]) {
            NSLog(@"dist req %f curr %f tx %f",
                  _requiredDistance,
                  [self calcDistanceWithView:view],
                  tx
                  );
        }
    }
}

- (CGFloat)calcDistanceWithView:(UIView *)view
{
    CGRect viewRect = [view convertRect:view.bounds toView:nil];
    CGRect centerViewRect = [self.centerView convertRect:self.centerView.bounds toView:nil];
    CGFloat dist = (view == _views.firstObject)
    ? centerViewRect.origin.x - (viewRect.origin.x + viewRect.size.width) // left view
    : viewRect.origin.x - (centerViewRect.origin.x + centerViewRect.size.width); // right view

    return fabs(dist);
}

//- (CGFloat)calcCenterDistanceWithView:(UIView *)view
//{
//    CGPoint centerViewRelativeCenter = CGPointMake(self.centerView.frame.size.width / 2, self.centerView.frame.size.height / 2);
//    CGPoint centerViewCenter = [self.centerView convertPoint:centerViewRelativeCenter toView:nil];
//    
//    CGPoint viewRelativeCenter = CGPointMake(view.frame.size.width / 2, view.frame.size.height / 2);
//    CGPoint viewCenter = [view convertPoint:viewRelativeCenter toView:nil];
//    
//    CGFloat dist = centerViewCenter.x - viewCenter.x;
//    
//    return fabs(dist);
//}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.zoomingView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [self updateWithZoom:scrollView.zoomScale];
}

@end
