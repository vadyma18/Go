
import UIKit



class CellForRoutePreview: UITableViewCell {
    
    @IBOutlet private weak var timeLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var seatsLabel: UILabel!
    @IBOutlet private weak var fromLabel: UILabel!
    @IBOutlet private weak var toLabel: UILabel!
    @IBOutlet weak var mapView: GMSMapView!
    
    @IBOutlet weak var mapInfoView: UIView!
    

    
    override func awakeFromNib() {
        super.awakeFromNib()        
        self.selectionStyle = UITableViewCellSelectionStyle.None
        // Initialization code
    }
   
    var timeLabelString: NSDate? {
        get {
            return nil
        }
        set
        {
            var df = NSDateFormatter()
            df.dateFormat = "HH:mm"
            timeLabel!.text = df.stringFromDate(newValue!)
        }
    }
    
    var dateLabelString: NSDate? {
        get {
            return nil
        }
        set
        {
            var df = NSDateFormatter()
            df.dateFormat = "dd MMMM"
            dateLabel!.text = df.stringFromDate(newValue!).uppercaseString
        }
    }

    var dateLabelStringFromSchedule: Schedule? {
        get {
            return nil
        }
        set
        {
            let scheduleDateType = newValue!.getScheduleTimeType()
            dateLabel!.text = nameForSectionWithIndex(scheduleDateType.type).uppercaseString
        }
    }
    
    var seatsCount: Int {
        get {
            return 0
        }
        set
        {
			var backgroundColor : UIColor = UIColor(red: 0.262745, green: 0.843137, blue: 0.321569, alpha: 1)
			if newValue == 0 {
				backgroundColor =  UIColor.redColor()
			}
			seatsLabel.backgroundColor = backgroundColor
			seatsLabel!.text = "\(newValue)"
        }
    }

    var fromLabelString: NSString {
        get {
            return fromLabel.text!
        }
        set
        {
            fromLabel!.text = newValue
        }
    }
    
    var toLabelString: NSString {
        get {
            return toLabel.text!
        }
        set
        {
            toLabel!.text = newValue
        }
    }
}
