
import UIKit

class DirverRoutsViewController: UITableViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet var sidebarButton : UIBarButtonItem!
      
    private var _didLoadRoutes = false
    lazy var items = NSMutableArray()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        navigationController?.setToolbarHidden(true, animated: false)
        
        title = "My Routes:"
        sidebarButton.tintColor = UIColor.whiteColor()
        sidebarButton.target = self.navigationController
        sidebarButton.action = "animateViewAppear:"
        
        var nib = UINib(nibName: "CustomCellMyRout", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "myRouteCell")
        self.refreshControl?.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        refreshRoutes()        
    }
	
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refresh(sender:AnyObject)
    {
        refreshRoutes()
        self.refreshControl?.endRefreshing()
    }

    
    //MARK: - adding routes to items manipulations
    func getSection(scheduleTime: (type: ScheduleTimeType, typeIndex: Int)) -> NSMutableDictionary
    {
        var section: NSMutableDictionary?
        var index: Int? = 0
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
    
    func addItem(route: Route)
    {
        let _shedule : Schedule = route.schedule! as Schedule
        let scheduleTime : (type: ScheduleTimeType, typeIndex: Int) = _shedule.getScheduleTimeType()
        if scheduleTime.type != ScheduleTimeType.UnKnown
        {
            var section = self.getSection(scheduleTime)
            insertRoute(route, withTimeSortInArray: section.objectForKey("routes") as NSMutableArray)
        }
    }
    
    func refreshRoutes()
    {
        GoServer.instance.getUserRides
        {
            (code, routes) in
            if code == .OK
            {
                self.items.removeAllObjects()
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
    
    func deleleRouteByIndexPath(indexPath: NSIndexPath)
    {
        let section = items.objectAtIndex(indexPath.section) as NSDictionary
        let routes = (section.objectForKey("routes") as NSMutableArray)
        routes.removeObjectAtIndex(indexPath.row)
    }
    
    //MARK: - section header
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 30
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 0))
        //should be the same color, as CustomCell border
        view.backgroundColor = UIColor(red: 0.917647, green: 0.913725, blue: 0.94902, alpha: 1)
        let label = UILabel(frame: CGRect(x: 10, y: 1, width: tableView.bounds.size.width, height: 30))
        label.font = UIFont(name: "Helvetica", size: 17.0)
        label.textColor = UIColor.grayColor()
        var sectionName = items.objectAtIndex(section).objectForKey("sectionName") as String
        label.text = sectionName.uppercaseString
        view.addSubview(label)
        return view
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

    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool
    {
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "ShowDriverRoutePreview"
        {
            let selectedIndex = tableView.indexPathForSelectedRow()
            let route = getRouteByIndexPath(items, selectedIndex!)
            (segue.destinationViewController as RouteDriverPreviewTableView).route = route
        }
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return items.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if !_didLoadRoutes
        {
            return 1
        }
        return (items.objectAtIndex(section).objectForKey("routes") as NSArray).count
    }
    
   override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        if !_didLoadRoutes
        {
            return tableView.dequeueReusableCellWithIdentifier("processView", forIndexPath: indexPath) as UITableViewCell
        }
        
        let cellIdentifier = kMyRouteCell
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? CustomCellMyRout
        
        if cell == nil
        {
            cell = CustomCellMyRout()
        }

        let route = getRouteByIndexPath(items, indexPath)
        let date = route.schedule?.date
        
        cell?.fromAdressString = route.from ?? ""
        cell?.toAdressString = route.to ?? ""
        cell?.seatsCount = route.numberOfSeats ?? 0
        cell?.time = date
        cell?.pendingsCount = route.pendingUsers.count

        return cell!
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 100
    }    
	
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        var segueIdentifier : NSString = "ShowDriverRoutePreview"
        performSegueWithIdentifier(segueIdentifier, sender: tableView)
    }
  
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {
        if editingStyle == UITableViewCellEditingStyle.Delete
        {
            GoServer.instance.deleteRide(getRouteByIndexPath(items, indexPath).rideId!, handler:
                {
                (code, result) in
                if code == .OK
                {
                    var section = self.items.objectAtIndex(indexPath.section) as NSMutableDictionary
                    var routes = (section).objectForKey("routes") as NSMutableArray
                    (routes).removeObjectAtIndex(indexPath.row)
                    if routes.count == 0
                    {
                        self.items.removeObjectAtIndex(indexPath.section)
                    }
                    tableView.reloadData()
                }
            })
        }
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewDidDisappear(animated)
        
        items.removeAllObjects()
        tableView.reloadData()
        _didLoadRoutes = false
    }

    @IBAction func unwindSegue(segue: UIStoryboardSegue){}

}
