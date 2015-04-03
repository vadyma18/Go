
import UIKit

class CheckBox: UIButton {
    
    func loadResources()
    {
        self.setImage(UIImage(named: "checkbox-unchecked") as UIImage?, forState: UIControlState.Normal)
        self.setImage(UIImage(named: "checkbox-checked") as UIImage?, forState: UIControlState.Selected)
        self.setImage(UIImage(named: "checkbox-checked") as UIImage?, forState: UIControlState.Highlighted)
        
        self.addTarget(self, action: "checkBoxCkliked:", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.loadResources()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.loadResources()
    }
    
    func checkBoxCkliked(sender: UIButton){
        self.selected = !self.selected
        self.sendActionsForControlEvents(UIControlEvents.ValueChanged)
    }
}
