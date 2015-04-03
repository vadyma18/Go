
import Foundation

let kCurrentUserImageName : NSString = "currentUserImage.png"
let cacheDirectory : NSString = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0] as NSString
let kCacheUserImage = "cacheUserImage"

//default user
let kDefaultUserPicId : NSString = "userPicId"


//user
let kDriverId = "driverId"
let kUserId = "userId"
let kUserPassword = "password"
let kUserUserPic = "userPic"
let kUserName = "userName"
let kUserSurname = "userSurname"
let kUserDescriptionInfo = "userDescription"
let kUserEmail = "userEmail"
let kUserPhoneNumber = "userPhoneNumber"
let kUserImageId = "userImageId"
let kUserNickName = "userNickName"

//route
let kRouteFrom = "startAddress"
let kRouteTo = "stopAddress"
let kRouteSeats = "seats"
let kRouteCheckpoints = "checkPoints"
let kRouteSchedule = "schedule"
let kRouteDriverId = "driverId"
let kRoutePendingUsers = "pendingUsers"
let kRouteApprovedUsers = "approvedUsers"
let kRouteStatus = "status"
let kRouteId = "routeID"
let kRoutePolyLine = "points"
let kRouteLongPolyline = "points_extended"

//message
let kText = "text"
let kTimestamp = "timestamp"
let kCellForPassengerMessage = "cellForPassengerMessage"
let kCellForCurrentUserMessage = "cellForCurrentUserMessage"

//cache keys
let kCacheRoute = "route"

//section names
let kTakenPasangers = "Passengers taken"
let kPasangersToTake = "Want to ride"
let kTodaySection = "Today"
let kTommorowSection = "Tommorow"
let kMonday = "Monday"
let kTuesday = "Tuesday"
let kWednesday = "Wednesday"
let kThursday = "Thursday"
let kFriday = "Friday"
let kSaturday = "Saturday"
let kSunday = "Sunday"

//user info 
let kUserInfoUserId = "userId"
let kUserInfoUserNickName = "userNickName"
let kUserInfoUserPhoneNumber = "userPhoneNumber"
let kUserInfoUserImageId = "userImageId"

//schedule
let kScheduleDate = "date"
let kScheduleInterval = "interval"
let kScheduleDays = "days"
let kMyRouteCell = "myRouteCell"
let shortDayName: [String] = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"]
let interval: [String] = ["On time","10 Minutes","15 Minutes","30 Minutes"]
let kTimeStamp = "timestamp"

//server
let kServerURL = "https://go.zeoalliance.com"
let kClientId = "clientId"
let kClientVersion = "clientVersion"
let kDeviceToken = "deviceToken"
let kSessionId = "sessionId"

// cells
let kCustomCellNibName = "CustomCell"
let kCustomCellReusableId = "RouteCellId"
let kCellForApprovedUsersNibName = "CellForApprovedUsers"
let kCellForApprovedUsersRoutePreviewNibName = "CellForApprovedUsersRoutePreview"
let kCellForPendingUsersNibName = "CellForPendingUsers"
let kCellForApprovedUsersReusableId = "AproveForPassViewCell"
let kCellForApprovedUsersRoutePreviewReusableId = "AproveCell"
let kCellForPendingUsersReusableId = "PendingCell"
let kCellForRoutePreviewNibName = "CellForRoutePreview"
let kCellForRoutePreviewReusableId = "RoutePreview"

let kAPIName = "api"

// Push Notifications
let kNotificationRideId = "routeId"
let kNotificationMessage = "message"
let kNotificaitonAcceept = "accept"

//Page modes for map and aditional info views
enum PageMode : Int
{
    case
    create = 0,
    edit = 1,
    find = 2,
    show = 3
}

func defineTitleForPageMode(pageMode: PageMode) -> String
{
    switch pageMode
    {
    case .create : return "Create Route:"
    case .find : return "Find Route:"
    case .edit : return "Edit Route:"
    default : return ""
    }
}

func scaleImage(image: UIImage) -> UIImage?
{
    let hasAlpha = false
    let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
    
    var scaledImage = image
        while scaledImage.size.height > 300
        {
            autoreleasepool
            {
                let size = CGSizeApplyAffineTransform(scaledImage.size, CGAffineTransformMakeScale(0.5, 0.5))
                UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
                image.drawInRect(CGRect(origin: CGPointZero, size: size))
                
                scaledImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
            }
        }
    
    return scaledImage
}