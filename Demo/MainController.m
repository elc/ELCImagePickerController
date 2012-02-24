#import "AppDelegate.h"
#import "MainController.h"
#import "ELCImagePickerController.h"
#import "ELCAlbumPickerController.h"

@implementation MainController
@synthesize scrollview;

- (IBAction) launchController
{
    ELCAlbumPickerController *albumController = [[ELCAlbumPickerController alloc] initWithNibName:nil bundle:nil];
	ELCImagePickerController *elcPicker = [[ELCImagePickerController alloc] initWithRootViewController:albumController];
    [albumController setParent:elcPicker];
	[elcPicker setDelegate:self];
	[self presentModalViewController:elcPicker animated:YES];
}

#pragma mark ELCImagePickerControllerDelegate

- (void) elcImagePickerController: (ELCImagePickerController*) picker didFinishPickingMediaWithInfo: (NSArray*) info
{
	[self dismissModalViewControllerAnimated:YES];

    for (UIView *v in [scrollview subviews])
        [v removeFromSuperview];
    
	CGRect workingFrame = scrollview.frame;
	workingFrame.origin.x = 0;
	
	for (NSDictionary *dict in info)
    {
		UIImageView *imageview = [[UIImageView alloc] initWithImage:[dict objectForKey:UIImagePickerControllerOriginalImage]];
		[imageview setContentMode:UIViewContentModeScaleAspectFit];
		imageview.frame = workingFrame;
		
		[scrollview addSubview:imageview];
		
		workingFrame.origin.x = workingFrame.origin.x + workingFrame.size.width;
	}
	
	[scrollview setPagingEnabled:YES];
	[scrollview setContentSize:CGSizeMake(workingFrame.origin.x, workingFrame.size.height)];
}

- (void) elcImagePickerControllerDidCancel: (ELCImagePickerController*) picker
{
	[self dismissModalViewControllerAnimated:YES];
}

@end
