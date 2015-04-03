
import UIKit

class RoutesSearchController: UITableViewController, UIGestureRecognizerDelegate, UIAlertViewDelegate, UITextFieldDelegate {
    @IBOutlet weak var fromMapPoint: UITextField!
    @IBOutlet weak var toMapPoint: UITextField!
    @IBOutlet weak var numberOfSeatsLabel: UILabel!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var timeTextField: UITextField!
    @IBOutlet weak var onTimeTextField: UITextField!
    
    var from : String?
    var to : String?
    var numberOfSeats : Int = 1
    var time : NSDate?
    var date : NSDate?
    var checkPoints: NSMutableArray?
    
    @IBAction func dateAction(sender: AnyObject) {
        var accessoryView:CustomDateView = CustomDateView(frame: CGRectMake(0, 0, 500, 500))
        self.createAlertViewWithAccessoryView(accessoryView, withTitle: "Set Date")
    }
    var routes: NSArray?
    
    @IBAction func timeAction(sender: AnyObject) {
        var accessoryView:CustomTimeView = CustomTimeView(frame: CGRectMake(0, 0, 500, 500))
        self.createAlertViewWithAccessoryView(accessoryView, withTitle: "Set Time")
    }
    
    @IBAction func iWillLeaveAction(sender: AnyObject) {
        var accessoryView:CustomLeaveView = CustomLeaveView(frame: CGRectMake(0, 0, 300, 300))
        self.createAlertViewWithAccessoryView(accessoryView, withTitle: "I will leave")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        routes = StubGoServer.instance.getStubRoutes()

        // Do any additional setup after loading the view.
    }
    
//    //disable textField editing
//    func textFieldShouldBeginEditing(textField: UITextField!) -> Bool {
//        if textField == fromMapPoint || textField == toMapPoint {
//            return true
//        } else {
//            return true
//        }
//    }
    
    //hides keyboard when 'return' key pressed
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    
    func findRoute() -> NSMutableArray
    {
        
        var result: NSMutableArray = NSMutableArray()
        //TODO finish search
        for index in self.routes!
        {
            let myRoute : Route = Route(routeRepresentation: index as NSDictionary)
            var isFromTrue = false
            var isToTrue = false
            var isTimeTrue = false
            var isDateTrue = false
            var isSeatsTrue = false
            if let tempFrom = self.from {
                if tempFrom == myRoute.from {
                    //TODO with checkpoints
                    isFromTrue = true
                }
            } else {
                isFromTrue = true
            }
            
            if let tempTo = self.to {
                if tempTo == myRoute.to {
                    //TODO with checkpoints
                    isToTrue = true
                }
            } else {
                isToTrue = true
            }
            
            if let tempDate = self.date {
                if tempDate == myRoute.schedule?.date {
                    isDateTrue = true
                }
            } else {
                isDateTrue = true
            }
            
            if self.numberOfSeats == myRoute.numberOfSeats {
                isSeatsTrue = true
            }
            
            if isFromTrue && isToTrue && isTimeTrue && isDateTrue && isSeatsTrue {
                result.addObject(index)
            }
        }
        return result
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func minusSeatButton(sender: AnyObject) {
        if self.numberOfSeats > 1 && self.numberOfSeats <= 6  {
            self.numberOfSeatsLabel.text = "\(--numberOfSeats)"
        }
    }
    @IBAction func plusSeatButton(sender: AnyObject) {
        if self.numberOfSeats >= 1 && self.numberOfSeats < 6 {
            self.numberOfSeatsLabel.text = "\(++numberOfSeats)"
        }
    }

//    @IBAction func letsGoBarButton(sender: AnyObject) {
//        
//    }
    //
    
    // MARK: - Navigation
    //TODO send data to server
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var searchResults = self.findRoute()
        
        self.view.endEditing(true)
    }
    
    func createAlertViewWithAccessoryView(accessoryView: UIView, withTitle title: String){
        var myAlert : UIAlertView = UIAlertView(frame: CGRectMake(0, 0, 1000, 1000))
//        myAlert.delegate = self
        myAlert.title = title
        myAlert.addButtonWithTitle("Done")
        myAlert.setValue(accessoryView, forKey: "accessoryView")
        myAlert.show()
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
//    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer,
//        shouldRequireFailureOfGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//            return false
//    }
}
