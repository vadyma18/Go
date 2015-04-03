
import Foundation

let NeedToUseStubValue = true

class StubGoServer
{
	class var instance : StubGoServer
	{
		get
		{
			struct StaticVar
			{
				static let instance = StubGoServer()
			}
			return StaticVar.instance
		}
	}

	func getStubRoutes() -> NSArray?
	{
		var path: NSString = NSBundle.mainBundle().pathForResource("Routs", ofType: "plist")!
		var routes : NSArray? = NSArray(contentsOfFile: path)
		return routes
	}
}