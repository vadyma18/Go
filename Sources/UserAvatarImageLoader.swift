
import UIKit

let kUserAvatarImagesDirectory = "UserAvatarImages"

class PendingOperations {
    lazy var downloadsInProgress = [NSIndexPath:NSOperation]()
    lazy var downloadQueue:NSOperationQueue = {
        var queue = NSOperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.name = "Downloading Queue"
        return queue
        }()
    
    lazy var scalingInProgress = [NSIndexPath:NSOperation]()
    lazy var scalingQueue:NSOperationQueue = {
        var queue = NSOperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.name = "Image Scaling Queue"
        return queue
        }()
}

enum AvatarState
{
    case Placeholder, LoadedFromCache, LoadedFromServer, ScaledAndSaved, Failed
}

class Avatar
{
    let name : String!
    let userId : String
    lazy var image : UIImage = UIImage()
    lazy var state = AvatarState.Placeholder

    init(userId: String, imageId: String)
    {
        if userId != ""
        {
            self.userId = userId
            let imageNamePrefix = "\(userId)_"
            var fileName = imageNamePrefix.stringByAppendingString("\(imageId)")
            self.name = pathForUserImages().stringByAppendingPathComponent(fileName)
        }
        else
        {
            self.name = "person"
            self.userId = userId
        }
    }
    
    private func createIfNeededImagesDirectory()
    {
        var fileManager = NSFileManager.defaultManager()
        var path : String = pathForUserImages()
        if !fileManager.fileExistsAtPath(path)
        {
            fileManager.createDirectoryAtPath(path, withIntermediateDirectories: true, attributes: nil, error: nil)
        }
    }
    
    private func predefineImageAvatar() -> UIImage
    {
        return UIImage(named: "person")!
    }

    func pathForUserImages() -> String
    {
        return cacheDirectory.stringByAppendingPathComponent(kUserAvatarImagesDirectory)
    }
}

class ImageLoader : NSOperation
{
    var avatar : Avatar
    init(avatar:Avatar)
    {
        self.avatar = avatar
    }
    override func main()
    {
        if self.cancelled
        {
            return
        }
        if avatar.state == .Placeholder
        {
            if let image = UIImage(contentsOfFile: avatar.name)
            {
                avatar.image = image
                avatar.state = .LoadedFromCache
                return
            }
        }
        if self.cancelled
        {
            return
        }
        if let image = UIImage(data: GoServer.instance.getUserImageSync(avatar.userId))
        {
            avatar.image = image
            avatar.state = .LoadedFromServer
        }
    }
}

class ImageScaler : NSOperation
{
    var avatar : Avatar
    init(avatar:Avatar)
    {
        self.avatar = avatar
    }
    override func main()
    {
        if self.cancelled
        {
            return
        }
        if avatar.state == .LoadedFromServer
        {
            if let image = scaleImage(avatar.image)
            {
                avatar.image = image
                UIImagePNGRepresentation(image).writeToFile(avatar.name, atomically: true)
                avatar.state = .ScaledAndSaved
            }
            else
            {
                avatar.state = .Failed
                return
            }
        }
        if self.cancelled
        {
            return
        }
    }
}

func pathForUserImages() -> String
{
    return cacheDirectory.stringByAppendingPathComponent(kUserAvatarImagesDirectory)
}

extension UIImageView
{
    private func pathForUserImages() -> String
    {
        return cacheDirectory.stringByAppendingPathComponent(kUserAvatarImagesDirectory)
    }
    
    private func createIfNeededImagesDirectory()
    {
        var fileManager = NSFileManager.defaultManager()
        var path : String = self.pathForUserImages()
        if !fileManager.fileExistsAtPath(path)
        {
            fileManager.createDirectoryAtPath(path, withIntermediateDirectories: true, attributes: nil, error: nil)
        }
    }
    
    private func preloadImageData() -> NSData
    {
        return NSData(contentsOfURL: NSBundle.mainBundle().URLForResource("UserAvatarPreloadImage", withExtension: "gif")!)!
    }
    
    private func predefineImageAvatar() -> UIImage
    {
        return UIImage(named: "person")!
    }
    
    func loadImageFrom(userId: String?, imageId: String?)
    {
        if userId != nil
        {
            let fileManager = NSFileManager.defaultManager()
            let imageNamePrefix = "\(userId!)_"
            let fileName : String = imageNamePrefix.stringByAppendingString("\(imageId!)")
            let directoryName = self.pathForUserImages()
            let imagePath = directoryName.stringByAppendingPathComponent(fileName)
            self.image = UIImage.animatedImageWithData(self.preloadImageData())
            if fileManager.fileExistsAtPath(imagePath)
            {
                self.image = UIImage(contentsOfFile: imagePath)
            }
            else
            {
                self.createIfNeededImagesDirectory()
                var cacheDirectoryContent = fileManager.contentsOfDirectoryAtPath(directoryName, error: nil)
                for imageName in cacheDirectoryContent!
                {
                    if (imageName as NSString).hasPrefix(imageNamePrefix)
                    {
                        fileManager.removeItemAtPath(directoryName.stringByAppendingPathComponent(imageName as NSString), error: nil)
                        break
                    }
                }
                
                GoServer.instance.getUserImage(userId!)
                    {
                        (imageData) in
                        var imageHasBeenLoaded : Bool = false
                        if imageData != nil
                        {
                            if let newImage = UIImage(data: imageData!)
                            {
                                //check image size in bytes
                                if imageData!.length > 3000000
                                {
                                    if let img = UIImage(named: "person")
                                    {
                                        self.image = img
                                        UIImagePNGRepresentation(img).writeToFile(imagePath, atomically: true)
                                    }
                                }
                                else
                                {
                                    self.image = scaleImage(newImage)
                                    self.createIfNeededImagesDirectory()
                                    imageData?.writeToFile(imagePath, atomically: true)
                                }
                                imageHasBeenLoaded = true
                            }
                        }
                        
                        if !imageHasBeenLoaded
                        {
                            self.image = self.predefineImageAvatar()
                        }
                }
            }
        }
        else
        {
            self.image = self.predefineImageAvatar()
        }
    }
}