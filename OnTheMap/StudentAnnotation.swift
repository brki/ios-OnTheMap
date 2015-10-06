//
//  StudentAnnotation.swift
//  OnTheMap
//
//  Created by Brian on 03/10/15.
//  Copyright © 2015 truckin'. All rights reserved.
//

import Foundation
import MapKit

class StudentAnnotation: NSObject, MKAnnotation {

	/**
	A value between 0 and 1: a 0 represents a very old annotation, and a 1 represents the most recent annotation.
	*/
	let recentness: Float
	let uniqueStringId: String
	let date: NSDate
	let title: String?
	let subtitle: String?
	dynamic var coordinate: CLLocationCoordinate2D

	override var hashValue: Int { return uniqueStringId.hashValue }

	init(info: StudentInformation, recentness: Float) {
		self.date = info.updatedAt
		self.recentness = recentness
		self.uniqueStringId = info.objectId

		self.title = "\(info.firstName) \(info.lastName)"
		self.subtitle = info.mediaURL
		self.coordinate = CLLocationCoordinate2D(latitude: Double(info.latitude), longitude: Double(info.longitude))
	}

	// NSObject subclasses in Swift 2.0 use isEqual, and not
	// the == overload to test for equality.
	// http://stackoverflow.com/a/32726725/948341
	override func isEqual(object: AnyObject?) -> Bool {
		if let object = object as? StudentAnnotation {
			return object.uniqueStringId == self.uniqueStringId
		} else  {
			return false
		}
	}
}

func ==(lhs: StudentAnnotation, rhs: StudentAnnotation) -> Bool {
	return lhs.uniqueStringId == rhs.uniqueStringId
}