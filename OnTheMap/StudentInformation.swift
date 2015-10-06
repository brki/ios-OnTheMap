//
//  StudentInformation.swift
//  OnTheMap
//
//  Created by Brian on 30/09/15.
//  Copyright © 2015 truckin'. All rights reserved.
//

import Foundation

struct StudentInformation {

	let objectId: String
	let uniqueKey: String
	let firstName: String
	let lastName: String
	let mapString: String
	let mediaURL: String
	let latitude: Float
	let longitude: Float
	let createdAt: NSDate
	let updatedAt: NSDate

	init?(values: [String: AnyObject]) {
		let helper = JSONHelper(values: values)
		objectId  = helper.string("objectId") ?? ""
		uniqueKey = helper.string("uniqueKey") ?? ""
		firstName = helper.string("firstName") ?? ""
		lastName  = helper.string("lastName") ?? ""
		mapString = helper.string("mapString") ?? ""
		mediaURL  = helper.string("mediaURL") ?? ""
		latitude  = helper.float("latitude") ?? Float(0)
		longitude = helper.float("longitude") ?? Float(0)
		let createdAtString = helper.string("createdAt") ?? ""
		let updatedAtString = helper.string("updatedAt") ?? ""
		if helper.errorFields.count > 0 {
			print("No value found for these required fields: \(helper.errorFields)")
			return nil
		}
		createdAt = DateFormatter.sharedInstance.dateFromISO8601String(createdAtString) ?? NSDate()
		updatedAt = DateFormatter.sharedInstance.dateFromISO8601String(updatedAtString) ?? NSDate()
	}
}

class JSONHelper {

	let values: [String: AnyObject]
	var errorFields = [String]()

	init(values: [String: AnyObject]) {
		self.values = values
	}

	func string(key: String) -> String? {
		guard let value = values[key] as? String else {
			errorFields.append(key)
			return nil
		}
		return value
	}

	func float(key: String) -> Float? {
		guard let value = values[key] as? Float else {
			errorFields.append(key)
			return nil
		}
		return value
	}
}