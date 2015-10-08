//
//  AnnotationManager.swift
//  OnTheMap
//
//  Created by Brian on 03/10/15.
//  Copyright © 2015 truckin'. All rights reserved.
//

import Foundation
import MapKit

class AnnotationManager {
	var annotations = Set<StudentAnnotation>()

	func updateAnnotations(newAnnotations: Set<StudentAnnotation>, changeHandler: ((added: [StudentAnnotation], removed: [StudentAnnotation]) -> Void)? = nil) {
		if let handler = changeHandler {
			handler(
				added: Array(newAnnotations.subtract(annotations)),
				removed: Array(annotations.subtract(newAnnotations))
			)
		}
		annotations = newAnnotations
	}
}


// MARK: StudentInformation-aware methods

extension AnnotationManager {

	/**
	Update annotations with the given array of StudentInformation values.
	*/
	func updateAnnotationsWithStudentInformation(infos: [StudentInformation], changeHandler: ((added: [StudentAnnotation], removed: [StudentAnnotation]) -> Void)? = nil) {
		var annotations = Set<StudentAnnotation>()
		let infoCount = Float(infos.count)
		for (i, info) in infos.enumerate() {
			annotations.insert(StudentAnnotation(info: info, recentness: 1 - Float(i) / infoCount))
		}
		updateAnnotations(annotations, changeHandler: changeHandler)
	}
}