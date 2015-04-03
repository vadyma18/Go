
import Foundation

let flags = NSCalendarUnit(UInt.max)

extension NSDate
{
    class var currentCalendar: NSCalendar
    {
        get
        {
            struct StaticVar
            {
                static let instance = NSCalendar.autoupdatingCurrentCalendar()
            }
        return StaticVar.instance
        }
    }
    
    class func fromISOString(ISOString: String) -> NSDate?
    {
        return dateFormatter.dateFromString(ISOString)
    }
    
    func toISOString() -> NSString
    {
        return NSDate.dateFormatter.stringFromDate(self)
    }
    
    class var dateFormatter: NSDateFormatter
    {
        get
        {
            var df = NSDateFormatter()
            df.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            df.locale = NSLocale(localeIdentifier: "en_US_POSIX")
            df.timeZone = NSTimeZone(name: "UTC")
            return df
        }
    }
    
    func isToday() -> Bool
    {
        let components1  = NSDate.currentCalendar.components(flags, fromDate: self)
        let components2  = NSDate.currentCalendar.components(flags, fromDate: NSDate())
        //check for driver's route sort
        if components1.hour < components2.hour
        {
            return false
        }
        else if components1.hour == components2.hour && components1.minute < components2.minute
        {
            return false
        }
        else
        {
            return components1.year == components2.year &&
                components1.weekOfYear == components2.weekOfYear &&
                components1.day == components2.day
        }
    }
    
    func isTomorrow() -> Bool
    {
        let components1  = NSDate.currentCalendar.components(flags, fromDate: self)
        let components2  = NSDate.currentCalendar.components(flags, fromDate: NSDate())
        return components1.year == components2.year &&
            components1.weekOfYear == components2.weekOfYear &&
            components1.day == components2.day + 1
    }
    
    func isThisWeek() -> Bool
    {
        let components1  = NSDate.currentCalendar.components(flags, fromDate: self)
        let components2  = NSDate.currentCalendar.components(flags, fromDate: NSDate())
        return components1.year == components2.year &&
            components1.weekOfYear == components2.weekOfYear &&
            components1.day > components2.day
    }
    
    func isNextWeek() -> Bool
    {
        let components1  = NSDate.currentCalendar.components(flags, fromDate: self)
        let components2  = NSDate.currentCalendar.components(flags, fromDate: NSDate())
        return components1.year == components2.year &&
            components1.weekOfYear == components2.weekOfYear + 1
    }
    
    func dayOfWeek() -> Int
    {
        let component = NSDate.currentCalendar.components(flags, fromDate: self)
        if component.weekday == 1
        {
            return 6
        }
        return component.weekday - 2
    }
    
    class var routeDateFormater: NSDateFormatter
    {
            get
            {
                var routeDateFormater:NSDateFormatter = NSDateFormatter()
                routeDateFormater.dateFormat = "dd/MM/yyyy"
                return routeDateFormater
            }
    }
    
    class var routeTimeFormater: NSDateFormatter
    {
        get
        {
            var dateFormater:NSDateFormatter = NSDateFormatter()
            dateFormater.dateFormat = "HH:mm"
            return dateFormater
        }
    }
    
    func routeDateString() -> String
    {
        return NSDate.routeDateFormater.stringFromDate(self)
    }
    
    func routeTimeString() -> String
    {
        return NSDate.routeTimeFormater.stringFromDate(self)
    }
    
    class func routeDate(dateString: String) -> NSDate?
    {
        return routeDateFormater.dateFromString(dateString)
    }
    
    class func routeTime(timeString: String) -> NSDate?
    {
        return routeTimeFormater.dateFromString(timeString)
    }
}
