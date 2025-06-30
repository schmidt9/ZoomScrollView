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
    CGFloat _requiredDistance;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _views = @[self.view1, self.view2];
    
    _requiredDistance = [self calcDistanceWithView:self.view1];
}

- (CGFloat)calcDistanceWithView:(UIView *)view
{
    CGRect viewRect = [view convertRect:view.frame toView:nil];
    CGRect centerViewRect = [self.centerView convertRect:self.centerView.frame toView:nil];
    CGFloat dist = (view == _views.firstObject)
    ? centerViewRect.origin.x - (viewRect.origin.x + viewRect.size.width) // left view
    : viewRect.origin.x - (centerViewRect.origin.x + centerViewRect.size.width); // right view

    return fabs(dist);
}

- (CGFloat)invertedZoomScale
{
    return 1.0 / self.scrollView.zoomScale;
}

- (void)updateWithZoom:(CGFloat)zoom
{
    // using convertRect to get real size on screen
    CGFloat centerViewWidth = [self.centerView convertRect:self.centerView.frame toView:nil].size.width;
    
    for (UIView *view in _views) {
        CGAffineTransform scaleTransform = CGAffineTransformMakeScale(self.invertedZoomScale, self.invertedZoomScale);
        view.transform = scaleTransform;
    
        CGFloat viewWidth = view.bounds.size.width;
        // delta = (1 - S) * (P0 + (wB - S * wA) / 2)
        
        CGFloat tx = (1 - zoom) * (_requiredDistance + (50 - zoom * 50) / 2); // TODO: calculate
        CGFloat ty = 0;
        
        if ([view isEqual:_views.firstObject]) {
            tx *= -1;
        }
        
        CGAffineTransform translationTransform = CGAffineTransformMakeTranslation(tx, ty);
        view.transform = CGAffineTransformConcat(view.transform, translationTransform);
        
        if ([view isEqual:_views.firstObject]) {
            NSLog(@"center view width %f, view width %f, tx %f", centerViewWidth, viewWidth, tx);
        }
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.zoomingView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [self updateWithZoom:scrollView.zoomScale];
}

@end
