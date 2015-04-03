
import Foundation

extension GoServer{
    
    func createRide(route: Route!, handler: (code: ServerResultCode, result: NSDictionary?) -> Void)
    {
        let startAddress: String = route.from ?? ""
        let stopAddress: String = route.to ?? ""
        //let date: String = route.schedule?.date!.toISOString() ?? NSDate().toISOString()   
        var timestamp: NSTimeInterval = route.schedule!.date.timeIntervalSince1970
        let seats: Int = route.numberOfSeats!
        let interval: Int = route.schedule?.dalayInterval ?? 0
        let points: String = route.polyline ?? ""
        let days: Int = route.schedule?.days ?? 0
        let status: Int = route.status ?? 1
        let longPolyline: String = route.longPolyline ?? ""
        let request: [String: AnyObject] =
        [
            kRouteFrom : startAddress,
            kRouteTo : stopAddress,
            kScheduleDate : timestamp,
            kScheduleInterval : interval,
            kRouteSeats : seats,
            kRoutePolyLine : points,
            kScheduleDays : days,
            kRouteStatus : status,
            kRouteLongPolyline : longPolyline
        ]
        
        self.sendRequestWith("rides/route", method: "POST", body: request, headerFields: nil)
        {
            (result, code) in
            var newCode = ServerResultCode.OK
            if code != 0
            {
                if code == 4
                {
                    newCode = ServerResultCode.ConnectionError
                }
                else
                {
                    newCode = ServerResultCode.ProtocolError
                }
            }
            handler(code: newCode, result: result)
        }
    }
    
    func getRides(handler: (code: ServerResultCode, routes: NSMutableArray, driversInfo: NSMutableDictionary) -> Void){
       self.sendRequestWith("rides/routes", method: "GET", body: nil, headerFields: nil) {
			(result, code) in
			var routes = NSMutableArray()
            var driversInfo = NSMutableDictionary()
            if code == 0
            {
                if let json = result as NSDictionary?
                {
                    if let routeArray = json.objectForKey("routes") as? NSArray
                    {
                        for object in routeArray
                        {
                            if let res = object as? NSDictionary
                            {
                                var route = Route(routeRepresentation:res)
                                var driverInfo = UserInfo(jsonRepresentaion: res)
                                routes.addObject(route)
                                driversInfo.setObject(driverInfo, forKey: driverInfo.userId)
                            }
                        }
                    }
                }
            }
			var newCode = ServerResultCode.OK
			if code != 0
			{
				newCode = ServerResultCode.ProtocolError
			}
            handler(code: newCode, routes: routes, driversInfo: driversInfo)
        }
    }

    func getUserRides(handler: (code: ServerResultCode, routes: NSMutableArray) -> Void){
        self.sendRequestWith("rides/user_routes", method: "GET", body: nil, headerFields: nil)
        {
			(result, code) in
			var routes = NSMutableArray()
            if code == 0
            {
                if let json = result as NSDictionary?
                {
                    if let routeArray = json.objectForKey("routes") as? NSArray
                    {
                        for object in routeArray
                        {
                            if let res = object as? NSDictionary
                            {
                                var route = Route(routeRepresentation:res)
                                routes.addObject(route)
                            }
                        }
                    }
                }
            }
			var newCode = ServerResultCode.OK
			if code != 0
			{
				newCode = ServerResultCode.ProtocolError
			}
			handler(code: newCode, routes: routes)
        }
    }

    func changeRide(route: Route!, handler: (code: ServerResultCode) -> Void)
    {
        let routeID : String = route.rideId ?? ""
        let startAddress: String = route.from ?? ""
        let stopAddress: String = route.to ?? ""
        var timestamp: NSTimeInterval = route.schedule!.date.timeIntervalSince1970
        let seats: Int = route.numberOfSeats!
        let interval: Int = route.schedule?.dalayInterval ?? 0
        let points: String = route.polyline ?? ""
        let days: Int = route.schedule?.days ?? 0
        let status: Int = route.status ?? 1
        let longPolyline: String = route.longPolyline ?? ""
        let request: [String: AnyObject] =
        [
            kRouteId : routeID,
            kRouteFrom : startAddress,
            kRouteTo : stopAddress,
            kScheduleDate : timestamp,
            kScheduleInterval : interval,
            kRouteSeats : seats,
            kRoutePolyLine : points,
            kScheduleDays : days,
            kRouteStatus : status,
            kRouteLongPolyline : longPolyline
        ]
        
        self.sendRequestWith("rides/route", method: "PATCH", body: request, headerFields: nil)
        {
            (result, code) in
            var newCode = ServerResultCode.OK
            if code != 0
            {
                newCode = ServerResultCode.ProtocolError
            }
            handler(code: newCode)
        }
    }

    func getRide(rideId: String, handler: (code: ServerResultCode, route: Route?) -> Void){
        let fields : NSDictionary = ["routeId" : rideId]
		self.sendRequestWith("rides/route", method: "GET", headerFields: fields) {

			(result, code) in
			var route : Route?
			if code == 0{
				if let res = result as NSDictionary?{
					route = Route(routeRepresentation: result!)
				}
			}

			var newCode = ServerResultCode.OK
			if code != 0
			{
				newCode = ServerResultCode.ProtocolError
			}
			handler(code: newCode, route: route)
        }
    }
    
    func deleteRide(routeId: String, handler: (code: ServerResultCode, result: NSDictionary?) -> Void)
    {
        //let request : [String: String] = [ kRouteId : routeId ]
        // delete when bug will be resolved on server
        let request : [String: String] = [	"routeId" : routeId ]
        
        self.sendRequestWith("rides/route", method: "DELETE", body: nil, headerFields: request)
        {
            (result, code) in
            var newCode = ServerResultCode.OK
            if code != 0
            {
                newCode = ServerResultCode.ProtocolError
            }
            handler(code: newCode, result: result)
        }
    }
    
    func findRides(route: Route!, handler: (code: ServerResultCode, routes: NSMutableArray, driversInfo: NSMutableDictionary) -> Void)
    {
        let startAddress: String = route.from ?? ""
        let stopAddress: String = route.to ?? ""
        let timestamp: NSTimeInterval = route.schedule!.date.timeIntervalSince1970
        let seats: Int = route.numberOfSeats!
        let interval: Int = route.schedule?.dalayInterval ?? 0
        let points: String = route.polyline ?? ""
        let days: Int = route.schedule?.days ?? 0
        let status: Int = route.status ?? 1
        
        let request: [String: AnyObject] =
        [
            kRouteFrom : startAddress,
            kRouteTo : stopAddress,
            kScheduleDate : timestamp,
            kScheduleInterval : interval,
            kRouteSeats : seats,
            kRoutePolyLine : points,
            kScheduleDays : days,
            kRouteStatus : status
        ]
        
        self.sendRequestWith("rides/find", method: "POST", body: request, headerFields: nil)
        {
            (result, code) in
            var routes = NSMutableArray()
            var driversInfo = NSMutableDictionary()
            var newCode : ServerResultCode?
            if code == 0
            {
                if let json = result as NSDictionary?
                {
                    if let routeArray = json.objectForKey("routes") as? NSArray
                    {
                        for object in routeArray
                        {
                            if let res = object as? NSDictionary
                            {
                                var route = Route(routeRepresentation:res)
                                var driverInfo = UserInfo(jsonRepresentaion: res)
                                routes.addObject(route)
                                driversInfo.setObject(driverInfo, forKey: driverInfo.userId)
                            }
                        }
                    }
                }
                newCode = ServerResultCode.OK
            }
            else
            {
                switch code
                {
                    case 1 : newCode = ServerResultCode.ProtocolError; break
                    case 2 : newCode = ServerResultCode.MissingSession; break
                    case 3 : newCode = ServerResultCode.IncorrectPolyline; break
                    case 80 : newCode = ServerResultCode.InvalidJson; break
                    case 81 : newCode = ServerResultCode.MissingJson; break
                    default : break
                }
            }

            handler(code: newCode!, routes: routes, driversInfo: driversInfo)
        }
    }
}

