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
    CGFloat _requiredDistance;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _views = @[self.view1, self.view2];
    
    _requiredDistance = [self calcDistanceWithView:self.view1];
    
    [self updateCurrentZoomLabel];
}

- (void)updateCurrentZoomLabel
{
    self.currentZoomLabel.text = [NSString stringWithFormat:@"x%f", self.scrollView.zoomScale];
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
    CGPoint centerViewOrigin = [self.centerView convertPoint:CGPointZero toView:nil];
    CGSize centerViewSize = [self.centerView convertRect:self.centerView.frame toView:nil].size;
    CGFloat centerViewRight = centerViewOrigin.x + centerViewSize.width;
    
    for (UIView *view in _views) {
        CGAffineTransform scaleTransform = CGAffineTransformMakeScale(self.invertedZoomScale, self.invertedZoomScale);
        view.transform = scaleTransform;
    
        CGFloat viewWidth = view.bounds.size.width;
        // delta = (1 - S) * (P0 + (wB - S * wA) / 2)
        
        BOOL isFirstView = (view == _views.firstObject);
        CGRect viewFrame = [view convertRect:view.bounds toView:nil];
        
        CGFloat tx = isFirstView
        ? centerViewOrigin.x - (viewFrame.origin.x + viewFrame.size.width)
        : viewFrame.origin.x - centerViewRight;
        CGFloat ty = 0;
        
        if ([view isEqual:_views.lastObject]) {
            tx *= -1;
        }
        
        CGAffineTransform translationTransform = CGAffineTransformMakeTranslation(tx, ty);
        view.transform = CGAffineTransformConcat(view.transform, translationTransform);
        
        if ([view isEqual:_views.firstObject]) {
            NSLog(@"center view width %f, view width %f, tx %f", centerViewRight, viewWidth, tx);
        }
    }
    
    [self updateCurrentZoomLabel];
}

#pragma mark - UI Events

- (IBAction)zoomMinusButtonTouchUpInside:(UIButton *)sender
{
    CGFloat newZoom = self.scrollView.zoomScale - 1;
    
    self.scrollView.zoomScale = (newZoom < self.scrollView.minimumZoomScale)
    ? self.scrollView.minimumZoomScale
    : newZoom;
    
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
