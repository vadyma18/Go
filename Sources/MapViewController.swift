
import Foundation

class MapViewController : UIViewController, GMSMapViewDelegate, UISearchBarDelegate, CLLocationManagerDelegate, UISearchDisplayDelegate, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate
{
    @IBOutlet var sidebarButton : UIBarButtonItem!
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var fromTextField: UISearchBar!
    @IBOutlet weak var toTextField: UISearchBar!
    @IBOutlet var okTapGestureRegognize: UIBarButtonItem!
    @IBOutlet weak var processIndicator: UIActivityIndicatorView!

    //vars for searchBar manipulations
    @IBOutlet weak var toSearchBarTopConstraint: NSLayoutConstraint!
    private var searchFromDisplay: UISearchDisplayController?
    private var searchToDisplay: UISearchDisplayController?
    private lazy var searchResults = NSMutableArray()
    private lazy var constantForToSearchBarTopConstraint = CGFloat()
    private lazy var canSendSearchRequest = true
    private lazy var trigerTimerIfTextFieldDidChanged = false
    private lazy var trigerTimerIfTextFieldDidChangedText = ""
    private lazy var fromTextFieldTextForCancelSearch = ""
    private lazy var toTextFieldTextForCancelSearch = ""
    private lazy var searchFromSearchButtonClicked = false //define flow for search button clicked
    private lazy var hasUpdateRouteFromSearchFieldNoError = true //needed because from could not set local variable from closure
    
    private let segueIdentifier = "AdditionalInfoView"
    var firstLocationUpdate_ : Bool = false
    var currentRoutePolyline_ : GMSPolyline = GMSPolyline()
    var route : Route?
    var markers_ : NSMutableArray = []
    var pageMode : PageMode = PageMode.create
    var refreshTask : DispatchHandle?
    
    //For returning marker back when it`s dragged into invalid location
    var previousLocation : CLLocationCoordinate2D!
    
    var readyToSave : Bool
        {
        set
        {
            okTapGestureRegognize.enabled = newValue
        }
        get
        {
            return okTapGestureRegognize.enabled
        }
    }
    func mapView(mapView: GMSMapView!, willMove gesture: Bool) {
        self.view.endEditing(gesture)
    }
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if self.fromTextField.text != "" && self.toTextField.text != "" {
            return true
        } else {
            return false
        }
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == segueIdentifier {
            let aditionalInfoRouteController = segue.destinationViewController as? AdditionalInfoRouteViewController

            aditionalInfoRouteController?.pageMode = pageMode
            if route == nil
            {
                route = Route(checkPoints: markers_, from: self.fromTextField.text, to: self.toTextField.text, path: currentRoutePolyline_.path)
            }
            else
            {
                route?.checkPoints = markers_
                route?.from = fromTextField.text
                route?.to = toTextField.text
                route?.path = currentRoutePolyline_.path
            }
            aditionalInfoRouteController?.route = route
        }
    }
    //TODO check if view reloads
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        title = defineTitleForPageMode(pageMode)
        mapView.addObserver(self, forKeyPath: "myLocation", options: .New, context: nil)
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        mapView.removeObserver(self, forKeyPath: "myLocation")
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        searchFromDisplay = UISearchDisplayController(searchBar: fromTextField!, contentsController: self)
        searchFromDisplay?.delegate = self
        searchFromDisplay?.searchResultsDelegate = self
        searchToDisplay = UISearchDisplayController(searchBar: toTextField!, contentsController: self)
        searchToDisplay?.delegate = self
        searchToDisplay?.searchResultsDelegate = self
        

        navigationController?.setToolbarHidden(true, animated: false)
        sidebarButton.tintColor = UIColor.whiteColor()
        sidebarButton.target = self.navigationController
        sidebarButton.action = "animateViewAppear:"

        readyToSave = false
        mapView.delegate = self
        fromTextField.backgroundImage = UIImage()
        toTextField.backgroundImage = UIImage()
        currentRoutePolyline_.map = mapView
        moveMapCameraToKyivCoordinates()
        // Ask for My Location data after the map has already been added to the UI.
        dispatch_async(dispatch_get_main_queue())
        {
            self.mapView.myLocationEnabled = true
        }
    }
    
    private func moveMapCameraToKyivCoordinates()
    {
        let kyivCoords = CLLocationCoordinate2D(latitude: 50.44179976269, longitude: 30.52024886012)
        mapView.camera = GMSCameraPosition.cameraWithTarget(kyivCoords, zoom: 10)
    }
    
    func clearViewController()
    {
        route = Route()
        fromTextField.text = ""
        toTextField.text = ""
        markers_ = NSMutableArray()
        mapView.clear()
        currentRoutePolyline_ = GMSPolyline()
        currentRoutePolyline_.map = mapView
        moveMapCameraToKyivCoordinates()
    }
    
    override func viewDidAppear(animated: Bool)
    {
        //observe orientation change to update mapView
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "orientationChanged", name: "UIDeviceOrientationDidChangeNotification", object: UIDevice.currentDevice())
        
        if route != nil
        {
            markers_ = route!.checkPoints!
            fromTextField.text = route!.from
            toTextField.text = route!.to
            if markers_.count > 0
            {
                startProcessIndicator()
                for marker in markers_
                {
                    (marker as GMSMarker).map = mapView
                    (marker as GMSMarker).draggable = true
                }
                (markers_.lastObject as GMSMarker).icon = UIImage(named: "destination_marker")
                if markers_.count > 2
                {
                    for i in 1...markers_.count - 1
                    {
                        (markers_[i] as GMSMarker).snippet = "Delete"
                    }
                }
                invalidateRoute()
            }
        }
    }
    
    private func updateSearchDisplayTableViewLayout(searchDisplay: UISearchDisplayController)
    {
        let defaultFrameY = CGFloat(0)
        if (UIDevice.currentDevice().systemVersion as NSString).doubleValue <= 8.0
        {
            return
        }
        else
        {
            if UIDevice.currentDevice().orientation == UIDeviceOrientation.Portrait || UIDevice.currentDevice().orientation == UIDeviceOrientation.PortraitUpsideDown
            {
                searchDisplay.searchResultsTableView?.frame.origin.y = defaultFrameY + 17
            }
            else if UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeLeft || UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeRight
            {
                searchDisplay.searchResultsTableView?.frame.origin.y = defaultFrameY
            }
        }
    }

    func orientationChanged()
    {
        let defaultFrameY = CGFloat(0)
        if !fromTextField.isFirstResponder() && !toTextField.isFirstResponder()
        {
           self.mapView.animateWithCameraUpdate(GMSCameraUpdate.fitBounds(GMSCoordinateBounds(path: self.currentRoutePolyline_.path), withEdgeInsets: UIEdgeInsets(top: 140, left: 30, bottom: 10, right: 30)))
        }
        else if fromTextField.isFirstResponder()
        {
            updateSearchDisplayTableViewLayout(searchFromDisplay!)
        }
        else if toTextField.isFirstResponder()
        {
            updateSearchDisplayTableViewLayout(searchToDisplay!)
        }
    }
    
    func mapView(mapView : GMSMapView, didTapAtCoordinate coordinate: CLLocationCoordinate2D)
    {
        self.view.endEditing(true)
        if markers_.count < 8 {
            startProcessIndicator()
            
            GoogleMapsApi.instance.getFormattedAddressForCoordinates(coordinate) {
                (address) in
                self.stopProcessIndicator()
                
                if address != nil{
                    let newMarker = GMSMarker(position: coordinate)
                    newMarker.draggable = true
                    newMarker.map = mapView
                    newMarker.draggable = true
                    newMarker.appearAnimation = kGMSMarkerAnimationPop
                    if self.markers_.count > 1 {
                        newMarker.snippet = "Delete"
                        self.markers_.insertObject(newMarker, atIndex: 1)
                        self.invalidateRoute()
                    }
                    else {
                        if self.markers_.count == 0 {
                            self.fromTextField.text = address
                            self.resetTextFieldTextForCancelSearch(self.fromTextField)
                        }
                        else {
                            self.toTextField.text = address
                            self.resetTextFieldTextForCancelSearch(self.toTextField)
                            newMarker.icon = UIImage(named: "destination_marker")
                            self.invalidateRoute()
                        }
                        self.markers_.addObject(newMarker)
                    }
                }
            }
        }
    }
    func mapView(mapView: GMSMapView!, didTapInfoWindowOfMarker marker: GMSMarker!) {
        startProcessIndicator()
        markers_.removeObject(marker)
        marker.map = nil
        invalidateRoute()
    }
    func mapView(mapView: GMSMapView!, didBeginDraggingMarker marker: GMSMarker!) {
        previousLocation = marker.position
    }
    func mapView(mapView: GMSMapView!, didEndDraggingMarker marker: GMSMarker!) {
        startProcessIndicator()
        GoogleMapsApi.instance.getFormattedAddressForCoordinates(marker.position) {
            (address) in
            self.stopProcessIndicator()
            if address != nil
            {
                if marker == self.markers_.firstObject as GMSMarker
                {
                    self.fromTextField.text = address
                    self.resetTextFieldTextForCancelSearch(self.fromTextField)
                }
                else if marker==self.markers_.lastObject as GMSMarker
                {
                    self.toTextField.text = address
                    self.resetTextFieldTextForCancelSearch(self.toTextField)
                }
             if self.markers_.count > 1 {self.invalidateRoute()}
            }
            else {
                marker.position = self.previousLocation!
            }
        }
    }
    func invalidateRoute()
    {
        readyToSave = false
        refreshTask?.cancel()
        weak var selfForBlock = self
        refreshTask = dispatch_after_delay(2.0, dispatch_get_main_queue())
        {
            if selfForBlock != nil
            {
                selfForBlock!.refreshRoute()
            }
        }
    }
    func refreshRoute()
    {
        if markers_.count > 1
        {
            startProcessIndicator()
            GoogleMapsApi.instance.getPathForMarkers(markers_, optimizeWaypoints: true)
                {
                    (path) in
                    
                    self.currentRoutePolyline_.path = path
                    self.readyToSave = true
                    self.mapView.animateWithCameraUpdate(GMSCameraUpdate.fitBounds(GMSCoordinateBounds(path: self.currentRoutePolyline_.path), withEdgeInsets: UIEdgeInsets(top: 140, left: 30, bottom: 10, right: 30)))
            }
        }
        else if markers_.count == 1
        {
            self.mapView.animateToCameraPosition(GMSCameraPosition.cameraWithTarget((markers_.firstObject as GMSMarker).position, zoom: 10))
        }
        if fromTextField.isFirstResponder()
        {
            searchFromDisplay?.searchResultsTableView.reloadData()
        }
        else if toTextField.isFirstResponder()
        {
            searchToDisplay?.searchResultsTableView.reloadData()
        }
        self.stopProcessIndicator()
    }
    
    deinit
    {
        //        mapView.removeObserver(self, forKeyPath: "myLocation")
    }

    @IBAction func onCancel(sender: AnyObject?)
    {
        let navController = parentViewController as UINavigationController
        navController.popToRootViewControllerAnimated(true)
        let routeController = navController.viewControllers.first as RoutesController
        routeController.refreshRoutes()
    }
    func mapView(mapView: GMSMapView, didEndDraggingMarker marker:GMSMarker)
    {
        invalidateRoute()
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<()>)
    {
        if (!firstLocationUpdate_)
        {
            // If the first location update has not yet been recieved, then jump to that
            // location.
            firstLocationUpdate_ = true;
            let location = change[NSKeyValueChangeNewKey] as CLLocation
            mapView.camera = GMSCameraPosition.cameraWithTarget(location.coordinate, zoom: 14)
        }
    }
    
    private func startProcessIndicator()
    {
        if !fromTextField.isFirstResponder() && !toTextField.isFirstResponder()
        {
            fromTextField.userInteractionEnabled = false
            toTextField.userInteractionEnabled = false
        }
        self.view.insertSubview(processIndicator, aboveSubview: mapView)
        processIndicator.startAnimating()
        mapView.userInteractionEnabled = false
    }
    
    private func stopProcessIndicator()
    {
        if !fromTextField.isFirstResponder() && !toTextField.isFirstResponder()
        {
            fromTextField.userInteractionEnabled = true
            toTextField.userInteractionEnabled = true
        }
        self.view.insertSubview(self.processIndicator, belowSubview: self.mapView)
        self.processIndicator.stopAnimating()
        self.mapView.userInteractionEnabled = true
    }
    
    private func getCurrentKeyBoardLanguage() -> String
    {
        return textInputMode?.primaryLanguage! ?? "en"
    }
    
    //MARK: autocomplete google search
    func searchGoogleAPI(searchText: String)
    {
        let language = getCurrentKeyBoardLanguage()

        GoogleMapsApi.instance.getSearchResultsForString(searchText, language: language, sensor: "true", handler:
            {
                (places) in
                if let result = places
                {
                    self.searchResults = result
                    if self.fromTextField.isFirstResponder()
                    {
                        self.searchFromDisplay?.searchResultsTableView.reloadData()
                    }
                    else if self.toTextField.isFirstResponder()
                    {
                        self.searchToDisplay?.searchResultsTableView.reloadData()
                    }
                }
        })
    }
    
    //MARK: search autocomplete
//    private func updateRouteFromSearchField(description: String)
    //for searchButton that has address already - add param address
    private func updateRouteFromSearchField(description: String, coordinates: CLLocationCoordinate2D?) -> Bool
    {
        let language = getCurrentKeyBoardLanguage()
        
        // could check for coords not searchFromSearchButtonClicked
        if searchFromSearchButtonClicked
        {
            hasUpdateRouteFromSearchFieldNoError = true
            searchFromSearchButtonClicked = false
            
            if fromTextField.isFirstResponder()
            {
                if coordinates == nil
                {
                    hasUpdateRouteFromSearchFieldNoError = false
                    presentIncorrectAddressErrorAlert(fromTextField)
                }
                else if self.markers_.count == 0
                {
                    hasUpdateRouteFromSearchFieldNoError = true
                    let newMarker = GMSMarker(position: coordinates!)
                    newMarker.draggable = true
                    newMarker.map = self.mapView
                    newMarker.draggable = true
                    newMarker.appearAnimation = kGMSMarkerAnimationPop
                    self.markers_.addObject(newMarker)
                    self.mapView.animateToCameraPosition(GMSCameraPosition.cameraWithTarget(newMarker.position, zoom: 10))
                }
                else
                {
                    hasUpdateRouteFromSearchFieldNoError = true
                    (self.markers_.firstObject as GMSMarker).position = coordinates!
                    self.refreshRoute()
                }
            }
            else if toTextField.isFirstResponder()
            {
                if coordinates == nil
                {
                    hasUpdateRouteFromSearchFieldNoError = false
                    presentIncorrectAddressErrorAlert(toTextField)
                }
                else if self.markers_.count == 1
                {
                    hasUpdateRouteFromSearchFieldNoError = true
                    let newMarker = GMSMarker(position: coordinates!)
                    newMarker.icon = UIImage(named: "destination_marker")
                    newMarker.draggable = true
                    newMarker.map = self.mapView
                    newMarker.draggable = true
                    newMarker.appearAnimation = kGMSMarkerAnimationPop
                    self.markers_.addObject(newMarker)
                    self.refreshRoute()
                }
                else if self.markers_.count > 1
                {
                    hasUpdateRouteFromSearchFieldNoError = true
                    (self.markers_.lastObject as GMSMarker).position = coordinates!
                    self.refreshRoute()
                }
            }
        }
        else
        {
            if fromTextField.isFirstResponder()
            {
                GoogleMapsApi.instance.getCoordinatesForAddress(description, language: language)
                {
                    (coords) in
                    if coords != nil
                    {
                        if self.markers_.count == 0
                        {
                            self.hasUpdateRouteFromSearchFieldNoError = true
                            let newMarker = GMSMarker(position: coords!)
                            newMarker.draggable = true
                            newMarker.map = self.mapView
                            newMarker.draggable = true
                            newMarker.appearAnimation = kGMSMarkerAnimationPop
                            self.markers_.addObject(newMarker)
                            self.mapView.animateToCameraPosition(GMSCameraPosition.cameraWithTarget(newMarker.position, zoom: 10))
                        }
                        else
                        {
                            self.hasUpdateRouteFromSearchFieldNoError = true
                            (self.markers_.firstObject as GMSMarker).position = coords!
                            self.refreshRoute()
                        }
                    }
                    else
                    {
                        self.hasUpdateRouteFromSearchFieldNoError = false
                        self.presentIncorrectAddressErrorAlert(self.fromTextField)
                    }
                }
            }
            else if toTextField.isFirstResponder()
            {
                GoogleMapsApi.instance.getCoordinatesForAddress(description, language: language)
                {
                    (coords) in
                    if coords != nil
                    {
                        if self.markers_.count == 1
                        {
                            self.hasUpdateRouteFromSearchFieldNoError = true
                            let newMarker = GMSMarker(position: coords!)
                            newMarker.icon = UIImage(named: "destination_marker")
                            newMarker.draggable = true
                            newMarker.map = self.mapView
                            newMarker.draggable = true
                            newMarker.appearAnimation = kGMSMarkerAnimationPop
                            self.markers_.addObject(newMarker)
                            self.refreshRoute()
                        }
                        else if self.markers_.count > 1
                        {
                            self.hasUpdateRouteFromSearchFieldNoError = true
                            (self.markers_.lastObject as GMSMarker).position = coords!
                            self.refreshRoute()
                        }
                    }
                    else
                    {
                        self.hasUpdateRouteFromSearchFieldNoError = false
                        self.presentIncorrectAddressErrorAlert(self.toTextField)
                    }
                }
            }
        }
        return hasUpdateRouteFromSearchFieldNoError
    }
    
    //MARK: search TableView
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return searchResults.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 35
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cellId = "Cell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId) as? UITableViewCell
        
        if cell == nil
        {
            cell = UITableViewCell()
        }
        cell?.textLabel?.text = getAddressName(indexPath)
        cell?.textLabel?.font = UIFont(name: "Helvetica", size: CGFloat(14))
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let addressName = getAddressName(indexPath)
        if !addressName.isEmpty
        {
            if searchFromSearchButtonClicked
            {
                if addressName == "Incorrect address name" || addressName == "Nothing found"
                {
                    return
                }
                else
                {
                    if let components = (searchResults.objectAtIndex(indexPath.row) as? NSDictionary)?["geometry"] as? NSDictionary
                    {
                        if let location = components["location"] as? NSDictionary
                        {
                            let coords = CLLocationCoordinate2D(latitude: location["lat"] as Double, longitude: location["lng"] as Double)
                            if updateRouteFromSearchField(addressName, coordinates: coords)
                            {
                                endOnCellSelectedSearchResults(addressName)
                            }
                            stopProcessIndicator()
                        }
                    }
                }
            }
            else
            {
                if addressName == "Nothing found" || addressName == "Too much requests were sent" || addressName == "Request denied" || addressName == "Invalid request"
                {
                    return
                }
                else
                {
                    if updateRouteFromSearchField(addressName, coordinates: nil)
                    {
                        endOnCellSelectedSearchResults(addressName)
                    }
                    stopProcessIndicator()
                }
            }
        }
    }
    
    //MARK: UISearchBar delegate
    //TODO save marker address
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String)
    {
        trigerTimerIfTextFieldDidChanged = true
        searchFromSearchButtonClicked = false
        if searchBar == fromTextField
        {
            trigerTimerIfTextFieldDidChangedText = searchText //check if needed
            searchFromDisplay?.searchResultsDataSource = self
            searchFromDisplay?.searchResultsTableView.alpha = 0.75
            searchFromDisplay?.searchBar.setShowsCancelButton(true, animated: true)
        }
        else if searchBar == toTextField
        {
            trigerTimerIfTextFieldDidChangedText = searchText
            searchToDisplay?.searchResultsDataSource = self
            searchToDisplay?.searchResultsTableView.alpha = 0.75
            searchToDisplay?.searchBar.setShowsCancelButton(true, animated: true)
        }
    }
    
    func searchBarShouldEndEditing(searchBar: UISearchBar) -> Bool
    {
        //check if search display is active
        var fromIsActive = false
        var toIsActive = false
        if let display = searchFromDisplay
        {
            fromIsActive = display.active
        }
        if let display = searchToDisplay
        {
            toIsActive = display.active
        }
        if  fromIsActive || toIsActive
        {
            return false
        }
        else
        {
            return true
        }
    }
    
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool
    {
        if searchBar == fromTextField
        {
            toTextField.hidden = true
            searchFromDisplay?.setActive(true, animated: false)
            searchFromDisplay?.searchResultsTableView.alpha = 0.75
            //
            searchFromDisplay?.searchResultsTableView.bounces = false
        }
        else if searchBar == toTextField
        {
            if fromTextField.text.isEmpty
            {
                self.presentAlert("Write your start address first", message: nil)
                return false
            }
            else
            {
                fromTextField.hidden = true
                constantForToSearchBarTopConstraint = toSearchBarTopConstraint.constant
                toSearchBarTopConstraint.constant = constantForToSearchBarTopConstraint - 36
                searchToDisplay?.setActive(true, animated: false)
                searchToDisplay?.searchResultsTableView.alpha = 0.75
                //
                searchToDisplay?.searchResultsTableView.bounces = false
            }
        }
        return true
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar)
    {
        if searchBar == fromTextField
        {
            toTextField.hidden = false
            searchFromDisplay?.setActive(false, animated: true)
        }
        else if searchBar == toTextField
        {
            fromTextField.hidden = false
            toSearchBarTopConstraint.constant = constantForToSearchBarTopConstraint
            searchToDisplay?.setActive(false, animated: true)
        }
        updateSearchBarText(searchBar)
        searchFromSearchButtonClicked = false
        trigerTimerIfTextFieldDidChanged = false
    }
    
    //MARK: privete utility methods for searchBar
    private func presentIncorrectAddressErrorAlert(searchBar: UISearchBar)
    {
        //TODO check if reload tableView
        if searchBar == fromTextField
        {
            searchBar.text = fromTextFieldTextForCancelSearch
        }
        else if searchBar == toTextField
        {
            searchBar.text = toTextFieldTextForCancelSearch
        }
        
//        resetTextFieldTextForCancelSearch(searchBar)
        presentAlert("Error", message: "Invalid address!")
    }
    
    private func getAddressName(indexPath: NSIndexPath) -> String
    {
        if searchFromSearchButtonClicked
        {
            if searchResults.count > 0
            {
                if let address_components = (searchResults.objectAtIndex(indexPath.row) as? NSDictionary)?["formatted_address"] as? String
                {
                    return address_components
                }
                else
                {
                    return "Incorrect address name"
                }
            }
            else
            {
                return "Nothing found"
            }
        }
        else
        {
            if let status = searchResults.objectAtIndex(0) as? String
            {
                if status == "ZERO_RESULTS"
                {
                    return "Nothing found"
                }
                else if status == "OVER_QUERY_LIMIT"
                {
                    return "Too much requests were sent"
                }
                else if status == "REQUEST_DENIED"
                {
                    return "Request denied"
                }
                if status == "INVALID_REQUEST"
                {
                    return "Invalid request"
                }
            }
            else
            {
                let result = searchResults.objectAtIndex(indexPath.row) as NSDictionary
                let description = result.objectForKey("description") as? String
                return description ?? ""
            }
        }
        return ""
    }

    private func updateSearchBarText(searchBar: UISearchBar)
    {
        if searchBar == fromTextField
        {
            fromTextField.text = fromTextFieldTextForCancelSearch
        }
        else if searchBar == toTextField
        {
            toTextField.text = toTextFieldTextForCancelSearch
        }
    }
    
    //saves address if no errors on search of tap markers
    private func resetTextFieldTextForCancelSearch(searchBar: UISearchBar)
    {
        if searchBar == fromTextField
        {
            fromTextFieldTextForCancelSearch = searchBar.text
        }
        else if searchBar == toTextField
        {
            toTextFieldTextForCancelSearch = searchBar.text
        }
    }
    
    //TODO CHECK
    private func endOnCellSelectedSearchResults(addressName: String)
    {
        if fromTextField.isFirstResponder()
        {
            fromTextField.text = addressName
            resetTextFieldTextForCancelSearch(fromTextField)
            searchBarTextDidEndEditing(fromTextField)
        }
        else if toTextField.isFirstResponder()
        {
            toTextField.text = addressName
            resetTextFieldTextForCancelSearch(toTextField)
            searchBarTextDidEndEditing(toTextField)
        }
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar)
    {
        searchFromSearchButtonClicked = true
        
        let language = getCurrentKeyBoardLanguage()
        if fromTextField.isFirstResponder()
        {
            GoogleMapsApi.instance.getApproximateCoordinatesForAddress(fromTextField.text, language: language)
                {
                    (coords) in
                    
                    self.stopProcessIndicator()
                    if let result = coords
                    {
                        self.searchResults = NSMutableArray(array: result)
                        self.searchFromDisplay?.searchResultsTableView.reloadData()
                    }
                    else
                    {
                        self.searchResults = NSMutableArray()
                        self.searchFromDisplay?.searchResultsTableView.reloadData()
                    }
            }
        }
        else if toTextField.isFirstResponder()
        {
            GoogleMapsApi.instance.getApproximateCoordinatesForAddress(toTextField.text, language: language)
                {
                    (coords) in
                    
                    self.stopProcessIndicator()
                    if let result = coords
                    {
                        self.searchResults = NSMutableArray(array: result)
                        self.searchToDisplay?.searchResultsTableView.reloadData()

                    }
                    else
                    {
                        self.searchResults = NSMutableArray()
                        self.searchToDisplay?.searchResultsTableView.reloadData()
                    }
            }
        }
    }
    
    //MARK: UISearchDisplayDelegate
    func searchDisplayController(controller: UISearchDisplayController, shouldReloadTableForSearchString searchString: String!) -> Bool
    {
        if !controller.searchBar.isFirstResponder()
        {
            return false
        }
        if Array(searchString).count > 3 && canSendSearchRequest
        {
            startProcessIndicator()
            trigerTimerIfTextFieldDidChanged = false
            canSendSearchRequest = false
            let timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: "resetCanSendSearchRequest", userInfo: nil, repeats: false)
            searchGoogleAPI(searchString)
            return true
        }
        return false
    }
    
    //MARK: search with timer methods
    func resetCanSendSearchRequest()
    {
        canSendSearchRequest = true
        if trigerTimerIfTextFieldDidChanged && Array(trigerTimerIfTextFieldDidChangedText).count > 4 && !searchFromSearchButtonClicked
        {
            searchGoogleAPI(trigerTimerIfTextFieldDidChangedText)
            startProcessIndicator()
            trigerTimerIfTextFieldDidChanged = false
            trigerTimerIfTextFieldDidChangedText = ""
            let timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: "resetCanSendSearchRequest", userInfo: nil, repeats: false)
        }
        stopProcessIndicator()
    }
    //
    func searchDisplayController(controller: UISearchDisplayController, willHideSearchResultsTableView tableView: UITableView)
    {
        searchResults = NSMutableArray()
        controller.searchResultsTableView.reloadData()
    }

    //MARK: multiple gesture handling
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    @IBAction func unwindSegue(segue: UIStoryboardSegue) {}
    
    @IBAction func unwindToThisViewController(segue: UIStoryboardSegue) {}
    
    //TODO IOS8 realization UISearchController, delegate: UISearchControllerDelegate, prot UISearchResultsUpdating
}