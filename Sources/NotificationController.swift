
import Foundation

var rootNavigationController: UINavigationController?

class NotificationController: NSObject
{
    private var needUpdate = false
    lazy var notificationData: NSDictionary = NSDictionary()
    
    func setNotificationData(data: NSDictionary)
    {
        notificationData = data;
    }
    
    func showAlertView()
    {
        if let navigationController = rootNavigationController
        {
            var refreshAlert = UIAlertController(title: "", message: notificationData.objectForKey("alert") as? String, preferredStyle: UIAlertControllerStyle.Alert)
            var notificationType = self.notificationData.objectForKey("nType") as NSString
            var rideId = notificationData.objectForKey("rideId") as NSString
            
            switch notificationType
            {
                case "join":
                    showRouteDriverPreviewTableViewOn(navigationController, refreshAlert: refreshAlert, rideId: rideId)
                
                case "accept", "start", "change", "decline", "comment":
                    showRoutePassengerPreviewViewControllerOn(navigationController, refreshAlert: refreshAlert, rideId: rideId, notificationType: notificationType)
                
                default:
                    break
            }
        }
    }
    
    private func showRouteDriverPreviewTableViewOn(navigationController: UINavigationController, refreshAlert: UIAlertController, rideId: NSString)
    {
        if let visibleController = rootNavigationController?.visibleViewController as? RouteDriverPreviewTableView
        {
            refreshRouteDriverPreviewTableViewController(visibleController, refreshAlert: refreshAlert, rideId: rideId)
        }
        else
        {
            pushRouteDriverPreviewTableViewWith(refreshAlert, rideId: rideId)
        }
        navigationController.presentViewController(refreshAlert, animated: true, completion: nil)
    }
    
    private func refreshRouteDriverPreviewTableViewController(visibleController: RouteDriverPreviewTableView, refreshAlert: UIAlertController, rideId: NSString)
    {
        GoServer.instance.getRide(rideId, handler:
            {
                (code, route) in
                if let _route: Route = route
                {
                    visibleController.refreshTableView(_route)
                }
        })
        refreshAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler:
            {
                (action: UIAlertAction!) in
        }))
    }
    
    private func pushRouteDriverPreviewTableViewWith(refreshAlert: UIAlertController, rideId: NSString)
    {
        var storyboard = UIStoryboard(name: "Main", bundle: nil)
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler:
            {
                (action: UIAlertAction!) in
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Show", style: .Default, handler:
            {
                (action: UIAlertAction!) in
                GoServer.instance.getRide(rideId, handler:
                    {
                        (code, route) in
                        if let _route: Route = route
                        {
                            var vc = storyboard.instantiateViewControllerWithIdentifier("RouteDriverPreviewTableView") as RouteDriverPreviewTableView
                            vc.route = _route
                            rootNavigationController?.pushViewController(vc, animated: true)
                        }
                })
        }))
    }
    
    private func showRoutePassengerPreviewViewControllerOn(navigationController: UINavigationController, refreshAlert: UIAlertController, rideId: NSString, notificationType: NSString)
    {
        var storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let visibleController = rootNavigationController?.visibleViewController as? RoutePassengerPreviewViewController
        {
            if notificationType == "comment"
            {
                showMessageViewOnController(visibleController, refreshAlert: refreshAlert, navigationController: navigationController)
            }
            else
            {
                refreshRoutePassengerPreviewViewController(visibleController, refreshAlert: refreshAlert, rideId: rideId, navigationController: navigationController)
            }
        }
        else
        {
            pushRoutePassengerPreviewViewControllerWith(refreshAlert, rideId: rideId, navigationController: navigationController, notificationType: notificationType)
        }
    }
    
    private func showMessageViewOnController(visibleController: RoutePassengerPreviewViewController, refreshAlert: UIAlertController, navigationController: UINavigationController)
    {
        if visibleController.messageViewHidden
        {
            refreshAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler:
                {
                    (action: UIAlertAction!) in
            }))
            
            refreshAlert.addAction(UIAlertAction(title: "Show", style: .Default, handler:
                {
                    (action: UIAlertAction!) in
                    visibleController.messageViewHidden = false
            }))
            navigationController.presentViewController(refreshAlert, animated: true, completion: nil)
        }
        else
        {
            visibleController.messagesTableViewController!.refreshMessages()
        }
    }
    
    private func refreshRoutePassengerPreviewViewController(visibleController: RoutePassengerPreviewViewController, refreshAlert: UIAlertController, rideId: NSString, navigationController: UINavigationController)
    {
        GoServer.instance.getRide(rideId, handler:
            {
                (code, route) in
                if let _route: Route = route
                {
                    visibleController.refreshViewController(_route)
                    visibleController.passengersTableView.reloadData()
                }
        })
        refreshAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler:
            {
                (action: UIAlertAction!) in
        }))
        navigationController.presentViewController(refreshAlert, animated: true, completion: nil)
    }
    
    private func pushRoutePassengerPreviewViewControllerWith(refreshAlert: UIAlertController, rideId: NSString, navigationController: UINavigationController, notificationType: NSString)
    {
        var storyboard = UIStoryboard(name: "Main", bundle: nil)
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler:
            {
                (action: UIAlertAction!) in
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Show", style: .Default, handler:
            {
                (action: UIAlertAction!) in
                GoServer.instance.getRide(rideId, handler:
                    {
                        (code, route) in
                        if let _route: Route = route
                        {
                            var vc = storyboard.instantiateViewControllerWithIdentifier("RoutePassengerPreviewViewController") as RoutePassengerPreviewViewController
                            vc.route = _route
                            rootNavigationController?.pushViewController(vc, animated: false)
                            if notificationType == "comment"
                            {
                                vc.setValue(false, forKey: "_messageViewHidden")
                            }
                        }
                })
        }))
        navigationController.presentViewController(refreshAlert, animated: true, completion: nil)
    }
}
