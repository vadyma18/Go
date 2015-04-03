
import Foundation

extension UIActionSheet
{
	typealias UIActionSheetHandler = ((clickedButton: Int) -> Void)

	class Delegate : NSObject, UIActionSheetDelegate
	{
		func actionSheet(actionSheet: UIActionSheet!, clickedButtonAtIndex buttonIndex: Int)
		{
			self.handler!(clickedButton: buttonIndex)
		}
		var handler : UIActionSheetHandler?
	}

	func setHandlerBlock(handler: UIActionSheetHandler)
	{
		struct StaticVars
		{
			static var delegateKey: Void?
		}
		let d = Delegate()
		d.handler = handler
		objc_setAssociatedObject(self, &StaticVars.delegateKey, d, UInt(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
		delegate = d
	}

	func showFromBarButtonItem(item: UIBarButtonItem!, animated: Bool, handler: UIActionSheetHandler)
	{
		setHandlerBlock(handler)
		showFromBarButtonItem(item, animated: animated)
	}

	func showFromRect(rect: CGRect, inView view: UIView!, animated: Bool, handler: UIActionSheetHandler)
	{
		setHandlerBlock(handler)
		showFromRect(rect, inView: view, animated: animated)
	}
}
