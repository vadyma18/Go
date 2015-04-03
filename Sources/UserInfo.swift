
import Foundation

class UserInfo
{
    lazy var userId: String = ""
    lazy var userNickName: String = "NickName"
    lazy var userPhoneNumber:String = ""
    lazy var userImageId: String = ""

    init(userId : String, userNickName : String, userPhoneNumber : String, userImageId : String)
	{
        self.userId				= userId
        self.userNickName		= userNickName
        self.userPhoneNumber	= userPhoneNumber
        self.userImageId		= userImageId
    }

    init(jsonRepresentaion: NSDictionary)
	{
        self.userId				= jsonRepresentaion.objectForKey(kUserId) as? String ?? jsonRepresentaion.objectForKey(kDriverId) as String
        self.userNickName		= jsonRepresentaion.objectForKey(kUserNickName)  as String
        self.userPhoneNumber	= jsonRepresentaion.objectForKey(kUserPhoneNumber)  as? String ?? ""
        self.userImageId		= jsonRepresentaion.objectForKey(kUserImageId)  as String
    }
}