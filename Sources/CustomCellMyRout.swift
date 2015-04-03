
import UIKit

class CustomCellMyRout: UITableViewCell {
    @IBOutlet weak var pendingsLabel: UILabel!
    @IBOutlet weak var seatsLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var view: UIView!
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        view.layer.borderColor = UIColor(red: 0.862745, green: 0.862745, blue: 0.890196, alpha: 1).CGColor
    }

    var fromAdressString : NSString
        {
        get {
            return self.fromLabel.text!
        }
        set
        {
            self.fromLabel!.text = newValue
        }
    }
    
    var toAdressString : NSString
        {
        get {
            return toLabel.text!
        }
        set
        {
            self.toLabel!.text = newValue
        }
    }
    
    var pendingsCount : Int?
        {
        get
        {
            return self.pendingsLabel.text?.toInt()
        }
        set
        {
            if newValue > 0
            {
                pendingsLabel.hidden = false
                pendingsLabel.backgroundColor = UIColor.redColor()
                pendingsLabel.text = String(newValue!)
            }
            else
            {
                pendingsLabel.text = String(newValue!)
                pendingsLabel.hidden = true
            }
        }
    }
    
    var seatsCount : Int?
        {
        get {
            return self.seatsLabel.text?.toInt()
        }
        set
        {
            self.seatsLabel.backgroundColor =  UIColor(red: 0.262745, green: 0.843137, blue: 0.321569, alpha: 1)
            self.seatsLabel!.text = String(newValue!)
            if newValue == 0 {
                self.seatsLabel.backgroundColor =  UIColor.redColor()
            }
        }
    }

    var time : NSDate?
        {
        get {
            return nil
        }
        set {
            var df = NSDateFormatter()
            df.dateFormat = "HH:mm"
            self.timeLabel!.text = df.stringFromDate(newValue!)
        }
    }
}
