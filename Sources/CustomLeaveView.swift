
import UIKit
var intervalText: [String] = ["Right on time","In a 10 min window","In a 15 min window","In a 30 min window"]
var intervals: [Int] = [0, 10, 15, 30]

class CustomLeaveView: UIView {
    
    
    private var checkBoxs = Array<CheckBox>()
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
        for i in 0...3 {
            checkBoxs.append(CheckBox(frame:CGRectMake(10, CGFloat(i * 30), 20, 20)))
            self.addSubview(checkBoxs[i])
            var intervalLabel:UILabel = UILabel(frame:CGRectMake(50, CGFloat(i * 30), 150, 20))
            intervalLabel.text = intervalText[i]
            intervalLabel.textColor = UIColor.blackColor()
            self.addSubview(intervalLabel)
        }
    }
    func selectedInterval() -> Int{
        for (index, value) in enumerate(checkBoxs){
            if value.selected { return intervals[index]}
        }
        return 0
    }
    func intervalOnCheckBox(interval: Int){
        for (index, value) in enumerate(intervals){
            if (interval == value) {checkBoxs[index].selected = true; return}
        }
    }
}
