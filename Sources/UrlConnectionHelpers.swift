
extension NSURLConnection
{
    class URLConnectionDelegate : NSObject, NSURLConnectionDataDelegate
    {
        var handler : (NSURLResponse!, NSData!, NSError!) -> Void
        let data = NSMutableData()
        var response : NSURLResponse?

        init(handler: (NSURLResponse!, NSData!, NSError!) -> Void)
        {
            self.handler = handler
        }
        
        func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse)
        {
            self.response = response
        }
        
        func connection(connection: NSURLConnection, didReceiveData data: NSData)
        {
            self.data.appendData(data)
        }
        
        func connectionDidFinishLoading(connection: NSURLConnection)
        {
            handler(response!, data, nil)
        }
        
        func connection(connection: NSURLConnection, didFailWithError error: NSError)
        {
            handler(response, nil, error)
        }
        
        func connection(connection: NSURLConnection, canAuthenticateAgainstProtectionSpace protectionSpace: NSURLProtectionSpace) -> Bool
        {
            return true
        }
        
        func connection(connection: NSURLConnection, willSendRequestForAuthenticationChallenge challenge: NSURLAuthenticationChallenge)
        {
            if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust
            {
                challenge.sender.useCredential(NSURLCredential(forTrust: challenge.protectionSpace.serverTrust), forAuthenticationChallenge:challenge)
            }
        }
    }

    class func sendAsynchronousRequestWithoutSSLVerification(request: NSURLRequest, queue: NSOperationQueue!, completionHandler handler: (NSURLResponse!, NSData!, NSError!) -> Void)
    {
        let connection = NSURLConnection(request: request, delegate: URLConnectionDelegate(handler: handler))!
        connection.setDelegateQueue(queue)
        connection.start()
    }
}
