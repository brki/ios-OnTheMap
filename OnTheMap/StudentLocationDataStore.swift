//
//  StudentLocationDataStore.swift
//  OnTheMap
//
//  Created by Brian on 09/10/15.
//  Copyright © 2015 truckin'. All rights reserved.
//

import Foundation

class StudentLocationDataStore {
	var studentLocations: [StudentInformation]?

	func fetchStudentLocations(refresh: Bool = true, handler: (locations:[StudentInformation]?, error: NSError?) -> Void) {

		if studentLocations != nil && !refresh {
			handler(locations: studentLocations, error: nil)
			return
		}

		ParseClient.sharedInstance.latestStudentInfos { newStudentLocations, error in
			if let locations = newStudentLocations {
				self.studentLocations = locations
				handler(locations: locations, error: error)
			} else {
				handler(locations: nil, error: error)
			}
		}
	}
}