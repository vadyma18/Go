
import UIKit

class AdditionalInfoRouteViewController: UIViewController, UIAlertViewDelegate
{
    private var isSearch = false
    var route: Route?
    var pageMode : PageMode = PageMode.create
    private var intervalIndex = 0
    lazy var searchResults = NSMutableArray()
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var processIndicatorView: UIView!
    @IBOutlet var CheckBoxCollection: [CheckBox]!
    @IBOutlet var ButtonCollection: [UIButton]!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var seatsCountLabel: UILabel!
    @IBOutlet weak var seatTextLabel: UILabel!
    @IBOutlet weak var intervalLabel: UILabel!
    @IBOutlet weak var processIndicator: UIActivityIndicatorView!
    @IBOutlet weak var barButtonCreateRoute: UIBarButtonItem!
    @IBOutlet weak var barButtonBack: UIBarButtonItem!
    
    let countOfIntervals = 4
    let maxCountOfSeats = 10
    
    private var _countSeats = 3
    var countSeats: Int
    {
        get
        {
            return _countSeats
        }
        set
        {
            _countSeats = newValue
            seatsCountLabel.text = String(_countSeats)
            if _countSeats == 1
            {
                seatTextLabel.text = "SEAT"
            }
            else if _countSeats == 10 || _countSeats == 2
            {
                seatTextLabel.text = "SEATS"
            }
        }
    }
    
    @IBAction func plusSeat(sender: UIButton)
    {
        countSeats = (countSeats % maxCountOfSeats) + 1
    }
    
    @IBAction func minusSeat(sender: UIButton)
    {
        if _countSeats > 1
        {
            countSeats--
        }
        else
        {
            countSeats = maxCountOfSeats
        }
    }
    
    @IBAction func nextInterval(sender: UIButton)
    {
        intervalIndex = (intervalIndex + 1) % countOfIntervals
        intervalLabel.text = interval[intervalIndex]
    }
    
    @IBAction func previousInterval(sender: UIButton)
    {
        if (intervalIndex > 0)
        {
            intervalIndex--
        }
        else
        {
            intervalIndex = countOfIntervals + (intervalIndex - 1)
        }
        intervalLabel.text = interval[intervalIndex]
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
        intervalLabel.text = interval[intervalIndex]
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        if let _route: Route = route
        {
            setCheckBoxsForDays(_route.schedule!.days ?? 0)
            intervalLabel.text = textForInterval(_route.schedule!.dalayInterval)
            countSeats = _route.numberOfSeats ?? 1
            timePicker.setDate(_route.schedule?.date ?? NSDate(), animated: false)
        }
        title = defineTitleForPageMode(pageMode)
    }
   
    @IBAction func saveRoute(sender: AnyObject)
    {
        route?.schedule?.days = daysFromCheckBoxs()
        route?.schedule?.date = timePicker.date
        route?.schedule?.dalayInterval = intervalFromText(intervalLabel.text! ?? "")
        route?.numberOfSeats = countSeats
        
        self.enabledControl(false)
        processIndicator.startAnimating()
        switch pageMode
        {
        case PageMode.create :
            GoServer.instance.createRide(route!, handler:
            {
                (code, result) in
                self.enabledControl(true)
                self.processIndicator.stopAnimating()
                if code == .OK
                {
                    self.performSegueToDriverRoutes()
                }
                else if code == .ConnectionError
                {
                    self.showAlertView("Could not connect to server!!!")
                }
                else
                {
                    self.showAlertView("Invalid route!!!")
                }            
            })
            break
        case PageMode.edit :
            GoServer.instance.changeRide(route!, handler:
            {
                (code) in
                self.enabledControl(true)
                self.processIndicator.stopAnimating()
                if code == .OK
                {
                    self.performSegueToDriverRoutes()
                }
                else if code == .ConnectionError
                {
                    self.showAlertView("Could not connect to server!!!")
                }
                else
                {
                    self.showAlertView("Invalid route!!!")
                }            
            })
            break
        case PageMode.find :
            GoServer.instance.findRides(route!, handler:
            {
                (code, routes, driversInfo) in
                self.enabledControl(true)
                self.processIndicator.stopAnimating()
                if code == .OK
                {
                    self.performUnwindSegueToSearchResults(routes, driversInfo: driversInfo)
                }
                else if code == .ConnectionError
                {
                    self.showAlertView("Could not connect to server!!!")
                }
                else
                {
                    self.showAlertView("Invalid route!!!")
                }
            })
            break

        default : break
        }
    }
    
    private func performSegueToDriverRoutes()
    {
        var storyboard = UIStoryboard(name: "Main", bundle: nil)
        var vc:UIViewController = storyboard.instantiateViewControllerWithIdentifier("DriverRoutes") as UIViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func performUnwindSegueToSearchResults(searchResults: NSMutableArray, driversInfo: NSMutableDictionary)
    {
        var storyboard = UIStoryboard(name: "Main", bundle: nil)
        var vc:RoutesController = storyboard.instantiateViewControllerWithIdentifier("ActiveRoutes") as RoutesController
        vc.pageMode = PageMode.find
        vc.searchResults = searchResults
        vc.driversInfo = driversInfo
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func enabledControl(value: Bool)
    {
        barButtonBack.enabled = value
        barButtonCreateRoute.enabled = value
        for i in 0...6
        {
            CheckBoxCollection[i].enabled = value
        }
        timePicker.enabled = value
        seatsCountLabel.enabled = value
        seatTextLabel.enabled = value
        intervalLabel.enabled = value
        for i in 0...3
        {
            ButtonCollection[i].enabled = value
        }

    }
    
    func textForInterval(_interval: Int) -> String
    {
        for (index, value) in enumerate(intervals)
        {
            if (value == _interval)
            {
                intervalIndex = index
                return interval[index]
            }
        }
        return ""
    }
    func intervalFromText(leave: NSString) -> Int
    {
        for (index, value) in enumerate(interval)
        {
            if leave == value { return intervals[index] }
        }
        return 0
    }
    
    func daysFromCheckBoxs() -> Int
    {
        var days = 0
        for i in 0...6 {
            if CheckBoxCollection[i].selected
            {
                days += 0x1<<i
            }
        }
        return days
    }
    
    func setCheckBoxsForDays(days : Int)
    {
        for i in 0...6{
            if days & 0x1<<i != 0 {
                CheckBoxCollection[i].selected = true;
            }
        }
    }
    
    func showAlertView(massage: String)
    {
        var alert: UIAlertView = UIAlertView(title: "Error", message: massage, delegate: self, cancelButtonTitle: "OK")
        alert.show()
    }
}
