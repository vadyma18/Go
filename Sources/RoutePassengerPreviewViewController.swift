
import UIKit

class RoutePassengerPreviewViewController: UIViewController,  GMSMapViewDelegate, UITableViewDelegate, UIGestureRecognizerDelegate, UIAlertViewDelegate
{
    var route: Route!
    var driver: UserInfo!
    var currentPath : GMSPolyline = GMSPolyline()
    var messagesTableViewController: MessagesTableViewController?
    
    @IBOutlet weak var driverUserPict: UIImageView!
    @IBOutlet weak var driverUserNickLabel: UILabel!
    @IBOutlet weak var numberOfSeatsLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var subscribeButton: UIButton!
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var passengersTableView: UITableView!
    @IBOutlet weak var subscribeView: UIView!
    @IBOutlet weak var callButton: UIButton!
    
    @IBOutlet weak var messageTableView: UITableView!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var processIndicator: UIActivityIndicatorView!
    @IBOutlet weak var yPositionConstraintForMessageView: NSLayoutConstraint!
    
    var _messageViewHidden = true
    var messageViewHidden: Bool
    {
        get
        {
            return _messageViewHidden
        }
        set
        {
            _messageViewHidden = newValue
            if !_messageViewHidden
            {
                messagesTableViewController?.animateViewAppear(nil)
            }
            else
            {
                messagesTableViewController?.animateViewDisappear(nil)
            }
        }
    }

    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        driverUserPict.layer.borderWidth = 1
        driverUserPict.layer.borderColor = UIColor.grayColor().CGColor
        var nib = UINib(nibName: kCellForApprovedUsersNibName, bundle: nil)
        self.passengersTableView.registerNib(nib, forCellReuseIdentifier: kCellForApprovedUsersReusableId)
        mapView.delegate = self
        
        GoServer.instance.getUserInfo(route!.driverId!)
        {
            (code, result) in
            self.driver = result
            self.driverUserNickLabel.text = self.driver.userNickName
            self.driverUserPict.loadImageFrom(self.route.driverId!, imageId: self.driver.userImageId)
        }
        
        if route.driverId == UserProfile.currentUserProfile().userId
        {
            callButton.hidden = true
        }
        
        refreshViewController(route)
    }
    
    func refreshViewController(route: Route)
    {
        self.route = route
        if route.numberOfSeats! == 0
        {
            numberOfSeatsLabel.backgroundColor = UIColor.redColor()
        }
        
        
        numberOfSeatsLabel.text = "\(route.numberOfSeats!)"
        fromLabel.text  = "From: \(route.from!)"
        toLabel.text = "To: \(route.to!)"
        dateLabel.text = route.schedule?.date.routeTimeString()
        timeLabel.text = route.schedule?.date.routeTimeString()
        
        if let schedule = route.schedule
        {
            let scheduleDateType = schedule.getScheduleTimeType()
            let date = nameForSectionWithIndex(scheduleDateType.type)
            dateLabel.text = date.uppercaseString;
        }
        
        createRouteOnMapView(checkPoints: route.checkPoints!, mapView: mapView!, currentPath: currentPath, optimizeWaypoints: true, withEdgeInsets: false)
        
        if (route.isRouteContainsCurrentUser() || route.driverId == UserProfile.currentUserProfile().userId)
        {
            initMessagesTableViewController()
        }
        else if route.numberOfSeats == 0
        {
            subscribeButton.enabled = false
            subscribeView.hidden = true
        }
        else
        {
            subscribeButton.setTitle("Subscribe", forState: UIControlState.Normal)
        }
    }
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool
    {
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "toMap"
        {
            let mapInfoViewController = segue.destinationViewController as? MapInfoViewController
            mapInfoViewController?.route = self.route
        }
        else if segue.identifier == "toDriverProfile"
        {
            let userProfileViewController = segue.destinationViewController as? UserProfileViewController
            userProfileViewController?.isMyProfile = false
            userProfileViewController?.currentUserId = driver!.userId
        }
    }
    
    @IBAction func driverCallButtonTap(sender: AnyObject)
    {
        if self.driver.userPhoneNumber != ""
        {
            var phone = "tel://" + self.driver.userPhoneNumber
            UIApplication.sharedApplication().openURL(NSURL(string: phone)!)
            println(phone)
        }
    }
    
    @IBAction func subscribeButtonTap(sender: AnyObject)
    {
        if (subscribeButton.titleLabel?.text == "Subscribe")
        {
            var alertView = UIAlertView(title: "Do you want subscribe to this route?", message: "", delegate: self, cancelButtonTitle: "CANCEL", otherButtonTitles: "OK")
            alertView.show()
        }
        else if messagesTableViewController != nil
        {
            self.messageViewHidden = false
        }
    }
    
    func mapView(mapView: GMSMapView!, didChangeCameraPosition position: GMSCameraPosition!)
    {
        return
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return route.approvedUsers.count == 0 ? 0 : 30
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        if route.approvedUsers.count > 0
        {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 0))
            //should be the same color, as CustomCell border
            view.backgroundColor = UIColor.whiteColor()
            let label = UILabel(frame: CGRect(x: 10, y: 1, width: tableView.bounds.size.width, height: 30))
            label.font = UIFont(name: "Helvetica", size: 17.0)
            label.text = kTakenPasangers
            view.addSubview(label)
            return view
        }
        else
        {
            return nil
        }
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
		return self.route.approvedUsers.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 60
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        var storyboard = UIStoryboard(name: "Main", bundle: nil)
        var viewController = storyboard.instantiateViewControllerWithIdentifier("userProfile") as UserProfileViewController
        
        viewController.currentUserId = (route.approvedUsers.objectAtIndex(indexPath.row) as UserInfo).userId
        viewController.isMyProfile = false
        
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var userName : String = "Anonimous"
        var cell = tableView.dequeueReusableCellWithIdentifier(kCellForApprovedUsersReusableId) as? CellForApprovedUsers
        if cell == nil
        {
            cell = CellForApprovedUsers()
        }
        var userInfo : UserInfo = route.approvedUsers.objectAtIndex(indexPath.row) as UserInfo
        userName = userInfo.userNickName ?? userName
        cell?.userNameString = userName
        cell?.userAvatar.loadImageFrom(userInfo.userId, imageId: userInfo.userImageId)
        return cell!
    }
    
    @IBAction func unwindSegue(segue: UIStoryboardSegue) {}
    
    @IBAction func sendComment(sender: AnyObject)
    {
        startProcessIndicator()
        self.messageTextView.resignFirstResponder()
        var message = Message(text: messageTextView.text)
        GoServer.instance.addCommentToRoute(route.rideId!, message: message)
        {
            (code) -> Void in
            self.stopProcessIndicator()
            if code == ServerResultCode.OK
            {
                self.messageTextView.text = ""
                self.messagesTableViewController?.refreshMessages()
            }
        }
    }
    
    @IBAction func hideMessageView(sender: AnyObject)
    {
        self.messageViewHidden = true
    }
    
    private func startProcessIndicator()
    {
        view.bringSubviewToFront(processIndicator)
        processIndicator.startAnimating()
        messageView.userInteractionEnabled = false
    }
    
    private func stopProcessIndicator()
    {
        view.sendSubviewToBack(processIndicator)
        processIndicator.stopAnimating()
        messageView.userInteractionEnabled = true
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int)
    {
        if buttonIndex == 1
        {
            //use a stub message to confirm to protocol
            var message : String = "Want to subscribe"
            GoServer.instance.joinRide(route.rideId!, message: message)
                {
                    (code) in
                    if code == ServerResultCode.OK
                    {
                        self.presentAlert("Success", message:"Your request was sent!")
                        self.initMessagesTableViewController()
                    }
                    else
                    {
                        self.presentAlert("Error", message:"Failed to subscribe!")
                    }
            }
        }
    }
    
    private func initMessagesTableViewController()
    {
        subscribeButton.setTitle("group chat", forState: UIControlState.Normal)
        if messagesTableViewController == nil
        {
            messagesTableViewController = MessagesTableViewController(tableView: messageTableView, route: route, view: messageView, yPositionConstraint: yPositionConstraintForMessageView, textView: messageTextView)
        }
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        if !messageViewHidden
        {
            self.messageViewHidden = false
        }
    }
}
