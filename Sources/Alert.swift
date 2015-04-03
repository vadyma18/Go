
import Foundation

extension UIViewController
{
	func presentAlert(title: String?, message: String?)
	{
		// Currently this code does not work as intended. It should try loading UIAlertController
		// class in runtime, but somehow still requires it, when dynamic linking occurs.
		// Thats why the code doesn't work on iOS 7.

//		if let alertClass = NSClassFromString("UIAlertController")? as? UIAlertController.Type
//		{
//			if let alertActionClass = NSClassFromString("UIAlertAction")? as? UIAlertAction.Type
//			{
//				var alert = alertClass(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
//				alert.addAction(alertActionClass.(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
//				self.presentViewController(alert, animated: true, completion: nil)
//				return
//			}
//		}

		var alert = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: "OK")
		alert.show()
	}
}
