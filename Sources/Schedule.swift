
import Foundation

enum ScheduleTimeType: Int
{
    case UnKnown = -1,
        Today = 0,
        Tomorrow = 1,
        DayType1 = 2,
        DayType2 = 3,
        DayType3 = 4,
        DayType4 = 5,
        DayType5 = 6,
        DayType6 = 7,
        DayType7 = 8
}

class Schedule
{
    lazy var dalayInterval = 0
    lazy var days = 0
    private var dateInterval: NSTimeInterval?
    private var _date: NSDate?
    var date: NSDate {
        get {
            if self._date == nil {
                if dateInterval != nil {
                    self._date = NSDate(timeIntervalSince1970: dateInterval!)
                }
                else {
                    _date = NSDate()
                }
                }
            return _date!
        }
        set {
            _date = newValue
        }
    }
    
        
    init()
    {
    }
    
    init (sheduleRepresentation: NSDictionary)
    {
        dateInterval = sheduleRepresentation.objectForKey(kScheduleDate) as? NSTimeInterval
        dalayInterval = sheduleRepresentation.objectForKey(kScheduleInterval) as Int
        days = sheduleRepresentation.objectForKey(kScheduleDays) as Int
    }
    
    func getScheduleTimeType() -> (type: ScheduleTimeType, typeIndex: Int)
    {
        var currentIndex: Int = 0
        if days != 0
        {
            let currentDate : NSDate = NSDate()
            if days & 0x1 << currentDate.dayOfWeek() != 0
            {
                let time1: String = NSDate.routeTimeFormater.stringFromDate(NSDate())
                let time2: String = NSDate.routeTimeFormater.stringFromDate(date)
                if time1 < time2
                {
                    return (ScheduleTimeType.Today, currentIndex)
                }
            }
            let tomorrowIndex: Int = NSDate(timeInterval: 24 * 60 * 60, sinceDate: currentDate).dayOfWeek()
            if days & 0x1 << tomorrowIndex != 0
            {
                return (ScheduleTimeType.Tomorrow, currentIndex + 1)
            }
            for i in 2...7
            {
                let nextDay : Int = NSDate(timeInterval: Double(i) * 24 * 60 * 60, sinceDate: currentDate).dayOfWeek()
                if days & 0x1 << nextDay != 0
                {
                    return (ScheduleTimeType(rawValue: nextDay + 2)!, i)
                }
            }
        }
        else if date.isToday()
        {
            return (ScheduleTimeType.Today, currentIndex)
        }
        return (ScheduleTimeType.UnKnown, -1)
    }
}



