
import Foundation

class Route: NSObject
{
	var rideId: String?
	var driverId: String?
    var pendingUsers: NSMutableArray = NSMutableArray()
    var approvedUsers: NSMutableArray  = NSMutableArray()
    var from : String?
    var to : String?
    var numberOfSeats : Int?
    var checkPoints: NSMutableArray?
    var schedule: Schedule?
    var status: Int?
    var path : GMSPath = GMSPath()
   
    init(routeRepresentation : NSDictionary)
    {
        super.init()
        self.rideId = routeRepresentation.objectForKey(kRouteId) as? String
        self.driverId = routeRepresentation.objectForKey(kRouteDriverId) as? String
        self.status = routeRepresentation.objectForKey(kRouteStatus) as? Int
        self.from = routeRepresentation.objectForKey(kRouteFrom) as? String
        self.to = routeRepresentation.objectForKey(kRouteTo) as? String
        self.numberOfSeats = routeRepresentation.objectForKey(kRouteSeats) as? Int
        self.polyline = routeRepresentation.objectForKey(kRoutePolyLine) as? String
        self.schedule = Schedule(sheduleRepresentation: routeRepresentation)        
        if let pendingUsersRep = routeRepresentation.objectForKey(kRoutePendingUsers) as? NSArray {
            for user in pendingUsersRep {
                if let userDic = user as? NSDictionary {
                    var userInfoValue : UserInfo = UserInfo(jsonRepresentaion: userDic)
                    self.pendingUsers.addObject(userInfoValue)
                }
            }
        }
        if let approvedUsersRep = routeRepresentation.objectForKey(kRouteApprovedUsers) as? NSArray {
            for user in approvedUsersRep {
                if let userDic = user as? NSDictionary {
                    var userInfoValue : UserInfo = UserInfo(jsonRepresentaion: userDic)
                    self.approvedUsers.addObject(userInfoValue)
                }
            }
        }
    }
    
    var longPolyline : String?
    {
        get
        {
            var newLongPolyline = NSMutableString()
            if path.encodedPath()!.isEmpty
            {
                if checkPoints?.count > 1
                {
                    GoogleMapsApi.instance.getPathForMarkers(checkPoints!, optimizeWaypoints: true)
                    {
                        (path) in
                        if let newPath = path
                        {
                            self.path = newPath
                            newLongPolyline.appendString(newPath.encodedPath()!)
                        }
                    }
                }
            }
            else
            {
                newLongPolyline.appendString(path.encodedPath()!)
            }
            
            return newLongPolyline
        }
        set
        {
            path = GMSPath(fromEncodedPath: newValue!)
        }
    }
    
    var polyline : String? {
        get {
            var polyLine = NSMutableString()
            if let wayPoints = checkPoints as NSArray!{
                var wayPath = GMSMutablePath()
                for marker in wayPoints {
                    wayPath.addCoordinate((marker as GMSMarker).position)
                }
                polyLine.appendString(wayPath.encodedPath())
            }
            return polyLine as String
        }
        set {
            checkPoints = []
            if newValue != nil && !newValue!.isEmpty{
                var invalidCharacters : NSMutableCharacterSet = NSMutableCharacterSet.decimalDigitCharacterSet()
                invalidCharacters.formUnionWithCharacterSet(NSMutableCharacterSet.whitespaceAndNewlineCharacterSet())
                if newValue!.componentsSeparatedByCharactersInSet(invalidCharacters).count <= 1
                {
                    SwiftTryCatch.try(
                        {
                            () -> Void in
                            if let wayPath = GMSPath(fromEncodedPath: newValue!)
                            {
                                for i in 0...wayPath.count()-1
                                {
                                    self.checkPoints?.addObject(GMSMarker(position: wayPath.coordinateAtIndex(i)))
                                }
                            }
                        },
                        catch:
                        {
                            (error) -> Void in
                             println("Route with id \(self.rideId) incorect!!!")
                        },
                        finally:
                        {
                            () -> Void in
                        })
                }
            }
        }
    }
    //Init from CreateRoute Page1 to send to second page
    init(checkPoints: NSMutableArray, from: String, to: String, path: GMSPath)
    {
        super.init()
        self.checkPoints = checkPoints
        self.from = from
        self.to = to
        self.path = path
        self.numberOfSeats = 3
        self.schedule = Schedule()
    }
    required override init() {
	}
	
	func isRouteContainsCurrentUser () -> Bool
	{
		var contains : Bool = false

        var allUsers : NSMutableArray = NSMutableArray()

        if (self.pendingUsers.count > 0) {

            allUsers.addObjectsFromArray(self.pendingUsers)
        }
        
        if (self.approvedUsers.count > 0) {
            
            allUsers.addObjectsFromArray(self.approvedUsers)
        }

        for user in allUsers {
            if let userInfo = user as? UserInfo
            {
                if userInfo.userId == UserProfile.currentUserProfile().userId {
                    contains = true;
                    break
                }
            }
        }
        return contains;
	}
}