
import Foundation

extension GoServer{
    func getUserInfo(userId:String, handler: (code: ServerResultCode, result : UserInfo) -> Void){
        var header : NSDictionary = [kUserId : userId]
        
         GoServer.instance.sendRequestWith("user/profile", method: "GET", body: nil, headerFields: header)
            {
                (result, code) in
                var userInfo : UserInfo = UserInfo(userId: userId, userNickName: "", userPhoneNumber: "", userImageId: "")
                if code == 0 {
                    if let res : NSDictionary = result
                    {
                        userInfo.userPhoneNumber = res.objectForKey(kUserPhoneNumber) as String!
                        userInfo.userNickName = res.objectForKey(kUserNickName) as String!
                        if userInfo.userNickName == ""{
                            //Temporary solution, because not all fields of profile are filled for every user
                            userInfo.userNickName=res.objectForKey(kUserEmail) as String!
                        }
                        userInfo.userImageId = res.objectForKey(kUserImageId) as String!
                    }
                }
                var newCode = ServerResultCode.OK
                if code != 0
                {
                    newCode = ServerResultCode.ProtocolError
                }
                handler(code: newCode, result: userInfo)
        }
    }
}