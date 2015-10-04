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
	let title: String?
	let subtitle: String?
	dynamic var coordinate: CLLocationCoordinate2D

	init(info: StudentInformation, recentness: Float) {
		self.title = "\(info.firstName) \(info.lastName)"
		self.subtitle = info.mediaURL
		self.coordinate = CLLocationCoordinate2D(latitude: Double(info.latitude), longitude: Double(info.longitude))
		self.recentness = recentness
	}
}