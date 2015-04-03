
import Foundation

extension GoServer
{
    func getCommentsForRideWithIdentifier(rideId: String, handler: (code: ServerResultCode, comments: NSMutableArray) -> Void)
    {
        let fields : NSDictionary = ["routeId" : rideId]
        self.sendRequestWith("rides/comments", method: "GET", body: nil, headerFields: fields)
        {
            (result, code) in
            var routes = NSMutableArray()
            if code == 0
            {
                if let json = result as NSDictionary?
                {
                    if let commentsArray = json.objectForKey("comments") as? NSArray
                    {
                        for object in commentsArray
                        {
                            autoreleasepool
                            {
                                if let res = object as? NSDictionary
                                {
                                    var comment = Message(jsonRepresentaion:res)
                                    routes.addObject(comment)
                                }
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
            handler(code: newCode, comments: routes)
        }
    }
    
    func addCommentToRoute(routeId: String, message: Message, handler: (code: ServerResultCode) -> Void)
    {
        let request: [String: AnyObject] =
        [
            kRouteId : routeId,
            kText : message.text,
            kTimeStamp : message.timestamp
        ]

        self.sendRequestWith("rides/comments", method: "POST", body: request, headerFields: nil)
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
            handler(code: newCode)
        }
    }

}