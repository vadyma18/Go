
import UIKit

var routeInfoCell : CellForRoutePreview?

class RouteDriverPreviewTableView: UITableViewController, GMSMapViewDelegate, CellForPendingUsersDelegate, CellForApprovedUsersRoutePreviewDelegate,  UIGestureRecognizerDelegate {

	private var _route : Route?
    private var map: GMSMapView?
    private var currentPath : GMSPolyline = GMSPolyline()

    var route : Route {
        get {
			if self._route == nil {
				self._route = Route()
			}
            return self._route!
        }
        set
        {
            self._route = newValue
        }
    }
    
    var approvedUsers : NSArray?
    var pendingUsers : NSArray?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.approvedUsers = route.approvedUsers
        self.pendingUsers = route.pendingUsers
        
        var nib1 = UINib(nibName: kCellForRoutePreviewNibName, bundle: nil)
        self.tableView.registerNib(nib1, forCellReuseIdentifier: kCellForRoutePreviewReusableId)
        var nib2 = UINib(nibName: kCellForApprovedUsersRoutePreviewNibName, bundle: nil)
        self.tableView.registerNib(nib2, forCellReuseIdentifier: kCellForApprovedUsersRoutePreviewReusableId)
        var nib3 = UINib(nibName: kCellForPendingUsersNibName, bundle: nil)
        self.tableView.registerNib(nib3, forCellReuseIdentifier: kCellForPendingUsersReusableId)
    }
    
    //MARK: cell buttons handling
    //MARK: CellForPendingUsersDelegate
    func callApprovedUserAction(sender: AnyObject) {
        let cell = sender as CellForApprovedUsersRoutePreview
        let userInfo = self.route.approvedUsers.objectAtIndex(cell.index!) as UserInfo
        let number = userInfo.userPhoneNumber
        let phone = "tel://" + "+" + number
        UIApplication.sharedApplication().openURL(NSURL(string: phone)!)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "editRoute"
        {
            var mapViewController = segue.destinationViewController as? MapViewController
            mapViewController?.route = route
            mapViewController?.pageMode = PageMode.edit
        }
    }
    
    func deleteApprovedUserAction(sender: AnyObject) {
        let cell = sender as CellForApprovedUsersRoutePreview
        let rideId = self.route.rideId!
        let userInfo = self.route.approvedUsers.objectAtIndex(cell.index!) as UserInfo
        let userId = userInfo.userId
        let message = ""
        GoServer.instance.acceptPassenger(rideId, userId: userId, accept: "0", message: message) {
            code in
            if code == ServerResultCode.OK {
                println("deleteApprovedUserAction - OK")
                self.updateRoutePreview()
            } else {
                println("deleteApprovedUserAction push notification error with code: \(code)")
            }
        }


        self.updateRoutePreview()
    }
    
    //MARK: CellForPendingUsersDelegate
    func callPendingUserAction(sender: AnyObject) {
        let cell = sender as CellForPendingUsers
        let userInfo = self.route.pendingUsers.objectAtIndex(cell.index!) as UserInfo
        let number = userInfo.userPhoneNumber
        let phone = "tel://" + "+" + number
        UIApplication.sharedApplication().openURL(NSURL(string: phone)!)
    }
    
    func acceptPendingUserAction(sender: AnyObject)
    {
        if route.numberOfSeats < 1
        {
            self.presentAlert("There's no free seats", message: nil)
            return
        }
        let cell = sender as CellForPendingUsers
        let rideId = route.rideId!
        let userInfo = route.pendingUsers.objectAtIndex(cell.index!) as UserInfo
        let userId = userInfo.userId
        let message = " "
        GoServer.instance.acceptPassenger(rideId, userId: userId, accept: "1", message: message) {
            (code) in
            if code == ServerResultCode.OK {
                println("acceptPendingUserAction push notification code: \(code)")
				self.updateRoutePreview()
            } else {
                println("acceptPendingUserAction push notification error with code: \(code)")
            }
        }
    }

    func deletePendingUserAction(sender: AnyObject) {
        let cell = sender as CellForPendingUsers
        let rideId = self.route.rideId!
        let userInfo = self.route.pendingUsers.objectAtIndex(cell.index!) as UserInfo
        let userId = userInfo.userId
        let message = " "
        GoServer.instance.acceptPassenger(rideId, userId: userId, accept: "0", message: message) {
            code in
            if code == ServerResultCode.OK {
                println("deletePendingUserAction push notification code: \(code)")
				self.updateRoutePreview()
            } else {
                println("deletePendingUserAction push notification error with code: \(code)")
            }
        }
    }
    
    //MARK: tableVeiw
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        var sections = 1
        if let approved = self.approvedUsers {
            if approved.count != 0 {
                ++sections
            }
        }
        if let pending = self.pendingUsers {
            if pending.count != 0 {
                ++sections
            }
        }
        return sections
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let numberOfSections = self.numberOfSectionsInTableView(self.tableView)
        
        if section == 0 {}
        if section == 1 && numberOfSections == 3 {
            return kTakenPasangers
        }
        if numberOfSections == 2 && section == 1 {
            if let approved = self.approvedUsers {
                if approved.count != 0 {
                    return kTakenPasangers
                }
            }
            if let pending = self.pendingUsers {
                if pending.count != 0 {
                    return kPasangersToTake
                }
            }
        }
        if section == 2 {
            return kPasangersToTake
        }
        return ""
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        if section > 0
        {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 0))
            //should be the same color, as CustomCell border
            view.backgroundColor = UIColor.whiteColor()
            let label = UILabel(frame: CGRect(x: 10, y: 1, width: tableView.bounds.size.width, height: 30))
            label.font = UIFont(name: "Helvetica", size: 17.0)
            if section == 1 && route.approvedUsers.count > 0
            {
                label.text = kTakenPasangers
            }
            else
            {
                label.text = kPasangersToTake
            }
            view.addSubview(label)
            return view
        }
        else
        {
            return nil
        }
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : 30
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 150
        } else {
            return 70
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfSections = self.numberOfSectionsInTableView(self.tableView)
        if section == 0 {
            return 1
        }
        
        if section == 1 && numberOfSections == 3 {
            if let approved = self.approvedUsers?.count {
                return approved
            }
        }
        if section == 1 && numberOfSections == 2 {
            if let approved = self.approvedUsers {
                if approved.count != 0 {
                    return approved.count
                }
            }
            if let pending = self.pendingUsers {
                if pending.count != 0 {
                    return pending.count
                }
            }
        }
        
        if section == 2 {
            if let pending = self.pendingUsers?.count {
                return pending
            }
        }
        return 0
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        if indexPath.section > 0
        {
            var userId : String?
            
            if indexPath.section == 1 && route.approvedUsers.count > 0
            {
                userId = (route.approvedUsers.objectAtIndex(indexPath.row) as UserInfo).userId
            }
            else
            {
                userId = (route.pendingUsers.objectAtIndex(indexPath.row) as UserInfo).userId
            }
            
            var storyboard = UIStoryboard(name: "Main", bundle: nil)
            var viewController = storyboard.instantiateViewControllerWithIdentifier("userProfile") as UserProfileViewController
            viewController.currentUserId = userId
            viewController.isMyProfile = false
            
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        else
        {
            var storyboard = UIStoryboard(name: "Main", bundle: nil)
            var viewController = storyboard.instantiateViewControllerWithIdentifier("MapInfo") as MapInfoViewController
            viewController.route = self.route
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		var cell : UITableViewCell?
        let numberOfSections = self.numberOfSectionsInTableView(self.tableView)
		if indexPath.section == 0 {
            
            var routeInfoCell : CellForRoutePreview? = tableView.dequeueReusableCellWithIdentifier(kCellForRoutePreviewReusableId) as? CellForRoutePreview
            
            if routeInfoCell == nil {
                routeInfoCell = CellForRoutePreview()
            }

            if self.map == nil {
                self.createMap(routeInfoCell!)
            }
            
            let schedule : Schedule? = route.schedule! as Schedule

            routeInfoCell!.timeLabelString = route.schedule?.date
            routeInfoCell!.dateLabelStringFromSchedule = schedule
            routeInfoCell!.seatsCount = route.numberOfSeats!
            routeInfoCell!.fromLabelString = route.from!
            routeInfoCell!.toLabelString = route.to!
            routeInfoCell!.mapView = self.map
            
            cell = routeInfoCell
        }


        if self.checkSection(indexPath) == 1 {
            var userName : String = "Anonimous"
            var cell = tableView.dequeueReusableCellWithIdentifier(kCellForApprovedUsersRoutePreviewReusableId) as? CellForApprovedUsersRoutePreview
            if cell == nil {
                cell = CellForApprovedUsersRoutePreview()
            }
            let userInfo : UserInfo = route.approvedUsers.objectAtIndex(indexPath.row) as UserInfo
            let number = userInfo.userPhoneNumber
            if !isValidPhoneNumber(number)
            {
                cell!.callUserApprovedUserButton.enabled = false
            }
            userName = userInfo.userNickName ?? userName
            cell!.userNameString = userName
            cell?.userAvatar.loadImageFrom(userInfo.userId, imageId: userInfo.userImageId)
            cell?.delegate = self
            cell?.delegatePending = self
            cell?.index = indexPath.row

            return cell!
        }
        
        if self.checkSection(indexPath) == 2 {
            var cell = tableView.dequeueReusableCellWithIdentifier(kCellForPendingUsersReusableId) as? CellForPendingUsers
            if cell == nil {
                cell = CellForPendingUsers()
            }
            var userName : String = "Anonimous"
            let userInfo : UserInfo = self.pendingUsers?.objectAtIndex(indexPath.row) as UserInfo
            let number = userInfo.userPhoneNumber
            if !isValidPhoneNumber(number)
            {
                cell!.callUserPendingUserButton.enabled = false
            }
            userName = userInfo.userNickName ?? userName
            cell?.userNameString = userName
            cell?.userAvatar.loadImageFrom(userInfo.userId, imageId: userInfo.userImageId)
            cell?.delegate = self
            cell?.delegatePending = self
            cell?.index = indexPath.row

            return cell!
        }
        return cell!
    }
    
    func checkSection(indexPath: NSIndexPath) -> Int {
        let numberOfSections = self.numberOfSectionsInTableView(self.tableView)
        
        if indexPath.section == 1 && numberOfSections == 3 {
            return 1
        }
        if indexPath.section == 1 && numberOfSections == 2 {
            if let approved = self.approvedUsers {
                if approved.count != 0 {
                    return 1
                }
            }
            if let pending = self.pendingUsers {
                if pending.count != 0 {
                    return 2
                }
            }
        }
        if  indexPath.section == 2 {
            return 2
        }
        return -1
    }
    
    func updateRoutePreview() {
        var currentRouteId : String = self.route.rideId!
        GoServer.instance.getRide(currentRouteId) {
            (code, route) in
            if code == .OK {
                self.refreshTableView(route!)
            }
        }
    }
    
    func refreshTableView(route: Route)
    {
        self.route = route
        approvedUsers = route.approvedUsers
        pendingUsers = route.pendingUsers
        tableView.reloadData()
    }
    
    func createMap(cell: CellForRoutePreview) {
        self.map = cell.mapView
        if self.map == nil {
            self.map = GMSMapView()
        }
        createRouteOnMapView(checkPoints: route.checkPoints!, mapView: map!, currentPath: currentPath, optimizeWaypoints: true, withEdgeInsets: false)
    }
    
    func isValidPhoneNumber(number: String) -> Bool
    {
        if (number.rangeOfCharacterFromSet(NSCharacterSet.decimalDigitCharacterSet()) != nil)
        {
            let phoneLenght = Array(number).count
            if (phoneLenght == 12 && number.hasPrefix("380")) || (phoneLenght == 10 && number.hasPrefix("0"))
            {
                return true
            }
        }
        return false
    }
    
    @IBAction func unwindSegue(segue: UIStoryboardSegue) {}
    @IBAction func unwindFromEdit(segue: UIStoryboardSegue)
    {
        updateRoutePreview()
        map?.clear()
        createRouteOnMapView(checkPoints: route.checkPoints!, mapView: map!, currentPath: currentPath, optimizeWaypoints: true, withEdgeInsets: false)
    }
}

//MARK: SwipableCellTableViewCellDelegate
extension RouteDriverPreviewTableView: SwipableCellTableViewCellDelegate {
    func swipeCellDidStartSwiping(cell: SwipableCell) {
        for currentCell in self.tableView.visibleCells(){
            if let theCell = currentCell as? SwipableCell {
                if theCell != cell && theCell.isSwiped {
                    theCell.resetConstraints(false)
                }
            }
        }
    }
}
