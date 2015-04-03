
import Foundation

extension GoServer
{
	func getUserImage(userId : NSString, handler: (imageData: NSData?) -> Void)
	{
		var urlString = kServerURL + "/user/profile/avatar/\(userId)/"
		var request = NSMutableURLRequest(URL: NSURL(string: urlString)!)

		NSURLConnection.sendAsynchronousRequest(request, queue: connectionQueue)
        {
            (response, data, error) in
            dispatch_async(dispatch_get_main_queue())
            {
                handler(imageData: data)
            }
		}
	}
    
    func getUserImageSync(userId : NSString) -> NSData
    {
        var urlString = kServerURL + "/user/profile/avatar/\(userId)/"
        return NSData(contentsOfURL: NSURL(string: urlString)!)!
    }
}