//
//  Models.swift
//  Go
//
//  Created by Dmytro Kovalchuk on 08.09.14.
//  Copyright (c) 2014 Zeo. All rights reserved.
//

import Foundation

enum ScheduleTimeType: Int {
	case Unknown = -1, Today = 0, Tomorrow, ThisWeek, NextWeek
	static let allVals = [Unknown, Today, Tomorrow, ThisWeek, NextWeek]
}

// TODO Serialize and deserialize JSON requests/responds into native types
class Schedule
{
	var time: NSDate?
	var interval: Int?
	var days: Array<Int>
	var date: NSDate?

	init()
	{
		time = NSDate()
		interval = 0
		days = []
		date = NSDate()
	}

	init(time theTime : NSDate, andDate theDate : NSDate, delayInterval theInterval: Int, andReportForDays theDays : Array<Int>)
	{
		time = theTime
		interval = theInterval
		days = theDays
		date = theDate
	}

	init (sheduleRepresentation : NSDictionary)
	{
		if let timeString = sheduleRepresentation.objectForKey("time") as? NSString
		{
			time = NSDate.fromISOString(timeString)
		}
		
		if let dateString = sheduleRepresentation.objectForKey("date") as? NSString
		{
			date = NSDate.fromISOString(dateString)
		}
		
		interval = sheduleRepresentation.objectForKey("interval") as? Int
		days = sheduleRepresentation.objectForKey("days") as Array<Int>
	}
	
	func getScheduleTimeType() -> ScheduleTimeType
	{
		var routeDate : NSDate! = date ?? time
		var type : ScheduleTimeType = ScheduleTimeType.Unknown
		
		if routeDate.isToday()
		{
			type = ScheduleTimeType.Today
		}
		else if routeDate.isTomorrow()
		{
			type = ScheduleTimeType.Tomorrow
		}
		else if routeDate.isThisWeek()
		{
			type = ScheduleTimeType.ThisWeek
		}
		else if routeDate.isNextWeek()
		{
			type = ScheduleTimeType.NextWeek
		}
		return type
	}
}

let flags = NSCalendarUnit(UInt.max)

extension NSDate
{
	class var currentCalendar : NSCalendar
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
	
	class func fromISOString(ISOString: String) -> NSDate? {
		return dateFormatter.dateFromString(ISOString)
	}
	
	func toISOString() -> NSString {
		return NSDate.dateFormatter.stringFromDate(self)
	}
	
	class var dateFormatter : NSDateFormatter
		{
		get {
			var df = NSDateFormatter()
			df.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
			df.locale = NSLocale(localeIdentifier: "en_US_POSIX")
			df.timeZone = NSTimeZone(name: "UTC")
			return df
		}
	}
	
	func isToday () -> Bool
	{
		let components1  = NSDate.currentCalendar.components(flags, fromDate: self)
		let components2  = NSDate.currentCalendar.components(flags, fromDate: NSDate())
		return components1.year == components2.year &&
			components1.weekOfYear == components2.weekOfYear &&
			components1.day == components2.day
	}
	
	func isTomorrow () -> Bool
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
			components1.weekOfYear == components2.weekOfYear
	}
	
	func isNextWeek() -> Bool
	{
		let components1  = NSDate.currentCalendar.components(flags, fromDate: self)
		let components2  = NSDate.currentCalendar.components(flags, fromDate: NSDate())
		return components1.year == components2.year &&
			components1.weekOfYear == components2.weekOfYear + 1
	}
}
