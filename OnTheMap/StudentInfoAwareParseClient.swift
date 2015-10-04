//
//  StudentInfoAwareParseClient.swift
//  OnTheMap
//
//  Created by Brian on 03/10/15.
//  Copyright © 2015 truckin'. All rights reserved.
//

import Foundation

extension ParseClient {

	func latestStudentInfos(handler: ([StudentInformation]?, NSError?) -> Void) {
		getStudentLocations() { results, error in
			guard let results = results else {
				if error == nil {
					handler(nil, NSError(domain: "ParseClient", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unknown error"]))
				} else {
					handler(nil, error)
				}
				return
			}
			var newStudentInfos = [StudentInformation]()
			for result in results {
				if let info = StudentInformation(values: result) {
					newStudentInfos.append(info)
				}
			}
			handler(newStudentInfos, nil)
		}
	}
}