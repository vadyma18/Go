
import UIKit

class CellForApprovedUsers: UITableViewCell {
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userAvatar: UIImageView!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
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
