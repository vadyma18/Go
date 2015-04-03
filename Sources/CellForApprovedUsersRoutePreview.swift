
import UIKit

protocol CellForApprovedUsersRoutePreviewDelegate {
    func deleteApprovedUserAction(sender: AnyObject)
    func callApprovedUserAction(sender: AnyObject)
}

class CellForApprovedUsersRoutePreview: SwipableCell {
    var delegatePending = CellForApprovedUsersRoutePreviewDelegate?()
    var index: Int?

    
    @IBOutlet private weak var userNameLabel: UILabel!
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var callUserApprovedUserButton: UIButton!
    @IBOutlet private weak var deleteUserApprovedUserButton: UIButton!
    
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var theRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var theLeftConstraint: NSLayoutConstraint!
    
    @IBAction func onCall(sender: UIButton) {
        self.delegatePending?.callApprovedUserAction(self)

    }

    @IBAction func onDelete(sender: UIButton) {
        self.delegatePending?.deleteApprovedUserAction(self)

    }

    override func awakeFromNib() {
        super.awakeFromNib()
        panGesture = UIPanGestureRecognizer(target: self, action: "panCell:")
        panGesture!.delegate = self
        self.view?.addGestureRecognizer(self.panGesture!)
        
        self.allButtons = [deleteUserApprovedUserButton, callUserApprovedUserButton]
        self.viewOfContents = self.view
        self.leftConstraint = self.theLeftConstraint
        self.rightConstraint = self.theRightConstraint
        userAvatar.layer.borderWidth = 1
        userAvatar.layer.borderColor = UIColor.grayColor().CGColor
        self.selectionStyle = UITableViewCellSelectionStyle.None
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
