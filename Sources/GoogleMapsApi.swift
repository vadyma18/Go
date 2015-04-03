
import Foundation

let kAPIKey : String = "AIzaSyBBTcengpdEOAqYUoEJyTIiTgamnr6rUS0"

class GoogleMapsApi
{
    let connectionQueue = NSOperationQueue()
    var services : AnyObject? = nil
    
	class var instance : GoogleMapsApi
	{
		get
		{
			struct StaticVar
			{
				static let instance = GoogleMapsApi()
			}
			return StaticVar.instance
		}
	}
    
	func load()
	{
		// TODO: Do this through notification center
		GMSServices.provideAPIKey(kAPIKey)
		services = GMSServices.sharedServices()
	}
	func getPathForMarkers(markers: NSMutableArray, optimizeWaypoints: Bool = true, handler: (path: GMSPath?) -> Void)
	{
		let request = requestForMarkers(markers, optimizeWaypoints)
		if request == nil
		{
			handler(path: nil)
			return
		}
		NSURLConnection.sendAsynchronousRequest(request!, queue: connectionQueue)
		{
			(response, data, error) in
			var result : GMSPath?
			if error != nil
			{
				println("Connection error: ", error)
			}
			else
			{
				if let routes = (NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: nil) as? NSDictionary)?["routes"] as? NSArray
				{
					if routes.count > 0
					{
						if let overviewPolyline = (routes[0] as? NSDictionary)?["overview_polyline"] as? NSDictionary
						{
							if let points = overviewPolyline["points"] as? String
							{
								result = GMSPath(fromEncodedPath: points)
							}
						}
					}
				}

				if result == nil
				{
					println("JSON " + NSString(data: data, encoding: NSUTF8StringEncoding)!)
				}
			}
			
			dispatch_async(dispatch_get_main_queue())
			{
				handler(path: result)
			}
		}
	}
	func getApproximateAddressForCoordinates(coords: CLLocationCoordinate2D, handler: (address: String?) -> Void)
	{
		let urlString = "https://maps.googleapis.com/maps/api/geocode/json?result_type=street_address&latlng=\(coords.latitude),\(coords.longitude)&key=\(kAPIKey)"
		let request = NSURLRequest(URL: NSURL(string: urlString)!)
		NSURLConnection.sendAsynchronousRequest(request, queue: connectionQueue)
		{
			(response, data, error) in
			var result : String?
			if error != nil
			{
				println("Connection error: ", error)
			}
			else
			{
				if let results = (NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: nil) as? NSDictionary)?["results"] as? NSArray
				{
					if results.count > 0
					{
                        if let components = (results[0] as? NSDictionary)?["address_components"] as? NSArray
						{
							for i : AnyObject in components
							{
                                if let dict = i as? NSDictionary
                                {
                                    if let types = dict["types"] as? NSArray
                                    {
                                        if types.containsObject("route")
                                        {
                                            if let shortName = dict["short_name"] as? String
                                            {
                                                result = shortName
                                            }
                                            else if let longName = dict["long_name"] as? String
                                            {
                                                result = longName
                                            }
                                            
                                            if result != nil
                                            {
                                                break
                                            }
                                        }
                                    }
                                }
							}
						}
					}
				}

				if result == nil
				{
					println("JSON " + NSString(data: data, encoding: NSUTF8StringEncoding)!)
				}
			}

			dispatch_async(dispatch_get_main_queue())
			{
				handler(address: result)
			}
		}
	}
    
	func getFormattedAddressForCoordinates(coords: CLLocationCoordinate2D, handler: (address: String?) -> Void)
	{
		let urlString = "https://maps.googleapis.com/maps/api/geocode/json?result_type=street_address&latlng=\(coords.latitude),\(coords.longitude)&key=\(kAPIKey)"
		let request = NSURLRequest(URL: NSURL(string: urlString)!)
		NSURLConnection.sendAsynchronousRequest(request, queue: connectionQueue)
		{
			(response, data, error) in
			var result : String?
			if error != nil
			{
				println("Connection error: ", error)
			}
			else
			{
				if let results = (NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: nil) as? NSDictionary)?["results"] as? NSArray
				{
					if results.count > 0
					{
                        if let component = (results[0] as? NSDictionary)?["formatted_address"] as? NSString
                        {
                            result = component
                        }
					}
				}

				if result == nil
				{
					println("JSON " + NSString(data: data, encoding: NSUTF8StringEncoding)!)
				}
			}

			dispatch_async(dispatch_get_main_queue())
			{
				handler(address: result)
			}
		}
	}
    
    func getApproximateCoordinatesForAddress(address: NSString, language: NSString, handler: (coords: NSArray?) -> Void)
    {
        let encodedAddress = address.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        let urlString = "https://maps.googleapis.com/maps/api/geocode/json?address=\(encodedAddress)&region=ua&language=\(language)&key=\(kAPIKey)"

        let request = NSURLRequest(URL: NSURL(string: urlString)!)

        NSURLConnection.sendAsynchronousRequest(request, queue: connectionQueue)
            {
                (response, data, error) in
                var result: NSArray?
                if error != nil
                {
                    println("Connection error: ", error)
                }
                else
                {
                    if let results = (NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: nil) as? NSDictionary)?["results"] as? NSArray
                    {
                        if results.count > 0
                        {
                            result = results
                        }
                    }
                    if result == nil
                    {
                        println("JSON " + NSString(data: data, encoding: NSUTF8StringEncoding)!)
                    }
                }
                
                dispatch_async(dispatch_get_main_queue())
                {
                    handler(coords: result?)
                }
        }
    }
    
    func getCoordinatesForAddress(address: NSString, language: NSString, handler: (coords: CLLocationCoordinate2D?) -> Void)
    {
        let encodedAddress = address.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        let urlString = "https://maps.googleapis.com/maps/api/geocode/json?address=\(encodedAddress)&region=ua&language=\(language)&key=\(kAPIKey)"
        
        let request = NSURLRequest(URL: NSURL(string: urlString)!)
        
        NSURLConnection.sendAsynchronousRequest(request, queue: connectionQueue)
            {
                (response, data, error) in
                var result: CLLocationCoordinate2D?
                if error != nil
                {
                    println("Connection error: ", error)
                }
                else
                {
                    if let results = (NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: nil) as? NSDictionary)?["results"] as? NSArray
                    {
                        if results.count > 0
                        {
                            if let components = (results[0] as? NSDictionary)?["geometry"] as? NSDictionary
                            {
                                if let location = components["location"] as? NSDictionary
                                {
                                    result = CLLocationCoordinate2D(latitude: location["lat"] as Double, longitude: location["lng"] as Double)
                                }
                            }
                        }
                    }
                    if result == nil
                    {
                        println("JSON " + NSString(data: data, encoding: NSUTF8StringEncoding)!)
                    }
                }
                
                dispatch_async(dispatch_get_main_queue())
                    {
                        handler(coords: result?)
                }
        }
    }

    
    //AUTOCOMPLETE
    func getSearchResultsForString(searchString: NSString, language: String, sensor: String, handler: (places: NSMutableArray?) -> Void)
    {
        let encodedAddress = searchString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!

        let urlString = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=\(encodedAddress)&types=geocode&language=\(language)&location=50.44179976269,30.520248860126&radius=50&sensor=\(sensor)&key=\(kAPIKey)"

        let request = NSURLRequest(URL: NSURL(string: urlString)!)
        
        NSURLConnection.sendAsynchronousRequest(request, queue: connectionQueue)
            {
                (response, data, error) in
                var result: NSMutableArray?
                if error != nil
                {
                    println("Connection error: ", error)
                }
                else
                {
                    if let results = (NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: nil) as? NSDictionary)?
                    {
                        if results.count > 0
                        {
                            let status = results.objectForKey("status") as? String
                            if status == "OK"
                            {
                                if let predictions = results.objectForKey("predictions") as? NSArray
                                {
                                    result = NSMutableArray()
                                    for object in predictions
                                    {
                                        let description = object as? NSDictionary
                                        result!.addObject(description!)
                                    }
                                }

                            }
                            else
                            {
                                result = NSMutableArray()
                                result!.addObject(status!)
                            }
                        }
                    }
                    if result == nil
                    {
                        println("JSON " + NSString(data: data, encoding: NSUTF8StringEncoding)!)
                    }
                }
                
                dispatch_async(dispatch_get_main_queue())
                {
                    handler(places: result?)
                }
        }
    }

    
	// private
	func requestForMarkers(markers: NSMutableArray, _ optimizeWaypoints: Bool = true) -> NSURLRequest?
	{
		let length = markers.count;
		if (length < 2)
		{
			return nil
		}
		
		let firstCoordinate = (markers.firstObject as GMSMarker).position
		let lastCoordinate = (markers.lastObject as GMSMarker).position
		
		var requestString = "http://maps.googleapis.com/maps/api/directions/json?"
		requestString += "origin=(\(firstCoordinate.latitude),\(firstCoordinate.longitude))&destination=(\(lastCoordinate.latitude),\(lastCoordinate.longitude))"
		
		if (length > 2)
		{
			var points = ""
			
			// TODO: Do it with point encoding.
			for i in 1 ..< length - 1
			{
				let pos = (markers[i] as GMSMarker).position
				if (i != 1)
				{
					points += "|"
				}
				
				points += "(\(pos.latitude),\(pos.longitude))"
			}

			if optimizeWaypoints
			{
				points = "optimize:true|" + points
			}

            requestString += "&waypoints=" + (points as NSString).stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!;
		}
            
		return NSURLRequest(URL: NSURL(string: requestString)!)
	}

}
