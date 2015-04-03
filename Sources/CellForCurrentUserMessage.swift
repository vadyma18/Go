
import UIKit

class CellForCurrentUserMessage: UITableViewCell
{
    @IBOutlet private weak var _dateLabel: UILabel!
    @IBOutlet private weak var _textView: UITextView!

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
