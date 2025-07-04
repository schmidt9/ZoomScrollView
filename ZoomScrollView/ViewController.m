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
    
    // distance from center of "left-side-view" to leading edge of "center-view"
    _initialDistance = CGRectGetMinX(_centerView.frame) - CGRectGetMidX(_view1.frame);
}

- (void)updateCurrentZoomLabel
{
    self.currentZoomLabel.text = [NSString stringWithFormat:@"x%f", self.scrollView.zoomScale];
}

- (CGFloat)invertedZoomScale
{
    return 1.0 / self.scrollView.zoomScale;
}

/**
 https://stackoverflow.com/a/79688031/3004003
 */
- (void)updateWithZoom:(CGFloat)zoom
{
    for (UIView *view in _views) {
        CGFloat tx = (_initialDistance * zoom) - _initialDistance;
        CGFloat ty = 0;
        
        if (CGRectGetMidX(view.frame) > CGRectGetMidX(_centerView.frame)) {
            // right-side-view, so negative translation
            tx *= -1;
        }
        
        CGAffineTransform scaleTransform = CGAffineTransformMakeScale(self.invertedZoomScale, self.invertedZoomScale);
        CGAffineTransform translationTransform = CGAffineTransformMakeTranslation(tx, ty);
        
        // translate, then scale
        view.transform = CGAffineTransformConcat(translationTransform, scaleTransform);
    }
    
    [self updateCurrentZoomLabel];
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
