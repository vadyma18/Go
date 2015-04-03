
import Foundation

class MapInfoViewController: UIViewController {
    
    private var segueId : String!
    var segueName : String?
    var route : Route!
    var currentPath : GMSPolyline = GMSPolyline()
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var mapView: GMSMapView!
    
    
    override func viewDidLoad() {
        segueId = self.segueName ?? "backToPassRoute"
        fromLabel.text = route.from
        toLabel.text = route.to
        createRouteOnMapView(checkPoints: route.checkPoints!, mapView: mapView, currentPath: currentPath, optimizeWaypoints: true, withEdgeInsets: true)
    }
    
    @IBAction func goBack (sender: AnyObject) {
        self.performSegueWithIdentifier(self.segueId, sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if self.segueId == "backToPassRoute" {
            let routePassengerViewController = segue.destinationViewController as? RoutePassengerPreviewViewController
            routePassengerViewController?.route = self.route
        } else if self.segueId == "RouteDriverPreview" {
            let routeDriverPreviewTableView = segue.destinationViewController as? RouteDriverPreviewTableView
            routeDriverPreviewTableView?.route = self.route
        }
    }
}