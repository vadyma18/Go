
import UIKit

class CustomTimeView: UIView {

    var datePicker: UIDatePicker?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.loadContent()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.loadContent()
    }
    
    private func loadContent()
    {
        self.datePicker = UIDatePicker(frame: CGRectMake(-10, -47, 50, 50))
        self.datePicker!.datePickerMode = UIDatePickerMode.Time
        self.addSubview(self.datePicker!)
    }
}
