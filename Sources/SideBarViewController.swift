
import UIKit

let sideBarInfoCellIdentifier : NSString = "sideBarCell"

class SidebarViewController: NSObject, UITableViewDelegate, UITableViewDataSource
{
    private var segmentedControl : UISegmentedControl!
    private var tableViewInfo    : UITableView!
    private var avatarImageView  : UIImageView!
    private var nickNameLabel    : UILabel!
    private var userNameLabel    : UILabel!
    private var view             : UIView!
    
    init(segmentedControl: UISegmentedControl, tableView: UITableView, avatarImageView: UIImageView, nickNameLabel: UILabel, userNameLabel: UILabel, view: UIView)
    {
        super.init()
        
        self.segmentedControl = segmentedControl
        self.tableViewInfo    = tableView
        self.avatarImageView  = avatarImageView
        self.nickNameLabel    = nickNameLabel
        self.userNameLabel    = userNameLabel
        self.view             = view
        
        tableViewInfo.delegate = self
        tableViewInfo.dataSource = self
        
        self.updateUserInfo(nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateUserInfo:", name: kUserProfileDidChangeNotificationName, object: nil)
    }

	deinit
    {
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
    
	func updateUserInfo(notification : AnyObject?)
    {
		avatarImageView.image = UserProfile.currentUserProfile().userAvatarImage
		nickNameLabel.text = UserProfile.currentUserProfile().userNickName
		userNameLabel.text = UserProfile.currentUserProfile().name + " " + UserProfile.currentUserProfile().surname

		if nickNameLabel.text!.isEmpty
        {
			nickNameLabel.text = "Your NickName"
		}

		if countElements(userNameLabel.text!) <= 1
        {
			userNameLabel.text = "Your Name"
		}
	}
    
    func isDriverMode() -> Bool
    {
        return segmentedControl.selectedSegmentIndex == 0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        var identifier : NSString = "ActiveRoutes"
        if indexPath.row == 0 && self.isDriverMode() {
            identifier = "DriverRoutes"
        }
        else if indexPath.row == 1 {
            // segueIdentifier = self.isDriverMode() ? "CreateRoute" : "FindRoutes"
            identifier = self.isDriverMode() ? "CreateRoute" : "ActiveRoutes"
        }
        else if indexPath.row == 2 {
            // segueIdentifier = "MyBlackLick"
            identifier = "ActiveRoutes"
        }
        performSegueWithControllerIdentifier(identifier)
    }
    
    func performSegueWithControllerIdentifier(identifier: NSString)
    {
        var storyboard = UIStoryboard(name: "Main", bundle: nil)
        var vc:UIViewController = storyboard.instantiateViewControllerWithIdentifier(identifier) as UIViewController
        rootNavigationController?.pushViewController(vc, animated: true)
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50;
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell = tableView.dequeueReusableCellWithIdentifier(sideBarInfoCellIdentifier) as? UITableViewCell
        
        if cell == nil
        {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: sideBarInfoCellIdentifier)
        }

        if indexPath.row == 0
        {
            cell?.textLabel!.text = self.isDriverMode() ? "My Routes" : "Active Routes"
            cell?.imageView!.image = UIImage(named: "routesicon.png")
        }
        else
        {
            if self.isDriverMode()
            {
                cell?.textLabel!.text = "Create a route"
                cell?.imageView!.image = UIImage(named: "createRouteIcon.png")
            }
        }
        //not used yet
//        else if indexPath.row == 1
//        {
//            cell?.textLabel!.text = self.isDriverMode() ? "Create a route" : "Find a route"
//            cell?.imageView!.image = UIImage(named: self.isDriverMode() ? "menu.png" : "menu.png")
//        }
//        else
//        {
//            cell?.textLabel!.text = "Black List"
//            cell?.imageView!.image = UIImage(named: "menu.png")
//        }

        cell?.textLabel!.textColor = UIColor.whiteColor()
        cell?.backgroundColor  = UIColor.clearColor()

        var sbgView = UIView()
        sbgView.backgroundColor = UIColor.clearColor()
        cell?.selectedBackgroundView = sbgView

        return cell!
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return ""
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        //with unused fields = 3
        if self.isDriverMode()
        {
            return 2
        }
        else
        {
            return 1
        }
    }
}
