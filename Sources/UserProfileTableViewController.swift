
import UIKit
import MobileCoreServices

class UserProfileViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UITextFieldDelegate, UIAlertViewDelegate, UIGestureRecognizerDelegate {

    private var imagePicker = UIImagePickerController()

    var isMyProfile : Bool = true
    var currentUserId : String?
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var nickNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
	
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var folderButton: UIButton!
    @IBOutlet weak var okButton: UIBarButtonItem!
    @IBOutlet weak var backBarButton: UIBarButtonItem!
  
    @IBAction func saveUserProfile(notification: AnyObject) {
        if !validateFieldsForCorrectInput()
        {
            return
        }
        self.view.endEditing(true)
        if self.isProfileShouldSave()
        {
            self.saveProfile()
        }
        (self.navigationController as NavigationSideBarController).animateViewAppear(nil)
    }

    @IBAction func cameraButtonAction(sender: AnyObject) {

        self.getFromCamera(self)
    }

    @IBAction func albumButtonAction(sender: AnyObject) {

        self.getFromGallery(self)
    }
    
    //hides keyboard when 'return' key pressed
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        textField.resignFirstResponder()
        return true
    }
  
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool
    {
        if isMyProfile
        {
            return true
        }
        else
        {
            return false
        }
    }

	func updateUserProfileInfo()
    {
		self.nameTextField.text = UserProfile.currentUserProfile().name
		self.surnameTextField.text = UserProfile.currentUserProfile().surname
		self.nickNameTextField.text = UserProfile.currentUserProfile().userNickName
		self.emailTextField.text = UserProfile.currentUserProfile().email
        self.phoneNumberTextField.text = ""
        self.textField(self.phoneNumberTextField, shouldChangeCharactersInRange: NSRange(location: 0, length: 0), replacementString: UserProfile.currentUserProfile().phoneNumber)
		self.userImageView.image = UserProfile.currentUserProfile().userAvatarImage
	}

    @IBAction func backButtonPress(sender: AnyObject)
    {
        if isMyProfile
        {
            if !validateFieldsForCorrectInput()
            {
                return
            }
            if self.isProfileShouldSave()
            {
                showAlertViewToSaveProfile()
            }
            else
            {
                (self.navigationController as NavigationSideBarController).animateViewAppear(sender)
            }
        }
        else
        {
            performSegueWithIdentifier("unwindBack", sender: self)
        }
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        if isMyProfile
        {
            navigationController?.setToolbarHidden(false, animated: false)
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if isMyProfile
        {
            self.updateUserProfileInfo()
            navigationController?.setToolbarHidden(false, animated: false)
            
            emailTextField.enabled = false
        }
        else
        {
            cameraButton.hidden = true
            folderButton.hidden = true
            okButton.enabled = false
            okButton.image = UIImage()
            
            backBarButton.title = "< Back"
            backBarButton.image = nil
            
            var fields : NSDictionary = [ kUserId : currentUserId! ]
            
            GoServer.instance.sendRequestWith("user/profile", method: "GET", body: nil, headerFields: fields)
            {
                (result, code) in
                
                if code == 0
                {
                    if let res : NSDictionary = result
                    {
                        self.nameTextField.text = res.objectForKey(kUserName) as String
                        self.surnameTextField.text = res.objectForKey(kUserSurname) as String
                        self.phoneNumberTextField.text = res.objectForKey(kUserPhoneNumber) as String
                        self.nickNameTextField.text = res.objectForKey(kUserNickName) as String
                        self.emailTextField.text = res.objectForKey(kUserEmail) as String
                        self.userImageView.loadImageFrom(self.currentUserId, imageId: (res.objectForKey(kUserImageId) as String))
                    }
                }
                else
                {
                    self.performSegueWithIdentifier("unwindBack", sender: self)
                    self.presentAlert("Error", message:"Failed to load users profile")
                }
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewDidDisappear(animated)
        if isMyProfile
        {
            navigationController?.setToolbarHidden(true, animated: false)
        }
    }
    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if !validateFieldsForCorrectInput()
        {
            return false
        }
        if self.isProfileShouldSave()
        {
            showAlertViewToSaveProfile()
            return false
        }
        return true
    }
    
    func getFromGallery(sender: AnyObject){
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum){
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum;
            imagePicker.allowsEditing = true
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }

    func getFromCamera(sender : AnyObject){
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.Camera;
            imagePicker.mediaTypes = [kUTTypeImage]
            imagePicker.allowsEditing = true
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        var tmpImage: UIImage?
        
        tmpImage = info[UIImagePickerControllerEditedImage] as? UIImage
        if let img = tmpImage {
            userImageView.image = scaleImage(img)
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
	
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController?, animated: Bool)
    {
        if viewController != nil
        {
            if navigationController.viewControllers.count == 2 ||
                NSStringFromClass(viewController!.dynamicType) == "PLUICameraViewController"
            {
                var plCropOverlay : UIView = viewController!.view.subviews[1].subviews[0] as UIView
                plCropOverlay.hidden = true
                viewController!.view.layer.addSublayer(self.overlayLayer())
            }
        }
    }

    func overlayLayer() -> CAShapeLayer
    {
        let screenHeight : CGFloat = UIScreen.mainScreen().bounds.size.height
        let screenWidth : CGFloat = UIScreen.mainScreen().bounds.size.width
        let diameter : CGFloat = 300;
        var position : CGFloat = (screenHeight - diameter) / 2.0
        
        var circleLayer : CAShapeLayer = CAShapeLayer();
        var circlePath : UIBezierPath = UIBezierPath(ovalInRect: CGRectMake((screenWidth - diameter)/2.0, position, diameter, diameter))
        circlePath.usesEvenOddFillRule = true
        
        circleLayer.fillColor = UIColor.clearColor().CGColor
        
        var path : UIBezierPath = UIBezierPath(roundedRect: CGRectMake(0, 0, screenWidth, screenHeight - 72), cornerRadius: 0)
        path.appendPath(circlePath)
        path.usesEvenOddFillRule = true
        
        var fillLayer : CAShapeLayer = CAShapeLayer();
        fillLayer.path = path.CGPath
        fillLayer.fillRule = kCAFillRuleEvenOdd
        fillLayer.fillColor = UIColor.blackColor().CGColor
        fillLayer.opacity = 0.5
        return fillLayer
    }
    
    @IBAction func logoutAndClearCacheButton(sender: AnyObject) {
        GoServer.instance.logout {
            (code) in
            if code == .OK {
                println("Logout successful!!!")
            } else {
                println("Logout server error!!!")
            }
        }
        self.clearPrefs()
        self.performSegueWithIdentifier("Logout", sender: sender)
    }
    
    func clearPrefs() {
        var defaults : NSUserDefaults = NSUserDefaults.standardUserDefaults()
        defaults.removeObjectForKey(kCurrentUserImageIdentifierKey)
        defaults.removeObjectForKey("username")
        defaults.removeObjectForKey("password")

        var fileManager = NSFileManager.defaultManager()
        var isCleared = fileManager.removeItemAtPath(cacheDirectory, error: nil)
        println("did clear all cache dir: \(isCleared)")
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if isMyProfile
        {
            if textField == phoneNumberTextField {
                let areaCodeMaxLength = 3
                let countryCodeMaxLength = 3
                let localCodeMaxLength = 7
                let maxLength = 18
                
                var validationSet: NSCharacterSet = NSCharacterSet.decimalDigitCharacterSet().invertedSet
                var stringArray: NSArray = string.componentsSeparatedByCharactersInSet(validationSet)
                if stringArray.count > 1 {
                    return false
                }
                
                var newString : String = (textField.text as NSString).stringByReplacingCharactersInRange(range, withString: string)
                if countElements(newString) > maxLength {
                    return false
                }
                
                var newStringArray: NSArray = newString.componentsSeparatedByCharactersInSet(validationSet)
                var numberString: NSString = newStringArray.componentsJoinedByString("")
                
                if textField.text == "" && numberString != "" && numberString.characterAtIndex(0) == 48 {
                    numberString = numberString.stringByReplacingCharactersInRange(NSRange(location: 0, length: 0), withString: "38")
                }
                
                if numberString.length > 0 {
                    numberString = numberString.stringByReplacingCharactersInRange(NSRange(location: 0, length: 0), withString: "+")
                    
                    if numberString.length > areaCodeMaxLength {
                        numberString = numberString.stringByReplacingCharactersInRange(NSRange(location: 3, length: 0), withString: " (")
                        
                        if numberString.length > areaCodeMaxLength + countryCodeMaxLength + 2 {
                            numberString = numberString.stringByReplacingCharactersInRange(NSRange(location: 8, length: 0), withString: ") ")
                            
                            if numberString.length > 13 {
                                numberString = numberString.stringByReplacingCharactersInRange(NSRange(location: 13, length: 0), withString: "-")
                            }
                        }
                    }
                }
                textField.text = numberString
                return false
            }
            return true
        }
        else
        {
            return false
        }
    }
    
    private func numberFromTextfield() -> String
    {
        var validationSet: NSCharacterSet = NSCharacterSet.decimalDigitCharacterSet().invertedSet
        var newStringArray: NSArray = phoneNumberTextField.text.componentsSeparatedByCharactersInSet(validationSet)
        var numberString: NSString = newStringArray.componentsJoinedByString("")
        return numberString
    }
    
    func showAlertViewToSaveProfile()
    {
        if !validateFieldsForCorrectInput()
        {
            return
        }
        let alert: UIAlertView = UIAlertView(title: "Save Profile?", message: "", delegate: self, cancelButtonTitle: "CANCEL", otherButtonTitles: "OK")
        alert.show()
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int)
    {
        if buttonIndex == 1
        {
            self.view.endEditing(true)
            self.saveProfile()
            (self.navigationController as NavigationSideBarController).animateViewAppear(nil)
        }
         else if buttonIndex == 0
        {
            self.updateUserProfileInfo()
        }
    }
    
    private func saveProfile()
    {
        if !validateFieldsForCorrectInput()
        {
            return
        }
        UserProfile.currentUserProfile().name = self.nameTextField.text
        UserProfile.currentUserProfile().surname = self.surnameTextField.text
        UserProfile.currentUserProfile().userNickName = self.nickNameTextField.text
        UserProfile.currentUserProfile().email = self.emailTextField.text
        UserProfile.currentUserProfile().phoneNumber = self.numberFromTextfield()
        UserProfile.currentUserProfile().userAvatarImage = self.userImageView.image!
        UserProfile.currentUserProfile().saveUserProfile()
    }
    
    private func isProfileShouldSave() -> Bool
    {
        if (UserProfile.currentUserProfile().name != self.nameTextField.text)
        {
            return true
        }
        else if (UserProfile.currentUserProfile().surname != self.surnameTextField.text)
        {
            return true
        }
        else if (UserProfile.currentUserProfile().userNickName != self.nickNameTextField.text)
        {
            return true
        }

        else if (UserProfile.currentUserProfile().phoneNumber != self.numberFromTextfield())
        {
            return true
        }
        else if (UserProfile.currentUserProfile().userAvatarImage != self.userImageView.image!)
        {
            return true
        }
        return false
    }
    
     func validateFieldsForCorrectInput() -> Bool
    {
        if (nameTextField.text.rangeOfCharacterFromSet(NSCharacterSet.decimalDigitCharacterSet()) != nil)
        {
            self.presentAlert("Error", message: "Name can't contain digits")
            return false
        }
        if (surnameTextField.text.rangeOfCharacterFromSet(NSCharacterSet.decimalDigitCharacterSet()) != nil)
        {
            self.presentAlert("Error", message: "Surname can't contain digits")
            return false
        }
        let phone = Array(phoneNumberTextField.text)
        if !phoneNumberTextField.text.isEmpty && phone.count < 18
        {
            self.presentAlert("Error", message: "Enter correct phone number")
            return false
        }
        return true
    }
 }
