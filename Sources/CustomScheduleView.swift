
import UIKit

class CustomScheduleView: UIView {

    private var checkBoxs = Array<CheckBox>()
    private var dayNames: [String] = ["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"]
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
        for i in 0...3{
            checkBoxs.append(CheckBox(frame:CGRectMake(10, CGFloat(i * 30), 20, 20)))
            self.addSubview(self.checkBoxs[i])
            var dayLabel:UILabel = UILabel(frame:CGRectMake(50, CGFloat(i * 30), 90, 20))
            dayLabel.text = dayNames[i]
            dayLabel.textColor = UIColor.blackColor()
            self.addSubview(dayLabel)
        }
        for i in 4...6{
            checkBoxs.append(CheckBox(frame:CGRectMake(150, CGFloat((i - 4) * 30), 20, 20)))
            self.addSubview(self.checkBoxs[i])
            var dayLabel:UILabel = UILabel(frame:CGRectMake(190, CGFloat((i - 4) * 30), 90, 20))
            dayLabel.text = dayNames[i]
            dayLabel.textColor = UIColor.blackColor()
            self.addSubview(dayLabel)
        }
    }
    func days() -> Int{
        var days = 0
        for (index, value) in enumerate(checkBoxs) {
            if (value.selected) { days += 0x1<<index }
        }
        return days
    }
    
    func daysOnCheckBox(days:Int){
        for i in 0...checkBoxs.count{
            if days & 0x1<<i != 0 {
                checkBoxs[i].selected = true
            }
        }

    }
    

}
