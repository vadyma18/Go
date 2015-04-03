
import UIKit

class CustomCell: UITableViewCell {

	@IBOutlet private weak var _departureTimeLabel: UILabel!
	@IBOutlet private weak var _fromLabel: UILabel!
	@IBOutlet private weak var _toLabel: UILabel!
	@IBOutlet private weak var _seatsCountLabel: UILabel!
	@IBOutlet weak var _avatarImageView: UIImageView!
    @IBOutlet private weak var _driverNameLabel: UILabel!
    @IBOutlet private weak var _contentView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        _contentView.layer.borderColor = UIColor(red: 0.862745, green: 0.862745, blue: 0.890196, alpha: 1).CGColor
        _contentView.layer.borderWidth = 1
        self.selectionStyle = UITableViewCellSelectionStyle.None
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

	var fromAdressString : NSString
		{
		get {
			return _fromLabel.text!
		}
		set
		{
			_fromLabel!.text = newValue
		}
	}

	var toAdressString : NSString
		{
		get {
			return _toLabel.text!
		}
		set
		{
			_toLabel!.text = newValue
		}
	}
	
	var seatCountString : Int?
		{
		get {
			return nil
		}
		set
		{
            if newValue == 0
            {
                _seatsCountLabel.backgroundColor = UIColor.redColor()
                _avatarImageView.layer.borderColor = UIColor.redColor().CGColor
                _avatarImageView.layer.borderWidth = 1
            }
            else {
                _seatsCountLabel.backgroundColor = UIColor(red: 0.262745, green: 0.843137, blue: 0.321569, alpha: 1)
                _avatarImageView.layer.borderColor = UIColor(red: 0.262745, green: 0.843137, blue: 0.321569, alpha: 1).CGColor
                _avatarImageView.layer.borderWidth = 1
            }
			_seatsCountLabel!.text = "\(newValue!)"
		}
	}
	
	var departureTime : NSDate?
		{
		get {
			return nil
		}
		set {
			_departureTimeLabel!.text = NSDate.routeTimeFormater.stringFromDate(newValue!)
		}
	}
    
    var driverName: String?
        {
        get {
            return nil
        }
        set {
            _driverNameLabel.text = newValue
        }
    }
    
}
