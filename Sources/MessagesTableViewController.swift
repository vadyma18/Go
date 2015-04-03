
import UIKit

class MessagesTableViewController:NSObject, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate
{
    private var tableView: UITableView!
    private var view: UIView!
    private var route: Route!
    private var yPositionConstraint: NSLayoutConstraint!
    private var textView: UITextView!
    private lazy var messages = NSMutableArray()
    
    let animationDuration = 0.5
    let contentViewOpacity: Float = 0.5
    let normalViewOpacity: Float = 1    

    private var superviewHeight: CGFloat?
    
    init(tableView: UITableView, route: Route, view: UIView, yPositionConstraint: NSLayoutConstraint, textView: UITextView)
    {
        self.tableView            = tableView
        self.route                = route        
        self.yPositionConstraint  = yPositionConstraint
        self.view                 = view
        self.textView             = textView
        
        super.init()
        
        self.superviewHeight      = getSuperviewHeight()
        self.tableView.dataSource = self
        self.tableView.delegate   = self
        self.textView.delegate    = self
        self.yPositionConstraint.constant = superviewHeight!
        
        var notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification , object: nil)
        notificationCenter.addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification , object: nil)
    }
    
    func refreshMessages()
    {
        GoServer.instance.getCommentsForRideWithIdentifier(route.rideId!, handler:
            {
                (code, comments) -> Void in
                if code == ServerResultCode.OK
                {
                    self.messages.removeAllObjects()
                    self.messages.addObjectsFromArray(comments)
                    self.tableView.reloadData()
                    if self.messages.count > 0
                    {
                        self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.messages.count-1, inSection: 0), atScrollPosition: UITableViewScrollPosition.Bottom, animated: false)
                    }
                }
        })
    }
    
    //MARK: Table view data source
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return messages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var message = messages.objectAtIndex(indexPath.row) as Message
        if UserProfile.currentUserProfile().userId != message.userId
        {
            var cell = tableView.dequeueReusableCellWithIdentifier(kCellForPassengerMessage) as? CellForPassengerMessage
            if cell == nil
            {
                cell = CellForPassengerMessage()
            }
            cell?.nickName = message.userNickName
            cell?.textForMessage = message.text
            cell?.date = message.getDate()
            cell?.avatarImageView.loadImageFrom(message.userId, imageId: message.userImageId)
            
            return cell!
        }
        else
        {
            var cell = tableView.dequeueReusableCellWithIdentifier(kCellForCurrentUserMessage) as? CellForCurrentUserMessage
            if cell == nil
            {
                cell = CellForCurrentUserMessage()
            }
            cell?.textForMessage = message.text
            cell?.date = message.getDate()
            
            return cell!
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        var text = (messages.objectAtIndex(indexPath.row) as Message).text as NSString
        
        var constraint = CGSize(width: view.frame.width - 90, height: 1000)
        
        var size = text.boundingRectWithSize(constraint, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(14.0)], context: nil)
        
        return size.height+30
    }
    
    //MARK: View Appear/Disapper
    func animateViewAppear(sender: AnyObject?)
    {
        if view.frame.origin.y == superviewHeight
        {
            refreshMessages()
            UIView.animateWithDuration(animationDuration, animations:
                { () -> Void in
                    self.view.frame.origin.y = 0
                    self.setupBehindView(self.contentViewOpacity, userInteractionEnable: false)
                })
                {
                    (Bool) -> Void in
                    self.yPositionConstraint.constant = 0
            }
        }
    }
    
    func animateViewDisappear(sender: AnyObject?)
    {
        if view.frame.origin.y == 0
        {
            UIView.animateWithDuration(animationDuration, animations:
                { () -> Void in
                    self.view.frame.origin.y = self.superviewHeight!
                    self.yPositionConstraint.constant = self.superviewHeight!
                    self.setupBehindView(self.normalViewOpacity, userInteractionEnable: true)
                    
                })
                {
                    (Bool) -> Void in
                }
        }
    }
    
    private func setupBehindView(opacity: Float, userInteractionEnable: Bool)
    {
        if let superview = view.superview
        {
            for value in superview.subviews
            {
                var _view = value as UIView
                if view != _view
                {
                    _view.layer.opacity = opacity
                    _view.userInteractionEnabled = userInteractionEnable
                }
            }
        }
    }
    
    private func getSuperviewHeight() -> CGFloat
    {
        if self.view.superview!.frame.height > self.view.superview!.frame.width
        {
            return self.view.superview!.frame.height
        }
        else
        {
            return self.view.superview!.frame.width
        }
    }
    
    func keyboardWillShow(notification: NSNotification)
    {
        if view.frame.origin.y == 0
        {
            var windowHeight = view.superview!.bounds.height
            var keyboardInfo = notification.userInfo as NSDictionary?
            var keyboardHeight = keyboardInfo?.valueForKey("UIKeyboardBoundsUserInfoKey")?.CGRectValue().height
            var yPositionBottomCornerTextView = textView.convertPoint(textView.bounds.origin, toView: view.superview).y + textView.frame.height
            var yPositionKeyboard = windowHeight - keyboardHeight!
            
            if yPositionBottomCornerTextView > yPositionKeyboard
            {
                view.frame.origin.y = yPositionKeyboard - yPositionBottomCornerTextView
                yPositionConstraint.constant = yPositionKeyboard - yPositionBottomCornerTextView
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification)
    {
        view.frame.origin.y = 0
        yPositionConstraint.constant = 0
    }
    
    //hides keyboard when 'return' key pressed
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool
    {
        if text == "\n"
        {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    deinit
    {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
