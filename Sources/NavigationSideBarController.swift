
import UIKit

class NavigationSideBarController: UINavigationController, UIGestureRecognizerDelegate
{
    private lazy var backgroundGradientLayer = CAGradientLayer()
    private var xPositionConstraint: NSLayoutConstraint?
    private var swipeGestureRecognizer: UISwipeGestureRecognizer?
    
    private var animationDuration = 0.5
    let contentViewOpacity: Float = 0.5
    let normalViewOpacity: Float = 1
    
    private lazy var contentView = UIView()
    private var sideBarView: UIView?
    
    func showSideBar(recognizer: UIScreenEdgePanGestureRecognizer)
    {
        switch recognizer.state
        {
        case .Ended:
            animateViewAppear(nil)
        default :
            break
        }
    }
    
    func setSideBarView(view: UIView)
    {
        sideBarView = view
    }
    
    
    func animateViewAppear(sender: AnyObject?)
    {
        if self.sideBarView!.frame.origin.x == -self.sideBarView!.frame.width
        {
            view.superview!.bringSubviewToFront(contentView)
            UIView.animateWithDuration(animationDuration, animations:
                { () -> Void in
                    self.sideBarView!.frame.origin.x = 0
                    self.setupBehindView(self.contentViewOpacity, userInteractionEnable: false)
                })
                { (Bool) -> Void in
                    self.swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "hideSideBar:")
                    self.swipeGestureRecognizer?.direction = UISwipeGestureRecognizerDirection.Left
                    self.contentView.addGestureRecognizer(self.swipeGestureRecognizer!)
                    self.xPositionConstraint!.constant = 0
                }
        }
    }
    
    func hideSideBar(sender: AnyObject?)
    {
        if self.sideBarView!.frame.origin.x == 0
        {
            UIView.animateWithDuration(animationDuration, animations:
                {
                    () -> Void in
                    self.sideBarView!.frame.origin.x = -self.sideBarView!.frame.size.width
                    self.setupBehindView(self.normalViewOpacity, userInteractionEnable: true)
                    self.xPositionConstraint!.constant = -self.sideBarView!.frame.width
                })
                {
                    (Bool) -> Void in
                    if (self.swipeGestureRecognizer != nil)
                    {
                        self.contentView.removeGestureRecognizer(self.swipeGestureRecognizer!)
                    }
                    self.animationDuration = 0.5
                    self.view.superview!.sendSubviewToBack(self.contentView)
            }
        }
    }
    
    private func setupBehindView(opacity: Float, userInteractionEnable: Bool)
    {
        view.layer.opacity = opacity
        view.userInteractionEnabled = userInteractionEnable
    }
    
    private func addSideBarWithConstraints()
    {
        var constraints: NSMutableArray = NSMutableArray()
        if let sideBarSuperView = sideBarView!.superview
        {
            for value in sideBarSuperView.constraints()
            {
                if let _view = (value as NSLayoutConstraint).firstItem as? UIView
                {
                    if _view == sideBarView
                    {
                        constraints.addObject(value)
                    }
                }
            }
            sideBarSuperView.removeConstraints(constraints)
            constraints.removeAllObjects()
        }
        
        for value in sideBarView!.constraints()
        {
            if let _view = (value as NSLayoutConstraint).firstItem as? UIView
            {
                if _view == sideBarView
                {
                    constraints.addObject(value)
                }
            }
        }
        sideBarView!.removeConstraints(constraints)
        
        sideBarView!.setTranslatesAutoresizingMaskIntoConstraints(false)
        setupBackgroundGradient()
        
        var constraintForWidth = NSLayoutConstraint(item: sideBarView!, attribute: .Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: sideBarView!.frame.width)
        sideBarView!.addConstraint(constraintForWidth)
        
        self.contentView.addSubview(sideBarView!)
        
        xPositionConstraint = NSLayoutConstraint(item: sideBarView!, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: self.contentView, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: -sideBarView!.frame.size.width)
        self.contentView.addConstraint(xPositionConstraint!)
        
        var yPositionConstraint = NSLayoutConstraint(item: sideBarView!, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.contentView, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0)
        self.contentView.addConstraint(yPositionConstraint)
        
        var constraintForHeight = NSLayoutConstraint(item: sideBarView!, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self.contentView, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
        self.contentView.addConstraint(constraintForHeight)
    }
    
    private func setupBackgroundGradient()
    {
        backgroundGradientLayer.frame = sideBarView!.bounds
        backgroundGradientLayer.colors = [UIColor(red: 0.9412, green: 0.2196, blue: 0.0902, alpha: 1).CGColor, UIColor(red: 0.9412, green: 0, blue: 0.2588, alpha: 1).CGColor]
        sideBarView!.layer.insertSublayer(backgroundGradientLayer, atIndex: 0)
    }
    
    private func addScreenEdgePanGestureRecognizer()
    {
        if let screenEdgePanGesture = self.view.gestureRecognizers?[0] as? UIScreenEdgePanGestureRecognizer
        {
            self.view.removeGestureRecognizer(screenEdgePanGesture)
        }
        
        var screenEdgePanGesture = UIScreenEdgePanGestureRecognizer(target: self, action: "showSideBar:")
        screenEdgePanGesture.edges = UIRectEdge.Left
        screenEdgePanGesture.delegate = self
        self.view.addGestureRecognizer(screenEdgePanGesture)
    }
    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool
    {
        return true
    }
    
    override func pushViewController(viewController: UIViewController, animated: Bool)
    {
        animationDuration = 0.25
        hideSideBar(nil)
        
        if let userPofileController = viewController as? UserProfileViewController
        {
            if userPofileController.isMyProfile
            {
                for value in self.viewControllers
                    {
                        if value.isKindOfClass(UserProfileViewController)
                        {
                            if (value as UserProfileViewController).isMyProfile
                            {
                                self.popToViewController(value as UIViewController, animated: true)
                                return
                            }
                        }
                    }
            }
        }
        else if let activeRoutesController = viewController as? RoutesController
        {
            if activeRoutesController.pageMode != .find
            {
                if let _activeRoutes = viewControllerFromStackAppropriate(viewController) as? RoutesController
                {
                    self.popToViewController(_activeRoutes, animated: true)
                    return
                }
            }

        }
        else if let mapViewController = viewController as? MapViewController
        {
            if let appropriateMapViewController = viewControllerFromStackAppropriate(viewController) as? MapViewController
            {
                appropriateMapViewController.clearViewController()
                appropriateMapViewController.pageMode = mapViewController.pageMode
                appropriateMapViewController.route = mapViewController.route
                appropriateMapViewController.title = defineTitleForPageMode(mapViewController.pageMode)
                self.popToViewController(appropriateMapViewController, animated: true)
                return
            }
        }
        else if let driverRoutesController = viewController as? DirverRoutsViewController
        {
            if let appropriateDriverRoutesController = viewControllerFromStackAppropriate(viewController)
            {
                self.popToViewController(appropriateDriverRoutesController, animated: true)
                return
            }
        }
        super.pushViewController(viewController, animated: true)
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        
        if sideBarView != nil
        {
            contentView.frame = view.frame
            contentView.autoresizingMask = UIViewAutoresizing.FlexibleHeight | UIViewAutoresizing.FlexibleWidth
            view.superview?.insertSubview(contentView, belowSubview: view)
            addSideBarWithConstraints()
            addScreenEdgePanGestureRecognizer()
        }
    }
        
    override func viewWillLayoutSubviews()
    {
        super.viewWillLayoutSubviews()
        
        if sideBarView != nil
        {
            contentView.transform = view.transform
            contentView.bounds = view.bounds
            backgroundGradientLayer.frame = sideBarView!.bounds
        }
    }
    
    private func viewControllerFromStackAppropriate(viewController: UIViewController) -> UIViewController?
    {
        var className1 = NSStringFromClass(viewController.classForCoder)
        for value in self.viewControllers
        {
            var className2 = NSStringFromClass((value as UIViewController).classForCoder)
            if className1 == className2
            {
                return value as? UIViewController
            }
        }
        return nil
    }
}
