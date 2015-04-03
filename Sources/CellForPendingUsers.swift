
import UIKit

protocol CellForPendingUsersDelegate {
    func deletePendingUserAction(sender: AnyObject)
    func acceptPendingUserAction(sender: AnyObject)
    func callPendingUserAction(sender: AnyObject)
}

class CellForPendingUsers: SwipableCell {
    var delegatePending = CellForPendingUsersDelegate?()
    var index: Int?

    
    
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet private weak var userNameLabel: UILabel!
    @IBOutlet weak var callUserPendingUserButton: UIButton!
    @IBOutlet weak var approveUserPendingUserButton: UIButton!
    @IBOutlet weak var deleteUserPendingUserButton: UIButton!
    
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var theRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var theLeftConstraint: NSLayoutConstraint!


    
    
    @IBAction func onCall(sender: UIButton) {
        self.delegatePending?.callPendingUserAction(self)
    }
    @IBAction func onAccept(sender: AnyObject) {
        self.delegatePending?.acceptPendingUserAction(self)
    }
    @IBAction func onDelete(sender: AnyObject) {
        self.delegatePending?.deletePendingUserAction(self)
    }


  
    override func awakeFromNib() {
        super.awakeFromNib()
        
        panGesture = UIPanGestureRecognizer(target: self, action: "panCell:")
        panGesture!.delegate = self
        self.view?.addGestureRecognizer(self.panGesture!)
        
        self.allButtons = [deleteUserPendingUserButton, approveUserPendingUserButton, callUserPendingUserButton]
        self.viewOfContents = self.view
        self.leftConstraint = self.theLeftConstraint
        self.rightConstraint = self.theRightConstraint
        userAvatar.layer.borderWidth = 1
        userAvatar.layer.borderColor = UIColor.grayColor().CGColor
        self.selectionStyle = UITableViewCellSelectionStyle.None

        // Initialization code
    }

    var userNameString : NSString
        {
        get {
            return userNameLabel.text!
        }
        set
        {
            userNameLabel!.text = newValue
        }
    }
}



