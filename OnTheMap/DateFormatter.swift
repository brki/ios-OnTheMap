//
//  DateFormatter.swift
//  OnTheMap
//
//  Created by Brian on 05/10/15.
//  Copyright © 2015 truckin'. All rights reserved.
//

import Foundation

class DateFormatter {
	static let sharedInstance = DateFormatter()

	let iso8601Format = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"

	var stringToDateFormatter = NSDateFormatter()
	var dateToStringFormatter = NSDateFormatter()

	init() {
		// Parse input strings in ISO8601 format, converting them to UTC as necessary.
		stringToDateFormatter.timeZone = NSTimeZone(name: "UTC")
		stringToDateFormatter.dateFormat = iso8601Format

		// Output: short format, localized.
		dateToStringFormatter.timeZone = NSTimeZone.localTimeZone()
		dateToStringFormatter.dateStyle = .ShortStyle
		dateToStringFormatter.timeStyle = .ShortStyle
		dateToStringFormatter.locale = NSLocale.autoupdatingCurrentLocale()
	}

	func localizedDateString(date: NSDate) -> String {
		return dateToStringFormatter.stringFromDate(date)
	}

	func dateFromISO8601String(dateString: String) -> NSDate? {
		return stringToDateFormatter.dateFromString(dateString)
	}

}