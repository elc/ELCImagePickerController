#import "ELCImagePickerController.h"

@interface MainController : UIViewController <ELCImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate>

@property(retain) IBOutlet UIScrollView *scrollview;

- (IBAction) launchController;

@end

