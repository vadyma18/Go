
import Foundation

class RoutesController : UITableViewController, UIActionSheetDelegate
{
    @IBOutlet var sidebarButton : UIBarButtonItem!
	private var _didLoadRoutes = false
    lazy var searchResults = NSMutableArray()
	lazy var items = NSMutableArray()
	lazy var driversInfo = NSDictionary()
    lazy var avatars = NSMutableDictionary()
    let pendingOperations = PendingOperations()
    
    var pageMode : PageMode = PageMode.show
    private var sideBarDelegate: SidebarViewController?
    @IBOutlet var sideBarView : UIView!
    @IBOutlet var segmentedControl : UISegmentedControl!
    @IBOutlet var tableViewInfo    : UITableView!
    @IBOutlet var avatarImageView  : UIImageView!
    @IBOutlet var nickNameLabel    : UILabel!
    @IBOutlet var userNameLabel    : UILabel!
    
    @IBAction func updateMenu()
    {
        tableViewInfo.reloadData()
    }

	override func viewDidLoad()
	{
		super.viewDidLoad()
        rootNavigationController = self.navigationController
       
        let textAttributes = NSMutableDictionary(capacity: 1)
        textAttributes.setObject(UIColor.whiteColor(), forKey: NSForegroundColorAttributeName)
        navigationController?.navigationBar.titleTextAttributes = textAttributes

        if pageMode == .show
        {
            title = "Active Routes";
            sidebarButton.title = ""
            sidebarButton.target = self.navigationController
            sidebarButton.action = "animateViewAppear:"
            sidebarButton.image = UIImage(named: "menu") as UIImage?

            
            (navigationController as NavigationSideBarController).setSideBarView(sideBarView)
            sideBarDelegate = SidebarViewController(segmentedControl: segmentedControl, tableView: tableViewInfo, avatarImageView: avatarImageView, nickNameLabel: nickNameLabel, userNameLabel: userNameLabel, view: sideBarView)
            refreshControl?.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        }
        var nib = UINib(nibName: kCustomCellNibName, bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: kCustomCellReusableId)
	}

    func refresh(sender:AnyObject)
    {
        refreshRoutes()
        self.refreshControl?.endRefreshing()
    }
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
   
    func getSection(scheduleTime: (type: ScheduleTimeType, typeIndex: Int)) -> NSMutableDictionary
	{
		var section: NSMutableDictionary?
        var index : Int? = 0
		for	item in items
		{
			var sectionTypeIndex = item.objectForKey("sectionType") as Int
			if sectionTypeIndex == scheduleTime.typeIndex
			{
				section = item as? NSMutableDictionary
                index = nil
				break
			}
            else if sectionTypeIndex < scheduleTime.typeIndex
            {
                index!++
            }
		}
		
		if section == nil
		{
			section = NSMutableDictionary(objectsAndKeys: scheduleTime.typeIndex, "sectionType", nameForSectionWithIndex(scheduleTime.type), "sectionName", NSMutableArray(), "routes")
			items.insertObject(section!, atIndex: index!)
		}
		
		return section!
	}
    
    func addItem (route : Route)
    {
        let _shedule : Schedule = route.schedule! as Schedule
        var scheduleTime : (type: ScheduleTimeType, typeIndex: Int) = _shedule.getScheduleTimeType()
        
        if avatars.valueForKey(route.driverId!) == nil
        {
            let avatar = Avatar(userId: route.driverId!, imageId: (driversInfo.objectForKey(route.driverId!) as UserInfo).userImageId)
            avatars.setValue(avatar, forKey: route.driverId!)
        }
        if scheduleTime.type != ScheduleTimeType.UnKnown
        {
            var section = self.getSection(scheduleTime)
            insertRoute(route, withTimeSortInArray: section.objectForKey("routes") as NSMutableArray)
        }
    }

	func refreshRoutes()
	{
        GoServer.instance.getRides
            {
            (code, routes, driversInfo) in
            if code == .OK
            {
                self.items.removeAllObjects()
                self.driversInfo = driversInfo as NSDictionary
                for object in routes
                {
                    if let route: Route = object as? Route
                    {
                        self.addItem(route)
                    }
                }
                self._didLoadRoutes = true
                self.tableView.reloadData()
            }
        }
	}

    // MARK: - Table view data source
    
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int
	{
        return items.count + 1
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        if section == 0 && _didLoadRoutes
        {
            return 0
        }
        else
        {
            return 30
        }
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        if section == 0
        {
            if _didLoadRoutes
            {
                return nil
            }
            else
            {
                let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 0))
                view.backgroundColor = UIColor(red: 0.917647, green: 0.913725, blue: 0.94902, alpha: 1)
                return view
            }
        }
        else
        {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 0))
            //should be the same color, as CustomCell border
            view.backgroundColor = UIColor(red: 0.917647, green: 0.913725, blue: 0.94902, alpha: 1)
            let label = UILabel(frame: CGRect(x: 10, y: 1, width: tableView.bounds.size.width, height: 30))
            label.font = UIFont(name: "Helvetica", size: 17.0)
            label.textColor = UIColor.grayColor()
            var sectionName = items.objectAtIndex(section - 1).objectForKey("sectionName") as String
            label.text = sectionName.uppercaseString
            view.addSubview(label)
            return view
        }
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView)
    {
        let sectionHeaderHeight = CGFloat(30)
        if scrollView.contentOffset.y <= sectionHeaderHeight && scrollView.contentOffset.y >= 0
        {
            scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0)
        }
        else if scrollView.contentOffset.y >= sectionHeaderHeight
        {
            scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
        }
    }
    
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
        if section == 0
        {
            if _didLoadRoutes
            {
                return 0
            }
            else
            {
                return 1
            }
        }
		return (items.objectAtIndex(section - 1).objectForKey("routes") as NSMutableArray).count
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
	{
        if indexPath.section == 0
        {
            return tableView.dequeueReusableCellWithIdentifier("processView", forIndexPath: indexPath) as UITableViewCell
        }
        
        let cellIdentifier = kCustomCellReusableId

		var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? CustomCell

		if cell == nil
		{
			cell = CustomCell()
		}
		
        let route: Route = getRouteByIndexPath(indexPath)
        let date: NSDate = route.schedule!.date
		let fromValue = route.from
		let toValue = route.to
		let seatsCount = route.numberOfSeats
		
        let avatar = avatars.objectForKey(route.driverId!) as Avatar
        
		cell?.fromAdressString = fromValue ?? ""
		cell?.toAdressString = toValue ?? ""
		cell?.seatCountString = seatsCount ?? 1
		cell?.departureTime = date
        cell?.driverName = (driversInfo.objectForKey(route.driverId!) as UserInfo).userNickName
        
        switch avatar.state
        {
            case .Placeholder: cell?.activityIndicator.startAnimating()
            self.startOperationsForAvatars(avatar, indexPath: indexPath)
            case .LoadedFromCache, .LoadedFromServer, .ScaledAndSaved : cell?.activityIndicator.stopAnimating()
            case .Failed : cell?._avatarImageView.image = UIImage(named: "person")
            default : break
        }
        cell?._avatarImageView.image = avatar.image
        
        return cell!
	}
    
    func startOperationsForAvatars(avatar: Avatar, indexPath: NSIndexPath)
    {
        switch avatar.state
        {
            case .Placeholder:
                startLoadingFromCache(avatar, indexPath: indexPath)
            case .LoadedFromServer:
                startScalingImage(avatar, indexPath: indexPath)
            default: break
        }
    }
    
    func startLoadingFromCache(avatar: Avatar, indexPath: NSIndexPath)
    {
        if let downloadOperation = pendingOperations.downloadsInProgress[indexPath]
        {
            return
        }

        let downloader = ImageLoader(avatar: avatar)
        downloader.completionBlock =
        {
            if downloader.cancelled
            {
                return
            }
            dispatch_async(dispatch_get_main_queue(),
            {
                self.pendingOperations.downloadsInProgress.removeValueForKey(indexPath)
                self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            })
        }
        pendingOperations.downloadsInProgress[indexPath] = downloader
        pendingOperations.downloadQueue.addOperation(downloader)
    }
    
    func startScalingImage(avatar: Avatar, indexPath: NSIndexPath)
    {
        if let scalingOperation = pendingOperations.scalingInProgress[indexPath]
        {
            return
        }
        
        let scaler = ImageScaler(avatar: avatar)
        scaler.completionBlock =
        {
            if scaler.cancelled
            {
                return
            }
            dispatch_async(dispatch_get_main_queue(),
            {
                self.pendingOperations.scalingInProgress.removeValueForKey(indexPath)
                self.tableView.reloadRowsAtIndexPaths([], withRowAnimation: .Fade)
            })
        }
        pendingOperations.scalingInProgress[indexPath] = scaler
        pendingOperations.scalingQueue.addOperation(scaler)
    }
    
    override func scrollViewWillBeginDragging(scrollView: UIScrollView)
    {
        suspendAllOperations()
    }
    
    override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool)
    {
        if !decelerate
        {
            loadImagesForOnscreenCells()
            resumeAllOperations()
        }
    }
    
    override func scrollViewDidEndDecelerating(scrollView: UIScrollView)
    {
        loadImagesForOnscreenCells()
        resumeAllOperations()
    }
    
    func suspendAllOperations ()
    {
        pendingOperations.downloadQueue.suspended = true
        pendingOperations.scalingQueue.suspended = true
    }
    
    func resumeAllOperations ()
    {
        pendingOperations.downloadQueue.suspended = false
        pendingOperations.scalingQueue.suspended = false
    }
    
    func loadImagesForOnscreenCells ()
    {
        if let pathsArray = tableView.indexPathsForVisibleRows()
        {

            let allPendingOperations = NSMutableSet(array:pendingOperations.downloadsInProgress.keys.array)
            allPendingOperations.addObjectsFromArray(pendingOperations.scalingInProgress.keys.array)
            
            let toBeCancelled = allPendingOperations.mutableCopy() as NSMutableSet
            let visiblePaths = NSSet(array: pathsArray)
            toBeCancelled.minusSet(visiblePaths)
            
            let toBeStarted = visiblePaths.mutableCopy() as NSMutableSet
            toBeStarted.minusSet(allPendingOperations)
            
            for indexPath in toBeCancelled
            {
                let indexPath = indexPath as NSIndexPath
                if let pendingDownload = pendingOperations.downloadsInProgress[indexPath]
                {
                    pendingDownload.cancel()
                }
                pendingOperations.downloadsInProgress.removeValueForKey(indexPath)
                if let pendingScaling = pendingOperations.scalingInProgress[indexPath]
                {
                    pendingScaling.cancel()
                }
            }
            
            for indexPath in toBeStarted
            {
                let indexPath = indexPath as NSIndexPath
                let recordToProcess = self.avatars.objectForKey(getRouteByIndexPath(indexPath).driverId!) as Avatar
                startOperationsForAvatars(recordToProcess, indexPath: indexPath)
            }
        }
    }
	
	override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        if indexPath.section == 0
        {
            return 50
        }
		return 117
	}
	
	func getRouteByIndexPath(indexPath: NSIndexPath) -> Route
    {
        var section = items.objectAtIndex(indexPath.section - 1) as NSDictionary
		var route = (section.objectForKey("routes") as NSArray).objectAtIndex(indexPath.row) as Route
		return route
	}

	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
	{
        if indexPath.section != 0
        {
		var segueIdentifier : NSString = "ShowPassengerRoutePreview"
		performSegueWithIdentifier(segueIdentifier, sender: tableView)
        }
        else
        {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
		if segue.identifier == "ShowPassengerRoutePreview"
        {
			var selectedIndex : NSIndexPath? = tableView.indexPathForSelectedRow()
			(segue.destinationViewController as RoutePassengerPreviewViewController).route = self.getRouteByIndexPath(selectedIndex!)
		}
        else if segue.identifier == "findRoute"
        {
            (segue.destinationViewController as MapViewController).pageMode = PageMode.find
        }
	}
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(true, animated: false)
        if pageMode == PageMode.find
        {
            title = "Search Results"
            refreshControl?.removeFromSuperview()
            _didLoadRoutes = true
            if searchResults.count > 0
            {
                items = NSMutableArray()
                for item in searchResults
                {
                    if let route = item as? Route
                    {
                        addItem(route)
                    }
                }
            }
            else
            {
                presentAlert("Nothing found", message: nil)
            }
        }
        else if pageMode == PageMode.show
        {
            title = "Active Routes"
            if items.count == 0
            {
                _didLoadRoutes = false
            }
            refreshRoutes()
        }
        tableView.reloadData()
    }
    
    @IBAction func backButtonPress(sender: AnyObject)
    {
        if pageMode == PageMode.find
        {
            navigationController?.popViewControllerAnimated(true)
        }
    }
    
    @IBAction func unwindSegue(segue: UIStoryboardSegue) {}
    
    @IBAction func unwindFromFind(segue: UIStoryboardSegue) {}
}
