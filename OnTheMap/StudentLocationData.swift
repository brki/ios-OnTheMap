//
//  StudentLocationData.swift
//  OnTheMap
//
//  Created by Brian on 07/10/15.
//  Copyright © 2015 truckin'. All rights reserved.
//

import UIKit

protocol ReusableCellProviding: class {
	func cellForStudentLocation(location: StudentInformation) -> UITableViewCell
}

class StudentLocationData: NSObject, UITableViewDataSource {

	var studentInfos = [StudentInformation]()
	let parse = ParseClient.sharedInstance
	weak var cellProvider: ReusableCellProviding!

	init(cellProvider: ReusableCellProviding) {
		self.cellProvider = cellProvider
	}

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let info = studentInfos[indexPath.row]
		return cellProvider.cellForStudentLocation(info)
	}

	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return studentInfos.count
	}

	func fetchStudentInfos(forceRefresh forceRefresh: Bool = true, handler: (success: Bool, error: NSError?) -> Void) {

		func handleStudentLocations(studentLocations: [StudentInformation]?, error: NSError?) {
			if let locations = studentLocations {
				self.studentInfos = locations
				handler(success: true, error: error)
			} else {
				handler(success: false, error: error)
			}
		}

		if forceRefresh {
			parse.latestStudentInfos(handleStudentLocations)
		} else {
			parse.studentInfos(handleStudentLocations)
		}
	}

}