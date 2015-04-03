
import Foundation

class LoginViewController : UIViewController, UITextFieldDelegate
{
	@IBOutlet var usernameField : UITextField!
	@IBOutlet var passwordField : UITextField!
	@IBOutlet var goButton: UIButton!
	@IBOutlet var progressIndicator: UIActivityIndicatorView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    private lazy var _backgroundGradientLayer = CAGradientLayer()
    private var _heightToMove: CGFloat = 0
    
	override func viewDidLoad()
	{
		super.viewDidLoad()
		loadPrefs()
        setStyleToTextfield()
        SetBackgroundGradient()
        
        var notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification , object: nil)
    }
    
    //hides keyboard when 'return' key pressed
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        textField.resignFirstResponder()
        
        scrollView.setContentOffset(CGPointMake(0, scrollView.contentOffset.y - _heightToMove ), animated: true)
        
        return true;
    }
    
    func keyboardWillShow(notification: NSNotification)
    {
        var windowHeight = view.bounds.height
        var keyboardInfo: NSDictionary? = notification.userInfo
        var keyboardHeight = keyboardInfo?.valueForKey("UIKeyboardBoundsUserInfoKey")?.CGRectValue().height
        var yTextfieldPosition = passwordField.convertPoint(passwordField.bounds.origin, toView: view).y
        var yPositionBottomCornerTextfield = yTextfieldPosition + passwordField.frame.height
        var yPositionKeyboard = windowHeight - keyboardHeight!
        
        if yPositionBottomCornerTextfield > yPositionKeyboard
        {
            _heightToMove = yPositionBottomCornerTextfield - yPositionKeyboard + 5                      // 5 - bottom margin passwordfield
            var yPositionScreenOnContentView = view.convertPoint(view.bounds.origin, toView: contentView).y
            var yPositionBottomCornerScreenOnContentView = yPositionScreenOnContentView + view.frame.height
            var contentViewHeightRest = contentView.frame.height - yPositionBottomCornerScreenOnContentView
            if (contentViewHeightRest < _heightToMove)
            {
                var contentViewHeightDearth = _heightToMove - contentViewHeightRest
                var contentHeight = contentView.frame.size.height + contentViewHeightDearth
                scrollView.contentSize = CGSizeMake(contentView.frame.width, contentHeight)
            }
            var yPositionForScroll = scrollView.contentOffset.y + _heightToMove
            scrollView.setContentOffset(CGPointMake(0, yPositionForScroll), animated: false)
        }
        else
        {
            _heightToMove = 0
        }
    }
    
    deinit
    {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewWillDisappear(animated : Bool)
	{
		super.viewWillDisappear(animated)
        
		savePrefs()
	}
    
    override func viewWillLayoutSubviews()
    {
        _backgroundGradientLayer.frame = view.bounds
        var yPositionGoButton = goButton.convertPoint(goButton.bounds.origin, toView: view).y
        if yPositionGoButton > view.bounds.height
        {
            var dearthHeight = yPositionGoButton - view.bounds.height + goButton.frame.height + 30         // 30 - bottom margin Go button
            var yPositionForScroll = scrollView.contentOffset.y + dearthHeight
            scrollView.setContentOffset(CGPointMake(0, yPositionForScroll), animated: false)
        }
    }

	func savePrefs()
	{
		let defs = NSUserDefaults.standardUserDefaults()
		defs.setObject(username, forKey: "username")
		defs.setObject(password, forKey: "password")
	}
	
	func loadPrefs()
	{
		let defs = NSUserDefaults.standardUserDefaults()
		if let u = defs.stringForKey("username") { username = u }
		if let p = defs.stringForKey("password") { password = p }
	}

	var username : String
	{
		get
		{
			return usernameField.text
		}
		set
		{
			usernameField.text = newValue
		}
	}

	var password : String
	{
		get
		{
			return passwordField.text
		}
		set
		{
			passwordField.text = newValue
		}
	}
    
	override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool
	{
        if !isValidEmail(usernameField.text)
        {
            self.presentAlert("Error", message: "Enter correct e-mail")
            return false
        }
        if passwordField.text.isEmpty
        {
            self.presentAlert("Error", message: "Enter your password")
            return false
        }
        
        goButton.enabled = false

        //hide keyboard
        self.view.endEditing(true)

        progressIndicator.startAnimating()
		UIApplication.sharedApplication().networkActivityIndicatorVisible = true

		GoServer.instance.registerAndLogin(username, password: password)
		{
			(code) in
			self.goButton.enabled = true
			self.progressIndicator.stopAnimating()
			UIApplication.sharedApplication().networkActivityIndicatorVisible = false
			if code == ServerResultCode.OK
			{
				self.performSegueWithIdentifier(identifier, sender: sender)
			}
			else if code == ServerResultCode.ErrorPassword
            {
                self.shakePasswordTextField()
            }
            else
			{
				self.presentAlert("Error", message:"Could not connect to server!")
			}
		}

		return false
	}
    
    private func isValidEmail(testStr: String) -> Bool
    {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-_]+\\.[A-Za-z]{2,63}"
        var emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        return emailTest!.evaluateWithObject(testStr)
    }
    
    private func setStyleToTextfield()
    {
        usernameField.leftViewMode = UITextFieldViewMode.Always
        var emailImageView = UIImageView(image: UIImage(named: "emailicon.png"))
        emailImageView.frame = CGRectMake(0, 0, 30, 25)
        var paddingEmailView = UIView(frame: CGRectMake(0, 0, emailImageView.frame.size.width + 20, emailImageView.frame.size.height))
        paddingEmailView.addSubview(emailImageView)
        usernameField.leftView = paddingEmailView
 
        passwordField.leftViewMode = UITextFieldViewMode.Always
        var passwordImageView = UIImageView(image: UIImage(named: "passwordicon.png"))
        passwordImageView.frame = CGRectMake(0, 0, 30, 25)
        var paddingPasswordView = UIView(frame: CGRectMake(0, 0, passwordImageView.frame.size.width + 20, passwordImageView.frame.size.height))
        paddingPasswordView.addSubview(passwordImageView)
        passwordField.leftView = paddingPasswordView

        var _bottomBorderUserNameTextField = CALayer()
        var _bottomBorderPasswordTextField = CALayer()
        _bottomBorderPasswordTextField.frame = CGRectMake(0, passwordField.frame.size.height - 1, passwordField.frame.size.width, 1)
        _bottomBorderUserNameTextField.frame = CGRectMake(0, usernameField.frame.size.height - 1, usernameField.frame.size.width, 1)

        _bottomBorderUserNameTextField.backgroundColor = UIColor.whiteColor().CGColor
        _bottomBorderPasswordTextField.backgroundColor = UIColor.whiteColor().CGColor
        usernameField.layer.addSublayer(_bottomBorderUserNameTextField)
        passwordField.layer.addSublayer(_bottomBorderPasswordTextField)
    }
    
    private func SetBackgroundGradient()
    {
        _backgroundGradientLayer.colors = NSArray(arrayLiteral: UIColor(red: 0.9412, green: 0.2196, blue: 0.0902, alpha: 1).CGColor, UIColor(red: 0.9412, green: 0, blue: 0.2588, alpha: 1).CGColor)
        view.layer.insertSublayer(_backgroundGradientLayer, atIndex: 0)
    }
    
    private func shakePasswordTextField()
    {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.05
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = NSValue(CGPoint: CGPointMake(passwordField.center.x - 10, passwordField.center.y))
        animation.toValue = NSValue(CGPoint: CGPointMake(passwordField.center.x + 10, passwordField.center.y))
        passwordField.layer.addAnimation(animation, forKey: "position")
    }
}
