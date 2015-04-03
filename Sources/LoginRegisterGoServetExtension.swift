
import Foundation

let clientIdValue : NSString = "iOS"
let clientVersionValue : NSString = (NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as? String) ?? "1.0"

extension GoServer
{
    func registerAndLogin(email: String, password: String, handler: (code: ServerResultCode) -> Void)
    {
        
        let request : [String: String] = [kUserName : email,
                                            kUserPassword : password,
                                            kClientId : clientIdValue,
                                            kClientVersion :clientVersionValue,
                                            kDeviceToken : self.deviceToken ?? ""]

      self.register(request, handler: {
            (code) in
            if code == .UserAlreadyIsRegistered
            {
                self.login(request, handler: handler)
            } else {
                handler(code: code)
            }
        })
    }
    
    private func login(request: NSDictionary, handler: (code: ServerResultCode) -> Void)
    {
		sendRequestWith("user/login", method: "POST", body: request, headerFields: nil) {
            (result, code) in
            var newCode = ServerResultCode.OK
            if code == 0 || code == 1
            {
                if let res : NSDictionary = result
                {
                    self.sessid = res.objectForKey(kSessionId) as? String
					if let userId: Int = res.objectForKey(kUserId) as? Int {
						UserProfile.currentUserProfile().loadUserProfile("\(userId)")
					}
					else if let userId: String = res.objectForKey(kUserId) as? String {
						UserProfile.currentUserProfile().loadUserProfile(userId)
					}
					else {
						println("Server error: Perform login user without userId")
					}
				}
                else
                {
                    newCode = .ProtocolError
                }
            }
            else if code == 2 { newCode = .ErrorPassword }
            else { newCode = .ConnectionError }
            handler(code: newCode)
        }
    }
    private func register(request: NSDictionary, handler: (code: ServerResultCode) -> Void)
    {
		sendRequestWith("user/register", method: "POST", body: request, headerFields: nil) {
                (result, code) in

                var newCode = ServerResultCode.OK
                if code == 0
                {
                    if let res : NSDictionary = result
                    {
                        self.sessid = res.objectForKey(kSessionId) as? String
						if let userId: String = res.objectForKey(kUserId) as? String
						{
							UserProfile.currentUserProfile().loadUserProfile(userId)
						}
						else {
							println("Server error: Perform login user without userId")
						}
                    }
                    else
                    {
                        newCode = .ProtocolError
                    }
                }
                else if code == 5
                {
                    newCode = .UserAlreadyIsRegistered
                }
                else { newCode = .ConnectionError }
                handler(code: newCode)
        }
    }

    func logout(handler: (code: ServerResultCode) -> Void)
    {
		sendRequestWith("user/logout", method: "POST", body: nil, headerFields: nil) {
            (result, code) in
            var newCode = ServerResultCode.OK
            if code == 0
            {
                self.sessid = nil
            } else if code == 1
            {
                newCode = .UserIsNotLogin
            }else
            {
                newCode = .ConnectionError
            }
            handler(code: newCode)
        }
    }
}