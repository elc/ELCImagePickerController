//
//  ELCStreetspotrOverlay.m
//  Streetspotr
//
//  Created by Manfred Schwind on 03.02.15.
//  Copyright (c) 2015 Streetspotr. All rights reserved.
//

#import "ELCStreetspotrOverlay.h"

@interface UIColor (Streetspotr)
+ (UIColor *)streetspotrTurquois;
@end

@implementation UIImage (ELCStreetspotrOverlay)

+ (UIImage *)streetspotrELCOverlayImage
{
	static __weak UIImage *cachedImage = nil;
	if (cachedImage) {
		return cachedImage;
	}

	UIGraphicsBeginImageContextWithOptions(CGSizeMake(75.0f, 75.0f), NO, 0.0f);

	{	// ********* BEGIN PaintCode code

		//// General Declarations
		CGContextRef context = UIGraphicsGetCurrentContext();

		//// Color Declarations
		UIColor* overlayColor = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 0.3];
		UIColor* tintColor = [UIColor streetspotrTurquois];		// MODIFIED!

		//// Shadow Declarations
		UIColor* shadow = [[UIColor blackColor] colorWithAlphaComponent: 0.3];
		CGSize shadowOffset = CGSizeMake(0.1, 2.1);
		CGFloat shadowBlurRadius = 2.5;

		//// Abstracted Attributes
		NSString* checkContent = @"\uf00c";						// MODIFIED!


		//// Rectangle Drawing
		UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRect: CGRectMake(0, 0, 75, 75)];
		[overlayColor setFill];
		[rectanglePath fill];


		//// OuterOval Drawing
		UIBezierPath* outerOvalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(46, 46, 24, 24)];
		CGContextSaveGState(context);
		CGContextSetShadowWithColor(context, shadowOffset, shadowBlurRadius, shadow.CGColor);
		[[UIColor whiteColor] setFill];
		[outerOvalPath fill];
		CGContextRestoreGState(context);



		//// InnerOval Drawing
		UIBezierPath* innerOvalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(48, 48, 20, 20)];
		[tintColor setFill];
		[innerOvalPath fill];


		//// Check Drawing
		CGRect checkRect = CGRectMake(46, 51, 24, 19);
		NSMutableParagraphStyle* checkStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
		[checkStyle setAlignment: NSTextAlignmentCenter];

		NSDictionary* checkFontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"FontAwesome5Free-Solid" size: 14], NSForegroundColorAttributeName: [UIColor whiteColor], NSParagraphStyleAttributeName: checkStyle};
		
		[checkContent drawInRect: checkRect withAttributes: checkFontAttributes];
		
}	// ********* END PaintCode code

	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	cachedImage = image;
	return image;
}

@end
