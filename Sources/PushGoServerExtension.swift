
import Foundation

extension GoServer{
    func joinRide(routeId:String, message:String, handler: (code: ServerResultCode) -> Void)
    {
//        let request : [String: String] = [ kRouteId : routeId,
//                                            kNotificationMessage : message]
        // delete when bug will be resolved on server
        let request : [String: String] = [	"routeId" : routeId,
											kNotificationMessage : message]

		sendRequestWith("/user/join", method: "POST", body: request, headerFields: nil) {
			(result, code) in
			var newCode = ServerResultCode.OK
			if code != 0 {
					newCode = .ProtocolError
				}
			handler(code: newCode)
        }
    }

    func acceptPassenger(routeId:String, userId:String, accept:String, message:String, handler: (code: ServerResultCode) -> Void)
    {
        let request : [String: String] = [kNotificationRideId : routeId,
										kUserId : userId,
										kNotificaitonAcceept : accept,
										kNotificationMessage : message]

		sendRequestWith("user/accept", method: "POST", body: request, headerFields: nil) {
			(result, code) in
			var newCode = ServerResultCode.OK
			if code != 0 {
				newCode = .ProtocolError
			}
			handler(code: newCode)
        }
    }
    // not realized on server
    func declinePassenger(routeId:String, userId:String, accept:String, message:String, handler: (code: ServerResultCode) -> Void)
    {
        let request : [String: String] = [kNotificationRideId : routeId,
            kUserId : userId,
            kNotificaitonAcceept : accept,
            kNotificationMessage : message]
        
        sendRequestWith("user/accept", method: "POST", body: request, headerFields: nil) {
            (result, code) in
            var newCode = ServerResultCode.OK
            if code != 0 {
                newCode = .ProtocolError
            }
            handler(code: newCode)
        }
    }

}