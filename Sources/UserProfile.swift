
import Foundation

let kCurrentUserImageIdentifierKey = "CurrentUserImageIdentifierKey"
let kUserProfileDidChangeNotificationName = "UserProfileDidChangeNotificationName"

class UserProfile
{
	//singleton without multithreading support
	class func currentUserProfile() -> UserProfile {
		struct Static {
			static var instance: UserProfile?
		}
		
		if Static.instance == nil {
			Static.instance = UserProfile()
		}
		return Static.instance!
	}

	private var _userId		: String?
	private var _name: String?
	private var _surname: String?
	private var _descriptionInfo: String?
	private var _email: String?
	private var _phoneNumber: String?
	private var _userImageId: String?
	private var _userNickName: String?
	private	var _userAvatarImage: UIImage?

	var userId: String? {
		get
		{
			return _userId
		}
	}
	
	func pathForUserAvatarImage() -> String {
		return String(format: "%@/%@.png", cacheDirectory,  self.userImageId ?? "stub")
	}
	
	var stubAvatarImage : UIImage {
		get {
			return UIImage(named: "person")!
		}
	}

	var userAvatarImage: UIImage {
		get {
			if self._userAvatarImage == nil {
				if self.userImageId != nil
				{
					if (NSFileManager.defaultManager().fileExistsAtPath(self.pathForUserAvatarImage()))
					{
						self._userAvatarImage = UIImage(contentsOfFile: self.pathForUserAvatarImage())
					}
				}
				if self._userAvatarImage == nil {
					self._userAvatarImage = stubAvatarImage
				}
			}
			return self._userAvatarImage!
		}
		set {
			if self._userAvatarImage != newValue {
				
				self._userAvatarImage = newValue
			}
		}
	}

    var name: String {
		get {
			return self._name ?? ""
		}
		set {
			self._name = newValue
		}
	}

    var surname: String {
		get {
			return self._surname ?? ""
		}
		set {
			self._surname = newValue
		}
	}

	var descriptionInfo: String {
		get {
			return self._descriptionInfo ?? ""
		}
		set {
			self._descriptionInfo = ""
		}
	}

	var email: String {
		get {
			return self._email ?? ""
		}
		set {
			self._email = newValue
		}
	}

	var phoneNumber: String {
		get {
			return self._phoneNumber ?? ""
		}
		set {
			self._phoneNumber = newValue
		}
	}

	var userImageId: String? {
		get {
			if self._userImageId == nil
			{
				self._userImageId = NSUserDefaults.standardUserDefaults().objectForKey(kCurrentUserImageIdentifierKey) as? String
			}
			return self._userImageId
		}
		set {
			var defaults : NSUserDefaults = NSUserDefaults.standardUserDefaults()
			if self._userImageId != newValue
			{
				if newValue == nil {
					defaults.removeObjectForKey(kCurrentUserImageIdentifierKey)
				}
				else {
					defaults.setObject(newValue, forKey: kCurrentUserImageIdentifierKey)
				}
				self._userImageId = newValue
			}
		}
	}

	var userNickName: String {
		get {
			return self._userNickName ?? ""
		}
		set {
			self._userNickName = newValue
		}
	}

	private func currentUserProfileRepresentation () -> [String: String] {

		let profile: [String: String] = [ kUserName				: self.name,
										  kUserSurname			: self.surname,
										  kUserEmail			: self.email,
										  kUserPhoneNumber		: self.phoneNumber,
										  kUserDescriptionInfo	: self.descriptionInfo,
										  kUserNickName			: self.userNickName ]
		return profile
	}

    func saveUserProfile()
    {
		
		GoServer.instance.sendRequestWith("user/profile", method: "POST", body: self.currentUserProfileRepresentation(), headerFields: nil) {
			(result, code) in

			if code == 0 {
			}
			else {
				println("UserProfile save with errorCode: \(code) : \(result)")
			}
			NSNotificationCenter.defaultCenter().postNotificationName(kUserProfileDidChangeNotificationName, object: nil)
		}
		
		if self.userAvatarImage != self.stubAvatarImage {
			var imageData : NSData = UIImagePNGRepresentation(self.userAvatarImage)
			var fields : NSDictionary = [ "imageType" : "png" ]
			GoServer.instance.sendRequestWith("user/profile/avatar/", method: "POST", body : imageData, contentType : "PNG", headerFields: fields) {
				(result, code) in

				if code == 0 {
					if let res : NSDictionary = result {
						if let newImageID = res.objectForKey(kUserImageId) as? NSString {
							if self.userImageId != newImageID
							{
								NSFileManager.defaultManager().removeItemAtPath(self.pathForUserAvatarImage(), error: nil)
								self.userImageId = newImageID
								imageData.writeToFile(self.pathForUserAvatarImage(), atomically: true)
								NSNotificationCenter.defaultCenter().postNotificationName(kUserProfileDidChangeNotificationName, object: nil)
							}
						}
					}
				}
				else {
					println("UserImage save with errorCode: \(code) : \(result)")
				}
			}
		}

	}

    func loadUserProfile(currentUserId : NSString)
    {
		self._userId = currentUserId
		if self._userId != nil
		{
			var fields : NSDictionary = [ kUserId : currentUserId ]

			GoServer.instance.sendRequestWith("user/profile", method: "GET", body: nil, headerFields: fields) {
				(result, code) in

				if code == 0 {
					if let res : NSDictionary = result
					{
						self.name = res.objectForKey(kUserName) as String
						self.surname = res.objectForKey(kUserSurname) as String
						self.descriptionInfo = res.objectForKey(kUserDescriptionInfo) as String
						self.phoneNumber = res.objectForKey(kUserPhoneNumber) as String
						self.userNickName = res.objectForKey(kUserNickName) as String
						self.email = res.objectForKey(kUserEmail) as String
						if let newImageID = res.objectForKey(kUserImageId) as? String {
							NSFileManager.defaultManager().removeItemAtPath(self.pathForUserAvatarImage(), error: nil)
							self.userImageId = newImageID
							self.loadUserAvatarImage()
						}

						NSNotificationCenter.defaultCenter().postNotificationName(kUserProfileDidChangeNotificationName, object: nil)
					}
				}
				else {
					println("UserProfile load with errorCode: \(code) : \(result)")
				}
			}
		}
	}

	func loadUserAvatarImage() {
		
		var fields : NSDictionary = [ kUserId : self.userId! ]
		GoServer.instance.getUserImage(self.userId!) {
			(imageData) in

			if imageData != nil {
				if let image =  UIImage(data: imageData!) {
					self.userAvatarImage = image
					imageData!.writeToFile(self.pathForUserAvatarImage(), atomically: true)
					NSNotificationCenter.defaultCenter().postNotificationName(kUserProfileDidChangeNotificationName, object: nil)
				}
			}
		}
	}
}
