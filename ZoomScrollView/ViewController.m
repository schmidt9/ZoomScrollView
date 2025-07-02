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
@property (strong, nonatomic) IBOutlet UILabel *currentZoomLabel;

@end

@implementation ViewController
{
    NSArray<UIView *> *_views;
    CGFloat _initialDistance;
    CGFloat _initialCenterViewWidth;
    CGFloat _initialViewsWidth;
    CGFloat _initialCentersDistance;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _views = @[self.view1, self.view2];

    [self updateCurrentZoomLabel];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    _initialDistance = [self calcDistanceWithView:self.view2];
    _initialCenterViewWidth = [self.centerView convertRect:self.centerView.frame toView:nil].size.width;
    _initialViewsWidth = [self.centerView convertRect:self.view2.frame toView:nil].size.width;
    
    _initialCentersDistance = [self centerForView:self.centerView useBounds:NO].x - [self centerForView:self.view1 useBounds:YES].x;
    
    [self printViewInfo:self.centerView name:@"center view" useBounds:YES];
    [self printViewInfo:self.view2 name:@"view 2" useBounds:NO];
}

- (void)updateCurrentZoomLabel
{
    self.currentZoomLabel.text = [NSString stringWithFormat:@"x%f", self.scrollView.zoomScale];
}

- (CGFloat)invertedZoomScale
{
    return 1.0 / self.scrollView.zoomScale;
}

- (void)updateWithZoom:(CGFloat)zoom
{
    [self printViewInfo:self.centerView name:@"center view" useBounds:NO];
    
    CGPoint centerViewOrigin = [self.centerView convertPoint:CGPointZero toView:nil];
    CGFloat centerViewWidth = [self.centerView convertRect:self.centerView.frame toView:nil].size.width;
    CGFloat centerViewRight = centerViewOrigin.x + centerViewWidth;
    NSLog(@"origin %f width %f right %f", centerViewOrigin.x, centerViewWidth, centerViewRight);
    
    for (UIView *view in _views) {
        CGAffineTransform scaleTransform = CGAffineTransformMakeScale(self.invertedZoomScale, self.invertedZoomScale);
        view.transform = scaleTransform;

        // delta = (1 - S) * (P0 + (wB - S * wA) / 2)
        // TEX:
        // \Delta = P_0 + \frac{w_B}{2} + \frac{w_A \cdot S}{2} - S \cdot (\text{centerB} - \text{centerA})
        
        CGRect viewFrame = [view convertRect:view.frame toView:nil];
        CGFloat viewX = CGRectGetMidX(viewFrame) - _initialViewsWidth / 2;
        CGFloat distance = viewX - centerViewRight;

        CGFloat centersDistance = [view isEqual:_views.lastObject] ? _initialCentersDistance * 1 : _initialCentersDistance * -1;
        CGFloat tx = _initialDistance + (_initialViewsWidth / 2) + (_initialCenterViewWidth * zoom) / 2 - zoom * centersDistance;
        CGFloat ty = 0;
        
        if ([view isEqual:_views.lastObject]) {
//            tx *= -1;
        }
        
        CGAffineTransform translationTransform = CGAffineTransformMakeTranslation(tx, ty);
        view.transform = CGAffineTransformConcat(view.transform, translationTransform);
        
        if ([view isEqual:_views.lastObject]) {
            [self printViewInfo:view name:@"view 2" useBounds:YES];
            NSLog(@"tx %f", tx);
        }
    }
    
    [self updateCurrentZoomLabel];
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

- (void)printViewInfo:(UIView *)view name:(NSString *)name useBounds:(BOOL)useBounds
{
    // using convert methods to get real dimensions on screen after transforms
    CGPoint origin = [view convertPoint:CGPointZero toView:nil];
    CGRect rect = useBounds ? view.bounds : view.frame;
    CGSize size = [view convertRect:rect toView:nil].size;
    CGPoint center = CGPointMake(origin.x + size.width / 2, origin.y + size.height / 2);
    
    NSLog(@"%@, axis X, zoom %f:\nleft %f\nright %f\nwidth %f\ncenter %f",
          name,
          self.scrollView.zoomScale,
          origin.x,
          origin.x + size.width,
          size.width,
          center.x
          );
}

- (CGPoint)centerForView:(UIView *)view useBounds:(BOOL)useBounds
{
    CGPoint origin = [view convertPoint:CGPointZero toView:nil];
    CGRect rect = useBounds ? view.bounds : view.frame;
    CGSize size = [view convertRect:rect toView:nil].size;
    
    return CGPointMake(origin.x + size.width / 2, origin.y + size.height / 2);
}

- (CGRect)rectForView:(UIView *)view useBounds:(BOOL)useBounds
{
    CGPoint origin = [view convertPoint:CGPointZero toView:nil];
    CGRect rect = useBounds ? view.bounds : view.frame;
    CGSize size = [view convertRect:rect toView:nil].size;
    
    return CGRectMake(origin.x, origin.y, rect.size.width, rect.size.height);
}

#pragma mark - UI Events

- (IBAction)zoomMinusButtonTouchUpInside:(UIButton *)sender
{
    CGFloat newZoom = self.scrollView.zoomScale - 1;
    
    if (newZoom < 1) {
        newZoom = self.scrollView.zoomScale - 0.1;
    }
    
    if (newZoom < 0.1) {
        newZoom = 0.1;
    }
    
    self.scrollView.zoomScale = newZoom;
    
    [self updateCurrentZoomLabel];
}

- (IBAction)zoomPlusButtonTouchUpInside:(UIButton *)sender
{
    CGFloat newZoom = self.scrollView.zoomScale + 1;
    
    self.scrollView.zoomScale = (newZoom > self.scrollView.maximumZoomScale)
    ? self.scrollView.maximumZoomScale
    : newZoom;
    
    [self updateCurrentZoomLabel];
}

# pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.zoomingView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [self updateWithZoom:scrollView.zoomScale];
}

@end
