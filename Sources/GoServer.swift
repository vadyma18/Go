
enum ServerResultCode : UInt32
{
	case OK = 1
    case UserAlreadyIsRegistered = 5
    case UserAlreadyIsLogin = 2
    case ErrorPassword = 3
	case ConnectionError = 4
	case ProtocolError = 6
    case UserIsNotLogin = 7
    
    case MissingSession = 8
    case IncorrectPolyline = 9
    
    case InvalidJson = 80
    case MissingJson = 81

}

class GoServer
{
	class var instance : GoServer
	{
		get
		{
			struct StaticVar
			{
				static let instance = GoServer()
			}
			return StaticVar.instance
		}
	}
    
    var sessid : String? = nil
    var connectionQueue: NSOperationQueue = NSOperationQueue()
    var deviceToken: NSString?

    func setToken(dataToken: NSData?) {
        if self.deviceToken == nil {
            if let tokenBytes = dataToken?.bytes
            {
                var characterSet: NSCharacterSet = NSCharacterSet( charactersInString: "<>" )
                self.deviceToken = ((dataToken!.description as NSString )
                    .stringByTrimmingCharactersInSet( characterSet )
                    .stringByReplacingOccurrencesOfString( " ", withString: "" ))
            }
        }
    }

    private func resultCodeFromResult(result: NSDictionary) -> UInt32
    {
        if let value = (result["code"] as? NSNumber)?.unsignedIntValue
        {
            return value
        }
        return 6
    }
	
// MARK: - Send Request

	func sendRequestWith(path: String, method: String, handler: (result: NSDictionary?, code: UInt32) -> Void)
	{
		self.sendRequestWith(path, method: method, body: nil, headerFields: nil, handler)
	}

	func sendRequestWith(path: String, method: String, body: AnyObject?, handler: (result: NSDictionary?, code: UInt32) -> Void)
	{
		self.sendRequestWith(path, method: method, body: body, headerFields: nil, handler)
	}
	
	func sendRequestWith(path: String, method: String, headerFields: NSDictionary?, handler: (result: NSDictionary?, code: UInt32) -> Void)
	{
		self.sendRequestWith(path, method: method, body: nil, headerFields: headerFields, handler)
	}

	func sendRequestWith(path: String, method: String, body: AnyObject?, headerFields: NSDictionary?, handler: (result: NSDictionary?, code: UInt32) -> Void)
	{
		self.sendRequestWith(path, method: method, body: body, contentType: "json", headerFields: headerFields, handler)
	}

	func sendRequestWith(path: String, method: String, body: AnyObject?, contentType : String, headerFields: NSDictionary?, handler: (result: NSDictionary?, code: UInt32) -> Void)
	{
//		println("REQUEST INFO: path = <\(path)> method = <\(method)> httpFields = <\(headerFields)>")
		var urlString = kServerURL + "/"
		var request = NSMutableURLRequest(URL: NSURL(string: urlString + path)!)
		request.HTTPMethod = method

		if contentType == "json" {
			if body != nil
			{
				request.HTTPBody = NSJSONSerialization.dataWithJSONObject(body!, options: NSJSONWritingOptions(), error: nil)
			}
			request.setValue("application/json", forHTTPHeaderField: "Content-Type")
			request.setValue("application/json", forHTTPHeaderField: "Accept")
		}
		else
		{
			if body != nil
			{
				request.HTTPBody = (body as? NSData)!
			}
		}

		if self.sessid != nil
		{
			request.setValue(self.sessid, forHTTPHeaderField: "sessionId")
		}

		if headerFields != nil
		{
			for (key, value) in headerFields!
			{
				request.setValue(value as? String, forHTTPHeaderField: key as String)
			}
		}
		
		NSURLConnection.sendAsynchronousRequestWithoutSSLVerification(request, queue: connectionQueue)
			{
				(response, data, error) in

//				var responce : AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(), error: nil)
//				if responce != nil {
//				}
//				else {
//					responce = NSString(data: data, encoding: NSUTF8StringEncoding)
//				}
//				println("RESPONSE = \(responce) \n Error = \(error)")

				var code: UInt32 = 0
				var result : NSDictionary? = nil
				if error != nil
				{
					code = 4
				}
				else
				{
					if let json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(), error: nil) as? NSDictionary
					{
						code = self.resultCodeFromResult(json)
						result = json
					}
					else
					{
						code = 6
					}
				}
				
				dispatch_async(dispatch_get_main_queue())
					{
						handler(result: result, code: code)
				}
		}
	}
}
