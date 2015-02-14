//
//  PhotoAnnotationView.m
//  mageo
//
//  Created by swallow on 2/2/15.
//  Copyright (c) 2015 swallow. All rights reserved.
//

#import "PhotoAnnotationView.h"
#import "PhotoAnnotationProtocol.h"

NSString* const MultiRowCalloutReuseIdentifier = @"MultiRowCalloutReuse";

CGSize const kMultiRowCalloutCellSize = {245,44};
CGFloat const kMultiRowCalloutCellGap = 3;

@interface PhotoAnnotationView()

@property (nonatomic,strong) IBOutlet UILabel *titleLabel;
@property (nonatomic,strong) IBOutlet UIImageView *imgPreview;
@property (nonatomic,strong) IBOutlet UILabel *lbl_latitude;
@property (nonatomic,strong) IBOutlet UILabel *lbl_longitude;
@property (nonatomic,strong) IBOutlet UIButton *btn_disclosure;
@property (nonatomic,assign) CGFloat cellInsetX;
@property (nonatomic,assign) CGFloat cellOffsetY;
@property (nonatomic,assign) CGFloat contentHeight;
@property (nonatomic,assign) CGPoint offsetFromParent;
@property (nonatomic,readonly) CGFloat yShadowOffset;
@property (nonatomic,strong) UIView *contentView;
@property (nonatomic,readonly) CGSize actualSize; // contentSize + buffers
@property (nonatomic,assign) BOOL animateOnNextDrawRect;
@property (nonatomic,assign) CGRect endFrame;
@property (nonatomic,assign) CGFloat xPixelShift;

@end

@implementation PhotoAnnotationView

+ (PhotoAnnotationView *)calloutWithAnnotation:(id<PhotoAnnotationProtocol>)annotation onCalloutAccessoryTapped:(MultiRowAccessoryTappedBlock)block
{
    return [[PhotoAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:MultiRowCalloutReuseIdentifier onCalloutAccessoryTapped:block];
}

- (instancetype)initWithAnnotation:(id<PhotoAnnotationProtocol>)annotation reuseIdentifier:(NSString *)reuseIdentifier onCalloutAccessoryTapped:(MultiRowAccessoryTappedBlock)block {
    
    self = [super initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:reuseIdentifier];
    if (self)
    {
        _contentHeight = 90.0;
        _yShadowOffset = 6;
        _offsetFromParent = CGPointMake(8, -14); //this works for MKPinAnnotationView
        _cellInsetX = 15;
        _cellOffsetY = 10;
        _onCalloutAccessoryTapped = block;
        self.enabled = NO;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setAnnotation:(id <MKAnnotation>)annotation
{
    [super setAnnotation:annotation];
    if (!annotation)
    {
        return;
    }
    [self setTitleWithAnnotation:(id<PhotoAnnotationProtocol>)annotation];
    [self setCalloutCellsWithAnnotation:(id<PhotoAnnotationProtocol>)annotation];
    [self setContentWithAnnotation:(id<PhotoAnnotationProtocol>)annotation];
    [self prepareFrameSize];
    [self prepareOffset];
    [self prepareContentFrame];
    [self setNeedsDisplay];
}

- (void)setTitleWithAnnotation:(id<PhotoAnnotationProtocol>)annotation
{
    if (!_titleLabel)
    {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _titleLabel.textColor = [UIColor colorWithRed:242/255.f green:245/255.f blue:226/255.f alpha:1];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont boldSystemFontOfSize:14];
        _titleLabel.shadowColor = [UIColor darkTextColor];
        _titleLabel.shadowOffset = CGSizeMake(0, -1);
        [self.contentView addSubview:_titleLabel];
    }
    if (annotation)
    {
        _cellOffsetY = 35 + (2*kMultiRowCalloutCellGap);
        _titleLabel.text = annotation.title;
        _titleLabel.hidden = NO;
    }
    else {
        _titleLabel.hidden = YES;
        _cellOffsetY = 10;
    }
}

- (void) setContentWithAnnotation:(id<PhotoAnnotationProtocol>)annotation{
    
    if (!_imgPreview) {
        _imgPreview = [ [UIImageView alloc] initWithImage:[annotation image]];
    }
    [self.contentView addSubview:_imgPreview];
    
    if (!_lbl_latitude) {
        _lbl_latitude = [ [UILabel alloc] init];
        _lbl_latitude.text = [annotation latitude];
        _lbl_latitude.textColor = [UIColor colorWithRed:242/255.f green:245/255.f blue:226/255.f alpha:1];
        _lbl_latitude.font = [UIFont boldSystemFontOfSize:12];
        _lbl_latitude.shadowColor = [UIColor lightTextColor];
        _lbl_latitude.shadowOffset = CGSizeMake(0, 1);
        _lbl_latitude.adjustsFontSizeToFitWidth = YES;
    }
    [self.contentView addSubview:_lbl_latitude];
    
    if (!_lbl_longitude) {
        _lbl_longitude = [ [UILabel alloc] init];
        _lbl_longitude.text = [annotation longitude];
        _lbl_longitude.textColor = [UIColor colorWithRed:242/255.f green:245/255.f blue:226/255.f alpha:1];
        _lbl_longitude.font = [UIFont boldSystemFontOfSize:12];
        _lbl_longitude.shadowColor = [UIColor lightTextColor];
        _lbl_longitude.shadowOffset = CGSizeMake(0, 1);
        _lbl_longitude.adjustsFontSizeToFitWidth = YES;
    }
    [self.contentView addSubview:_lbl_longitude];
    
    if (!self.btn_disclosure) {
        self.btn_disclosure = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        self.btn_disclosure.exclusiveTouch = YES;
        self.btn_disclosure.enabled = YES;
        [self.btn_disclosure addTarget: self action:@selector(calloutAccessoryTapped:) forControlEvents: UIControlEventTouchUpInside | UIControlEventTouchCancel];
    }
    
    [self.contentView addSubview:self.btn_disclosure];


}

- (IBAction)calloutAccessoryTapped:(id)sender
{
    if (_onCalloutAccessoryTapped)
    {
        _onCalloutAccessoryTapped();
    }
}

- (void)setCalloutCellsWithAnnotation:(id<PhotoAnnotationProtocol>)annotation
{
    if (annotation)
    {
        [self setCalloutCells:[annotation calloutCells]];
    }
}

- (void)setCalloutCells:(NSArray *)calloutCells
{
    if (_calloutCells)
    {
        for (UIView *cell in _calloutCells)
        {
            [cell removeFromSuperview];
        }
    }
    _calloutCells = calloutCells;
    if (calloutCells)
    {
        _contentHeight = _cellOffsetY + ([calloutCells count] * (kMultiRowCalloutCellSize.height + kMultiRowCalloutCellGap));
        for (UIView *cell in calloutCells)
        {
            [self.contentView addSubview:cell];
        }
        [self prepareContentFrame];
        [self copyAccessoryTappedBlockToCalloutCells];
    }
    
}

#pragma mark - Block setters

- (void)setOnCalloutAccessoryTapped:(MultiRowAccessoryTappedBlock)onCalloutAccessoryTapped
{
    _onCalloutAccessoryTapped = onCalloutAccessoryTapped;
    [self copyAccessoryTappedBlockToCalloutCells];
}

- (void)copyAccessoryTappedBlockToCalloutCells
{
    if (!_onCalloutAccessoryTapped)
        return;
    /*for (MultiRowCalloutCell *cell in _calloutCells)
    {
        if (!cell.onCalloutAccessoryTapped)
        {
            cell.onCalloutAccessoryTapped = _onCalloutAccessoryTapped;
        }
    }*/
}

#pragma mark - Layout

- (void)prepareContentFrame
{
    CGRect contentRect = CGRectOffset(self.bounds, 10, 3);
    contentRect.size = [self contentSize];
    self.contentView.frame = contentRect;
    
    if (_titleLabel)
    {
        _titleLabel.frame = CGRectMake(100, 10, kMultiRowCalloutCellSize.width - (2*_cellInsetX), 25);
    }
    
    if ( _imgPreview ) {
        _imgPreview.frame = CGRectMake( _cellInsetX, 10, 70, 70 );
    }
    
    if (_lbl_latitude) {
        _lbl_latitude.frame = CGRectMake(100, 40, kMultiRowCalloutCellSize.width- (2*_cellInsetX), 15);
    }
    
    if (_lbl_longitude) {
        _lbl_longitude.frame = CGRectMake(100, 60, kMultiRowCalloutCellSize.width- (2*_cellInsetX), 15);
    }
    
    if ( self.btn_disclosure ) {
        self.btn_disclosure.frame = CGRectMake( 200, 40, 50, 50 );
    }
    
    /*NSInteger index = 0;
    for (MultiRowCalloutCell *cell in self.calloutCells)
    {
        cell.frame = CGRectMake(_cellInsetX, _cellOffsetY + index * (kMultiRowCalloutCellSize.height+kMultiRowCalloutCellGap), kMultiRowCalloutCellSize.width - (_cellInsetX*2), kMultiRowCalloutCellSize.height - (2*kMultiRowCalloutCellGap));
        [cell setNeedsDisplay];
        index++;
    }*/
}

- (CGSize)contentSize
{
    //_contentHeight = 150;
    return CGSizeMake(kMultiRowCalloutCellSize.width, _contentHeight);
}


#define CalloutMapAnnotationViewBottomShadowBufferSize 6.0f
#define CalloutMapAnnotationViewContentHeightBuffer 8.0f
#define CalloutMapAnnotationViewHeightAboveParent 2.0f

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    /*if (!self.mapView || !self.superview)
        return;  // superview can/will be nil during deallocation
    [self adjustMapRegionIfNeeded];
    [self animateIn];
    [self setNeedsLayout];*/
}

- (CGSize)actualSize
{
    CGSize size = [self contentSize];
    size.width += 20;
    size.height += (CalloutMapAnnotationViewContentHeightBuffer +
                    CalloutMapAnnotationViewBottomShadowBufferSize -
                    self.offsetFromParent.y);
    
    return size;
}

- (void)prepareFrameSize {
    CGRect frame = self.frame;
    frame.size = [self actualSize];
    self.frame = frame;
}

- (void)prepareOffset {
    CGPoint parentOrigin = [self.mapView convertPoint:self.parentAnnotationView.frame.origin fromView:self.parentAnnotationView.superview];
    CGFloat xOffset = (self.actualSize.width / 2) - (parentOrigin.x + self.offsetFromParent.x);
    //Add half our height plus half of the height of the annotation we are tied to so that our bottom lines up to its top
    //Then take into account its offset and the extra space needed for our drop shadow
    CGFloat yOffset = -(self.frame.size.height / 2 + self.parentAnnotationView.frame.size.height / 2) + self.offsetFromParent.y + CalloutMapAnnotationViewBottomShadowBufferSize;
    self.centerOffset = CGPointMake(xOffset, yOffset);
}

- (void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    
    CGFloat stroke = 1.0;
    CGFloat radius = 7.0;
    CGMutablePathRef path = CGPathCreateMutable();
    UIColor *color;
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat parentX = [self relativeParentXPosition];
    //Determine Size
    rect = self.bounds;
    rect.size.width -= stroke + 14;
    rect.size.height -= stroke + CalloutMapAnnotationViewHeightAboveParent - self.offsetFromParent.y + CalloutMapAnnotationViewBottomShadowBufferSize;
    rect.origin.x += stroke / 2.0 + 7;
    rect.origin.y += stroke / 2.0;
   
    //Create Path For Callout Bubble
    CGPathMoveToPoint(path, NULL, rect.origin.x, rect.origin.y + radius);
    CGPathAddLineToPoint(path, NULL, rect.origin.x, rect.origin.y + rect.size.height - radius);
    CGPathAddArc(path, NULL, rect.origin.x + radius, rect.origin.y + rect.size.height - radius, radius, M_PI, M_PI / 2, 1);
    CGPathAddLineToPoint(path, NULL, parentX - 15, rect.origin.y + rect.size.height);
    CGPathAddLineToPoint(path, NULL, parentX, rect.origin.y + rect.size.height + 15);
    CGPathAddLineToPoint(path, NULL, parentX + 15, rect.origin.y + rect.size.height);
    CGPathAddLineToPoint(path, NULL, rect.origin.x + rect.size.width - radius, rect.origin.y + rect.size.height);
    CGPathAddArc(path, NULL, rect.origin.x + rect.size.width - radius, rect.origin.y + rect.size.height - radius, radius, M_PI / 2, 0.0f, 1);
    CGPathAddLineToPoint(path, NULL, rect.origin.x + rect.size.width, rect.origin.y + radius);
    CGPathAddArc(path, NULL, rect.origin.x + rect.size.width - radius, rect.origin.y + radius, radius, 0.0f, -M_PI / 2, 1);
    CGPathAddLineToPoint(path, NULL, rect.origin.x + radius, rect.origin.y);
    CGPathAddArc(path, NULL, rect.origin.x + radius, rect.origin.y + radius, radius, -M_PI / 2, M_PI, 1);
    CGPathCloseSubpath(path);
    
    //Fill Callout Bubble & Add Shadow
    color = [[UIColor blackColor] colorWithAlphaComponent:.6];
    [color setFill];
    CGContextAddPath(context, path);
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, CGSizeMake (0, self.yShadowOffset), 6, [UIColor colorWithWhite:0 alpha:.5].CGColor);
    CGContextFillPath(context);
    CGContextRestoreGState(context);
    
    //Stroke Callout Bubble
    color = [[UIColor darkGrayColor] colorWithAlphaComponent:.9];
    [color setStroke];
    CGContextSetLineWidth(context, stroke);
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextAddPath(context, path);
    CGContextStrokePath(context);
    
    //Determine Size for Gloss
    CGRect glossRect = self.bounds;
    glossRect.size.width = rect.size.width - stroke;
    glossRect.size.height = (rect.size.height - stroke) / 2;
    glossRect.origin.x = rect.origin.x + stroke / 2;
    glossRect.origin.y += rect.origin.y + stroke / 2;
    
    CGFloat glossTopRadius = radius - stroke / 2;
    CGFloat glossBottomRadius = radius / 1.5;
    
    //Create Path For Gloss
    CGMutablePathRef glossPath = CGPathCreateMutable();
    CGPathMoveToPoint(glossPath, NULL, glossRect.origin.x, glossRect.origin.y + glossTopRadius);
    CGPathAddLineToPoint(glossPath, NULL, glossRect.origin.x, glossRect.origin.y + glossRect.size.height - glossBottomRadius);
    CGPathAddArc(glossPath, NULL, glossRect.origin.x + glossBottomRadius, glossRect.origin.y + glossRect.size.height - glossBottomRadius, glossBottomRadius, M_PI, M_PI / 2, 1);
    CGPathAddLineToPoint(glossPath, NULL, glossRect.origin.x + glossRect.size.width - glossBottomRadius, glossRect.origin.y + glossRect.size.height);
    CGPathAddArc(glossPath, NULL, glossRect.origin.x + glossRect.size.width - glossBottomRadius, glossRect.origin.y + glossRect.size.height - glossBottomRadius, glossBottomRadius, M_PI / 2, 0.0f, 1);
    CGPathAddLineToPoint(glossPath, NULL, glossRect.origin.x + glossRect.size.width, glossRect.origin.y + glossTopRadius);
    CGPathAddArc(glossPath, NULL, glossRect.origin.x + glossRect.size.width - glossTopRadius, glossRect.origin.y + glossTopRadius, glossTopRadius, 0.0f, -M_PI / 2, 1);
    CGPathAddLineToPoint(glossPath, NULL, glossRect.origin.x + glossTopRadius, glossRect.origin.y);
    CGPathAddArc(glossPath, NULL, glossRect.origin.x + glossTopRadius, glossRect.origin.y + glossTopRadius, glossTopRadius, -M_PI / 2, M_PI, 1);
    CGPathCloseSubpath(glossPath);
    
    //Fill Gloss Path
    CGContextAddPath(context, glossPath);
    CGContextClip(context);
    CGFloat colors[] =
    {
        1, 1, 1, .3,
        1, 1, 1, .1,
    };
    CGFloat locations[] = { 0, 1.0 };
    CGGradientRef gradient = CGGradientCreateWithColorComponents(space, colors, locations, 2);
    CGPoint startPoint = glossRect.origin;
    CGPoint endPoint = CGPointMake(glossRect.origin.x, glossRect.origin.y + glossRect.size.height);
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    
    //Gradient Stroke Gloss Path
    CGContextAddPath(context, glossPath);
    CGContextSetLineWidth(context, 2);
    CGContextReplacePathWithStrokedPath(context);
    CGContextClip(context);
    CGFloat colors2[] =
    {
        1, 1, 1, .3,
        1, 1, 1, .1,
        1, 1, 1, .0,
    };
    CGFloat locations2[] = { 0, .1, 1.0 };
    CGGradientRef gradient2 = CGGradientCreateWithColorComponents(space, colors2, locations2, 3);
    CGPoint startPoint2 = glossRect.origin;
    CGPoint endPoint2 = CGPointMake(glossRect.origin.x, glossRect.origin.y + glossRect.size.height);
    CGContextDrawLinearGradient(context, gradient2, startPoint2, endPoint2, 0);
    
    //Cleanup
    CGPathRelease(path);
    CGPathRelease(glossPath);
    CGColorSpaceRelease(space);
    CGGradientRelease(gradient);
    CGGradientRelease(gradient2);

}

- (CGFloat)relativeParentXPosition
{
    if (!_mapView || !_parentAnnotationView)
        return 0;
    CGPoint parentOrigin = [self.mapView convertPoint:self.parentAnnotationView.frame.origin fromView:self.parentAnnotationView.superview];
    return parentOrigin.x + self.offsetFromParent.x + self.xPixelShift;
}

- (UIView *)contentView
{
    if (!_contentView)
    {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor clearColor];
        _contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:_contentView];
    }
    return _contentView;
}

@end
