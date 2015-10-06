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

	// TODO: the hashing / set membership checking is not working as expected, probably simply
	// because the Parse objectID changes from call to call.  Perhaps use hash value of String(coordinate + date + title) instead.
	let uniqueStringId: String
	let recentness: Float
	let date: NSDate
	let title: String?
	let subtitle: String?
	dynamic var coordinate: CLLocationCoordinate2D

	override var hashValue: Int { return uniqueStringId.hashValue }

	init(info: StudentInformation, recentness: Float) {
		self.uniqueStringId = info.objectId
		self.date = info.updatedAt
		self.recentness = recentness

		self.title = "\(info.firstName) \(info.lastName)"
		self.subtitle = info.mediaURL
		self.coordinate = CLLocationCoordinate2D(latitude: Double(info.latitude), longitude: Double(info.longitude))
	}
}

func ==(lhs: StudentAnnotation, rhs: StudentAnnotation) -> Bool {
	return lhs.uniqueStringId == rhs.uniqueStringId
}