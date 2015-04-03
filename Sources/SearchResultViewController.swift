
import UIKit

class SearchResultViewController: UITableViewController {
    
    let path: NSString = NSBundle.mainBundle().pathForResource("SearchRoutesResult", ofType: "plist")!
    
    
    //    var routes = StubGoServer.instance.getSearchRoutesResults()
    //for testing
    let routes = StubGoServer.instance.getStubRoutes()
    var from : String?
    var to : String?
    var numberOfSeats : Int = 1
    var time : NSDate?
    var date : NSDate?
    var checkPoints: NSMutableArray?
    var routesResult: NSMutableArray?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: kCustomCellNibName, bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: kCustomCellReusableId)
        
        routesResult = self.findRoute()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return "Search results"
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        if let items = self.routesResult {
            return items.count
        } else {
            return 0
        }
        
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100;
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellName = kCustomCellReusableId
        let cell = tableView.dequeueReusableCellWithIdentifier(cellName, forIndexPath: indexPath) as CustomCell
        
        //TODO add custom cell...
        
        if let items = routesResult {
            var route = Route(routeRepresentation: items[indexPath.row] as NSDictionary)
            cell.fromAdressString = route.from!
            cell.toAdressString = route.to!
            cell.seatCountString = route.numberOfSeats!
            //            cell.departureTime = route.schedule?.time?
        }
        
        return cell
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        var route: NSDictionary?
        if let items = self.routesResult {
            route = items[indexPath.row] as? NSDictionary
            if let item = route {
                var actionSheet = UIActionSheet()
                var subscription = item["driverSubscription"] as? NSDictionary
                var hasSubscription = (subscription != nil) && (subscription!["userId"]! as NSString != "000000000000000000000000")
                actionSheet.title = "Routes"
                actionSheet.addButtonWithTitle("GO / I will GO")
                actionSheet.addButtonWithTitle("Route Info")
                actionSheet.addButtonWithTitle("Cancel")
                actionSheet.showFromRect(tableView.rectForRowAtIndexPath(indexPath), inView: tableView, animated: true)
                    {
                        (buttonIndex) in
                        println("ActionSheet: select \(buttonIndex) button")
                }
            }
        }
    }
    
    
    func findRoute() -> NSMutableArray
    {
        var result: NSMutableArray = NSMutableArray()
        for index in self.routes!
        {
            let myRoute : Route = Route(routeRepresentation: index as NSDictionary)
            var isFromTrue = false
            var isToTrue = false
            var isTimeTrue = false
            var isDateTrue = false
            var isSeatsTrue = false
            if let tempFrom = self.from
            {
                if tempFrom == myRoute.from
                {
                    //TODO with checkpoints
                    isFromTrue = true
                }
            }
            else
            {
                isFromTrue = true
            }
            
            if let tempTo = self.to
            {
                if tempTo == myRoute.to
                {
                    //TODO with checkpoints
                    isToTrue = true
                }
            }
            else
            {
                isToTrue = true
            }
            
            if let tempDate = self.date
            {
                if tempDate == myRoute.schedule?.date
                {
                    isDateTrue = true
                }
            }
            else
            {
                isDateTrue = true
            }
            
            if self.numberOfSeats == myRoute.numberOfSeats
            {
                isSeatsTrue = true
            }
            
            if isFromTrue && isToTrue && isTimeTrue && isDateTrue && isSeatsTrue
            {
                result.addObject(index)
            }
        }
        return result
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return NO if you do not want the specified item to be editable.
    return true
    }
    */
    
    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
    // Delete the row from the data source
    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    } else if editingStyle == .Insert {
    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    }
    */
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
    
    }
    */
    
    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return NO if you do not want the item to be re-orderable.
    return true
    }
    */
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    }
    */
    
}
