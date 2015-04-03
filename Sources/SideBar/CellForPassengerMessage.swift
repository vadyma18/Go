
import UIKit

class CellForPassengerMessage: UITableViewCell
{
    @IBOutlet private weak var _nickNameLabel: UILabel!
    @IBOutlet private weak var _dateLabel: UILabel!
    @IBOutlet private weak var _textView: UITextView!
    @IBOutlet private weak var _avatarImageView: UIImageView!
    
    var avatarImageView: UIImageView
    {
        get
        {
            return _avatarImageView
        }
    }
    
    var nickName: NSString?
    {
        get
        {
            return nil
        }
        set
        {
            _nickNameLabel.text = newValue
        }
    }
    
    var date: NSDate?
    {
        get
        {
            return nil
        }
        set
        {
            _dateLabel.text = NSDate.routeDateFormater.stringFromDate(newValue!)
        }
    }
    
    var textForMessage: NSString?
    {
        get
        {
            return nil
        }
        set
        {
            _textView.text = newValue
        }
    }
}
