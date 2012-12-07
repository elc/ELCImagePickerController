#import "ELCImagePickerController.h"

@interface MainController : UIViewController <ELCImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate>

@property IBOutlet UIScrollView *scrollview;

- (IBAction) launchController;

@end

