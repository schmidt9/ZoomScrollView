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
    CGFloat _initialViewsWidth;
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
    _initialViewsWidth = [self.centerView convertRect:self.view2.frame toView:nil].size.width;
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
    // using convert... methods to get real position and size of view scaled by the scroll view on the screen
    CGFloat centerViewLeft = [self.centerView convertPoint:CGPointZero toView:nil].x;
    CGFloat centerViewWidth = [self.centerView convertRect:self.centerView.frame toView:nil].size.width;
    CGFloat centerViewRight = centerViewLeft + centerViewWidth;
    
    for (UIView *view in _views) {
        CGAffineTransform scaleTransform = CGAffineTransformMakeScale(self.invertedZoomScale, self.invertedZoomScale);
        view.transform = scaleTransform;
        
        CGRect viewBounds = [view convertRect:view.bounds toView:nil];
        
        // using initial view size because applying inverted transform keeps visual size of the transformed view,
        // but convertRect method gives transformed size
        CGFloat viewLeft = CGRectGetMidX(viewBounds) - _initialViewsWidth / 2;
        CGFloat viewRight = CGRectGetMidX(viewBounds) + _initialViewsWidth / 2;
        
        BOOL isLeftView = (view == _views.firstObject);
        CGFloat distance = isLeftView
        ? centerViewLeft - viewRight
        : viewLeft - centerViewRight;
        CGFloat tx = (_initialDistance - distance) / zoom;
        CGFloat ty = 0;
        
        if (isLeftView) {
            tx *= -1;
        }
        
        CGAffineTransform translationTransform = CGAffineTransformMakeTranslation(tx, ty);
        view.transform = CGAffineTransformConcat(view.transform, translationTransform);
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
