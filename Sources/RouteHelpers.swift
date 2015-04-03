
import Foundation

func nameForSectionWithIndex (type: ScheduleTimeType) -> NSString
{
    var sectionName : NSString
    switch (type.rawValue)
    {
    case ScheduleTimeType.Today.rawValue    : sectionName = kTodaySection;	break
    case ScheduleTimeType.Tomorrow.rawValue : sectionName = kTommorowSection; break
    case ScheduleTimeType.DayType1.rawValue : sectionName = kMonday; break
    case ScheduleTimeType.DayType2.rawValue : sectionName = kTuesday; break
    case ScheduleTimeType.DayType3.rawValue : sectionName = kWednesday; break
    case ScheduleTimeType.DayType4.rawValue : sectionName = kThursday; break
    case ScheduleTimeType.DayType5.rawValue : sectionName = kFriday; break
    case ScheduleTimeType.DayType6.rawValue : sectionName = kSaturday; break
    case ScheduleTimeType.DayType7.rawValue : sectionName = kSunday; break
    default: sectionName = ""; break
    }
    return sectionName
}

func insertRoute(route: Route, withTimeSortInArray routesArray: NSMutableArray)
{
    var time1: String = NSDate.routeTimeFormater.stringFromDate(route.schedule!.date)
    
    for (index,value) in enumerate(routesArray) {
        var time2: String = NSDate.routeTimeFormater.stringFromDate((value as Route).schedule!.date)
        if time1 < time2 {
            routesArray.insertObject(route, atIndex: index)
            return
        }
    }
    routesArray.addObject(route)
}

func insertRoute(route: Route, withDateSortInArray routesArray: NSMutableArray)
{
    var date1: NSDate = route.schedule!.date
    
    for (index,value) in enumerate(routesArray) {
        var date2: NSDate = ((value as Route).schedule!.date)
        if date1.compare(date2).rawValue < 0 {
            routesArray.insertObject(route, atIndex: index)
            return
        }
    }
    routesArray.addObject(route)
}

func createRouteOnMapView(#checkPoints: NSArray, #mapView: GMSMapView,
        #currentPath: GMSPolyline, #optimizeWaypoints: Bool, #withEdgeInsets: Bool)
{
    if checkPoints.count > 1
    {
        for var i = 0; i < checkPoints.count - 1; ++i
        {
            var newMarker = GMSMarker(position: (checkPoints.objectAtIndex(i) as GMSMarker).position)
            newMarker.map = mapView
        }
        var destinationMarker = GMSMarker(position: (checkPoints.lastObject as GMSMarker).position)
        destinationMarker.icon = UIImage(named: "destination_marker")
        destinationMarker.map = mapView
        var mutableCheckPoints = NSMutableArray(array: checkPoints)
        
        GoogleMapsApi.instance.getPathForMarkers(mutableCheckPoints, optimizeWaypoints: optimizeWaypoints)
        {
            (path) in
            currentPath.path = path
            currentPath.map = mapView
        
            //for RouteDriverPreviewTableView withEdgeInsets = TRUE
            if withEdgeInsets
            {
                var topEdge : CGFloat = 30
                var bottomEdge : CGFloat = 10
                if mapView.frame.height > 100
                {
                    topEdge = 140
                    bottomEdge = 30
                }
                mapView.animateWithCameraUpdate(GMSCameraUpdate.fitBounds(GMSCoordinateBounds(path: currentPath.path), withEdgeInsets: UIEdgeInsets(top: topEdge, left: 10, bottom: bottomEdge, right: 10)))
            }
            else
            {
                mapView.animateWithCameraUpdate(GMSCameraUpdate.fitBounds(GMSCoordinateBounds(path: currentPath.path)))
            }
        }
    }
}

func sortRoutes(routes: NSMutableArray) {
    routes.sortUsingComparator({
        (obj1, obj2) in
        let r1 = obj1 as Route
        let r2 = obj2 as Route
        if r1.schedule?.getScheduleTimeType().typeIndex < r2.schedule?.getScheduleTimeType().typeIndex {
            return NSComparisonResult.OrderedAscending
        } else if r1.schedule?.getScheduleTimeType().typeIndex > r2.schedule?.getScheduleTimeType().typeIndex {
            return NSComparisonResult.OrderedDescending
        }
        return NSComparisonResult.OrderedSame
    })
}

func getRouteByIndexPath(items: NSMutableArray, indexPath: NSIndexPath) -> Route
{
    let section = items.objectAtIndex(indexPath.section) as NSDictionary
    let route = (section.objectForKey("routes") as NSArray).objectAtIndex(indexPath.row) as Route
    return route
}
