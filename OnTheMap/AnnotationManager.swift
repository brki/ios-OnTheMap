//
//  AnnotationManager.swift
//  OnTheMap
//
//  Created by Brian on 03/10/15.
//  Copyright © 2015 truckin'. All rights reserved.
//

import Foundation
import MapKit

struct AnnotationManager {

	/**
	A reference is kept to the last-fetched annotations so that a difference can be calculated the next time the annotations
	are updated.
	*/
	var annotations = Set<StudentAnnotation>()
	let dataStore = (UIApplication.sharedApplication().delegate as! AppDelegate).dataStore

	/**
	Updates the annotations from the data store.
	
	The difference between the old list of annotations and the new list of annotations is calculated, so
	that the caller can use that information.
	*/
	mutating func updateStudentAnnotations(foreceRefresh forceRefresh: Bool = true, changeHandler: ((added: [StudentAnnotation]?, removed: [StudentAnnotation]?, error: NSError?) -> Void)?){

		dataStore.fetchStudentLocations(forceRefresh) { locations, error in
			if let err = error {
				changeHandler?(added: nil, removed: nil, error: err)
				return
			}
			guard let newLocations = locations else {
				let err = NSError(domain: "AnnotationManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to refresh locations"])
				changeHandler?(added: nil, removed: nil, error: err)
				return
			}

			var newAnnotations = Set<StudentAnnotation>()
			let locationCount = Float(newLocations.count)
			for (i, location) in newLocations.enumerate() {
				newAnnotations.insert(StudentAnnotation(info: location, recentness: 1 - Float(i) / locationCount))
			}

			changeHandler?(
				added: Array(newAnnotations.subtract(self.annotations)),
				removed: Array(self.annotations.subtract(newAnnotations)),
				error: nil
			)
			self.annotations = newAnnotations
		}
	}
}