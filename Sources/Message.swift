
import Foundation

class Message
{
    lazy var userId: String = ""
    lazy var timestamp: NSTimeInterval = 0
    lazy var text: String = ""
    lazy var userImageId = ""
    lazy var userNickName = ""
    
    init(text: String)
    {
        self.userId				= UserProfile.currentUserProfile().userId ?? ""
        self.timestamp          = NSDate().timeIntervalSince1970
        self.text               = text
        self.userImageId        = UserProfile.currentUserProfile().userImageId ?? ""
        self.userNickName       = UserProfile.currentUserProfile().userNickName ?? ""
    }
    
    init(jsonRepresentaion: NSDictionary)
    {
        self.userId				= jsonRepresentaion.objectForKey(kUserId) as? String ?? jsonRepresentaion.objectForKey(kDriverId) as String
        self.timestamp          = jsonRepresentaion.objectForKey(kTimestamp)  as NSTimeInterval
        self.text               = jsonRepresentaion.objectForKey(kText)  as String
        self.userImageId        = jsonRepresentaion.objectForKey(kUserImageId)  as String
        self.userNickName       = jsonRepresentaion.objectForKey(kUserNickName)  as String

    }
    
    func getDate() -> NSDate
    {
        return NSDate(timeIntervalSince1970: timestamp)
    }
}