//
//  Asset.m
//
//  Created by Matt Tuzzolo on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import "ELCAsset.h"
#import "ELCAssetTablePicker.h"

@implementation ELCAsset

@synthesize asset;
@synthesize parent;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}

-(id)initWithAsset:(ALAsset*)_asset {
	
	if (self = [super initWithFrame:CGRectMake(0, 0, 0, 0)]) {
		
		self.asset = _asset;
		
		CGRect viewFrames = CGRectMake(0, 0, 75, 75);
		
		UIImageView *assetImageView = [[UIImageView alloc] initWithFrame:viewFrames];
		[assetImageView setContentMode:UIViewContentModeScaleToFill];
		[assetImageView setImage:[UIImage imageWithCGImage:[self.asset thumbnail]]];
		[self addSubview:assetImageView];
		[assetImageView release];
        
        if ([_asset valueForProperty:ALAssetPropertyType] == ALAssetTypeVideo)
        { // Show duration in thumbnail
            int viewHeight = 16;
            UIView *durationContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(viewFrames) - viewHeight, CGRectGetWidth(viewFrames), viewHeight)];
            durationContainerView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.6f];
            [self addSubview:durationContainerView];
            
            UILabel *durationLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            durationLabel.backgroundColor = [UIColor clearColor];
            durationLabel.textColor = [UIColor whiteColor];
            durationLabel.font = [UIFont boldSystemFontOfSize:12];
            [durationContainerView addSubview:durationLabel];
            
            double duration = [[_asset valueForProperty:ALAssetPropertyDuration] doubleValue];
            NSDateFormatter *durationFormatter = [[NSDateFormatter alloc] init];
            [durationFormatter setDateFormat:@"mm:ss"];
            durationLabel.text = [durationFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:duration]];
            [durationLabel sizeToFit];
            
            durationLabel.center = CGPointMake(0, CGRectGetHeight(durationContainerView.bounds)/2);
            
            CGRect durationFrame = durationLabel.bounds;
            CGRect containerContentRect = CGRectInset(durationContainerView.frame, 4, 2);
            durationFrame.origin.x = CGRectGetMaxX(containerContentRect) - CGRectGetWidth(durationFrame);
            
            durationLabel.frame = CGRectIntegral(durationFrame);
            
            CGSize imageSize = [self cameraImageSize];
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0,imageSize.width, imageSize.height)];
            imageView.image = [self cameraImage];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            
            // Layouting
            [durationContainerView addSubview:imageView];
            imageView.center = CGPointMake(CGRectGetMinX(containerContentRect) + CGRectGetMidX(imageView.bounds), CGRectGetMidY(durationContainerView.bounds));
            imageView.frame = CGRectIntegral(imageView.frame);
        }
		
		overlayView = [[UIImageView alloc] initWithFrame:viewFrames];
		[overlayView setImage:[UIImage imageNamed:@"Overlay.png"]];
		[overlayView setHidden:YES];
		[self addSubview:overlayView];
    }
    
	return self;	
}

-(void)toggleSelection {
    
	overlayView.hidden = !overlayView.hidden;
    
//    if([(ELCAssetTablePicker*)self.parent totalSelectedAssets] >= 10) {
//        
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Maximum Reached" message:@"" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
//		[alert show];
//		[alert release];	
//
//        [(ELCAssetTablePicker*)self.parent doneAction:nil];
//    }
}

-(BOOL)selected {
	
	return !overlayView.hidden;
}

-(void)setSelected:(BOOL)_selected {
    
	[overlayView setHidden:!_selected];
}

- (void)dealloc 
{    
    self.asset = nil;
	[overlayView release];
    [super dealloc];
}

- (CGSize)cameraImageSize
{
    // width 38, height 20 <= retina
    return CGSizeMake(14, 8);
}

- (NSData *)dataWithBase64EncodedString:(NSString *)string {
    //
    //  NSData+Base64.m
    //
    //  Version 1.0.2
    //
    //  Created by Nick Lockwood on 12/01/2012.
    //  Copyright (C) 2012 Charcoal Design
    //
    //  Distributed under the permissive zlib License
    //  Get the latest version from here:
    //
    //  https://github.com/nicklockwood/Base64
    //
    //  This software is provided 'as-is', without any express or implied
    //  warranty.  In no event will the authors be held liable for any damages
    //  arising from the use of this software.
    //
    //  Permission is granted to anyone to use this software for any purpose,
    //  including commercial applications, and to alter it and redistribute it
    //  freely, subject to the following restrictions:
    //
    //  1. The origin of this software must not be misrepresented; you must not
    //  claim that you wrote the original software. If you use this software
    //  in a product, an acknowledgment in the product documentation would be
    //  appreciated but is not required.
    //
    //  2. Altered source versions must be plainly marked as such, and must not be
    //  misrepresented as being the original software.
    //
    //  3. This notice may not be removed or altered from any source distribution.
    //
    const char lookup[] = {
        99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99,
        99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99,
        99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 62, 99, 99, 99, 63,
        52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 99, 99, 99, 99, 99, 99,
        99,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14,
        15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 99, 99, 99, 99, 99,
        99, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
        41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 99, 99, 99, 99, 99
    };
    
    NSData *inputData = [string dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    long long inputLength = [inputData length];
    const unsigned char *inputBytes = [inputData bytes];
    
    long long maxOutputLength = (inputLength / 4 + 1) * 3;
    NSMutableData *outputData = [NSMutableData dataWithLength:maxOutputLength];
    unsigned char *outputBytes = (unsigned char *)[outputData mutableBytes];
    
    int accumulator = 0;
    long long outputLength = 0;
    unsigned char accumulated[] = {0, 0, 0, 0};
    for (long long i = 0; i < inputLength; i++) {
        unsigned char decoded = lookup[inputBytes[i] & 0x7F];
        if (decoded != 99) {
            accumulated[accumulator] = decoded;
            if (accumulator == 3) {
                outputBytes[outputLength++] = (accumulated[0] << 2) | (accumulated[1] >> 4);
                outputBytes[outputLength++] = (accumulated[1] << 4) | (accumulated[2] >> 2);
                outputBytes[outputLength++] = (accumulated[2] << 6) | accumulated[3];
            }
            accumulator = (accumulator + 1) % 4;
        }
    }
    
    //handle left-over data
    if (accumulator > 0) outputBytes[outputLength] = (accumulated[0] << 2) | (accumulated[1] >> 4);
    if (accumulator > 1) outputBytes[++outputLength] = (accumulated[1] << 4) | (accumulated[2] >> 2);
    if (accumulator > 2) outputLength++;
    
    //truncate data to match actual output length
    outputData.length = outputLength;
    return outputLength? outputData: nil;
}

- (UIImage *)cameraImage
{
    NSString *base64EncodedImageString = @"iVBORw0KGgoAAAANSUhEUgAAABwAAAAQCAYAAAAFzx/vAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAA2ZpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDUuMC1jMDYwIDYxLjEzNDc3NywgMjAxMC8wMi8xMi0xNzozMjowMCAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0UmVmPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VSZWYjIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD0ieG1wLmRpZDo2NDJBN0VEODExMjA2ODExOERCQkE1RTE4NUQ0QjhBMiIgeG1wTU06RG9jdW1lbnRJRD0ieG1wLmRpZDpDMzg2OTk4MDQyQjcxMUUyODYzOEI5QjIxMzQ0MEJDQiIgeG1wTU06SW5zdGFuY2VJRD0ieG1wLmlpZDpDMzg2OTk3RjQyQjcxMUUyODYzOEI5QjIxMzQ0MEJDQiIgeG1wOkNyZWF0b3JUb29sPSJBZG9iZSBQaG90b3Nob3AgQ1M1IE1hY2ludG9zaCI+IDx4bXBNTTpEZXJpdmVkRnJvbSBzdFJlZjppbnN0YW5jZUlEPSJ4bXAuaWlkOjY1MkE3RUQ4MTEyMDY4MTE4REJCQTVFMTg1RDRCOEEyIiBzdFJlZjpkb2N1bWVudElEPSJ4bXAuZGlkOjY0MkE3RUQ4MTEyMDY4MTE4REJCQTVFMTg1RDRCOEEyIi8+IDwvcmRmOkRlc2NyaXB0aW9uPiA8L3JkZjpSREY+IDwveDp4bXBtZXRhPiA8P3hwYWNrZXQgZW5kPSJyIj8+3806ewAAAMdJREFUeNpi+P//vxAQX/pPGegFYgY82AaIvwFxJogz5z91gBMeyz5D1WQyMTAw2DBQB9hjEbME4u1AzAMTAFnISSUL2QhZBrOQFsAMahk/ugQtLDQG4l3YLKOFhSDL9uKyjBYWcmKJS5paeASIPYH4O70sBIGDQOyPy1JapdLduCyllYUwS4OA+Be9LASBHeiWgix8QSXDX+MQ3wrEETBLQRYupoJloLhaj0ceJBcNthRYgjMDcQsQ/ySzlniIp6ZAx2wAAQYAhnhI8eeyV8IAAAAASUVORK5CYII=";
    return [[UIImage alloc] initWithData:[self dataWithBase64EncodedString:base64EncodedImageString]];
}

@end

