//
//  AssetCell.m
//
//  Created by ELC on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import "ELCAssetCell.h"
#import "ELCAsset.h"
#import "ELCConsole.h"
#import "ELCOverlayImageView.h"

@interface ELCAssetCell ()

@property (nonatomic, strong) NSArray *rowAssets;
@property (nonatomic, strong) NSMutableArray *imageViewArray;
@property (nonatomic, strong) NSMutableArray *overlayViewArray;

@end

@implementation ELCAssetCell

//Using auto synthesizers

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
	if (self) {
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellTapped:)];
        [self addGestureRecognizer:tapRecognizer];
        
        NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithCapacity:4];
        self.imageViewArray = mutableArray;
        
        NSMutableArray *overlayArray = [[NSMutableArray alloc] initWithCapacity:4];
        self.overlayViewArray = overlayArray;
        
        self.alignmentLeft = YES;
	}
	return self;
}

- (UIImage *)imageForAsset:(ALAsset *)asset
{
    UIImage *image;
    
    image = [UIImage imageWithCGImage:asset.thumbnail];
    if([[asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]) {
        UIImage *typeImage;
        UIView *view;
        UIView *typeView;
        NSNumber *duration;
        UILabel *durationLabel;
        NSInteger nbSeconds;
        NSInteger nbMinutes;
        NSInteger nbHours;
        CAGradientLayer *gradientLayer;
        UIImageView *imageView;
        
        imageView = [[UIImageView alloc] initWithImage:image];
        typeImage = [UIImage imageNamed:@"videoType.png"];
        
        duration = [asset valueForProperty:ALAssetPropertyDuration];
        durationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, image.size.height - 29, image.size.width - 10, 20)];
        durationLabel.textColor = [UIColor whiteColor];
        durationLabel.textAlignment = NSTextAlignmentRight;
        durationLabel.font = [durationLabel.font fontWithSize:24];
        nbHours = duration.doubleValue/60/60;
        nbMinutes = duration.doubleValue/60 - nbHours*60;
        nbSeconds = duration.doubleValue - nbMinutes*60 - nbHours*60*60;
        if(nbHours == 0) {
            durationLabel.text = [NSString stringWithFormat:@"%02d:%02d", (int)nbMinutes, (int)nbSeconds];
        }
        else {
            durationLabel.text = [NSString stringWithFormat:@"%d:%02d:%02d", (int)nbHours, (int)nbMinutes, (int)nbSeconds];
        }
        
        gradientLayer = [CAGradientLayer layer];
        gradientLayer.colors = @[(id)[UIColor colorWithWhite:0 alpha:0].CGColor, (id)[UIColor colorWithWhite:0 alpha:0.7].CGColor];
        gradientLayer.frame = CGRectMake(0, image.size.height - 34, image.size.width , 34);
        [imageView.layer addSublayer:gradientLayer];
        
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
        typeView = [[UIImageView alloc] initWithImage:typeImage];
        [view addSubview:imageView];
        [view addSubview:typeView];
        [view addSubview:durationLabel];
        typeView.contentMode = UIViewContentModeCenter;
        typeView.frame = CGRectMake(10, view.bounds.size.height - 31, 28, 28);
        
        UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0);
        [view.layer renderInContext:UIGraphicsGetCurrentContext()];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    return image;
}

- (void)setAssets:(NSArray *)assets
{
    self.rowAssets = assets;
	for (UIImageView *view in _imageViewArray) {
        [view removeFromSuperview];
	}
    for (ELCOverlayImageView *view in _overlayViewArray) {
        [view removeFromSuperview];
	}
    //set up a pointer here so we don't keep calling [UIImage imageNamed:] if creating overlays
    UIImage *overlayImage = nil;
    for (int i = 0; i < [_rowAssets count]; ++i) {

        ELCAsset *asset = [_rowAssets objectAtIndex:i];

        if (i < [_imageViewArray count]) {
            UIImageView *imageView = [_imageViewArray objectAtIndex:i];
            imageView.image = [self imageForAsset:asset.asset];
        } else {
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[self imageForAsset:asset.asset]];
            [_imageViewArray addObject:imageView];
        }
        
        if (i < [_overlayViewArray count]) {
            ELCOverlayImageView *overlayView = [_overlayViewArray objectAtIndex:i];
            overlayView.hidden = asset.selected ? NO : YES;
            overlayView.labIndex.text = [NSString stringWithFormat:@"%d", asset.index + 1];
        } else {
            if (overlayImage == nil) {
                overlayImage = [UIImage imageNamed:@"Overlay.png"];
            }
            ELCOverlayImageView *overlayView = [[ELCOverlayImageView alloc] initWithImage:overlayImage];
            [_overlayViewArray addObject:overlayView];
            overlayView.hidden = asset.selected ? NO : YES;
            overlayView.labIndex.text = [NSString stringWithFormat:@"%d", asset.index + 1];
        }
    }
}

- (void)cellTapped:(UITapGestureRecognizer *)tapRecognizer
{
    CGPoint point = [tapRecognizer locationInView:self];
    int c = (int32_t)self.rowAssets.count;
    CGFloat totalWidth = c * 75 + (c - 1) * 4;
    CGFloat startX;
    
    if (self.alignmentLeft) {
        startX = 4;
    }else {
        startX = (self.bounds.size.width - totalWidth) / 2;
    }
    
	CGRect frame = CGRectMake(startX, 2, 75, 75);
	
	for (int i = 0; i < [_rowAssets count]; ++i) {
        if (CGRectContainsPoint(frame, point)) {
            ELCAsset *asset = [_rowAssets objectAtIndex:i];
            asset.selected = !asset.selected;
            ELCOverlayImageView *overlayView = [_overlayViewArray objectAtIndex:i];
            overlayView.hidden = !asset.selected;
            if (asset.selected) {
                asset.index = [[ELCConsole mainConsole] numOfSelectedElements];
                [overlayView setIndex:asset.index+1];
                [[ELCConsole mainConsole] addIndex:asset.index];
            }
            else
            {
                int lastElement = [[ELCConsole mainConsole] numOfSelectedElements] - 1;
                [[ELCConsole mainConsole] removeIndex:lastElement];
            }
            break;
        }
        frame.origin.x = frame.origin.x + frame.size.width + 4;
    }
}

- (void)layoutSubviews
{
    int c = (int32_t)self.rowAssets.count;
    CGFloat totalWidth = c * 75 + (c - 1) * 4;
    CGFloat startX;
    
    if (self.alignmentLeft) {
        startX = 4;
    }else {
        startX = (self.bounds.size.width - totalWidth) / 2;
    }
    
	CGRect frame = CGRectMake(startX, 2, 75, 75);
	
	for (int i = 0; i < [_rowAssets count]; ++i) {
		UIImageView *imageView = [_imageViewArray objectAtIndex:i];
		[imageView setFrame:frame];
		[self addSubview:imageView];
        
        ELCOverlayImageView *overlayView = [_overlayViewArray objectAtIndex:i];
        [overlayView setFrame:frame];
        [self addSubview:overlayView];
		
		frame.origin.x = frame.origin.x + frame.size.width + 4;
	}
}


@end
