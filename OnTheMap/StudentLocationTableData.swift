//
//  StudentLocationTableData.swift
//  OnTheMap
//
//  Created by Brian on 07/10/15.
//  Copyright © 2015 truckin'. All rights reserved.
//

import UIKit

protocol ReusableCellProviding: class {
	func cellForStudentLocation(location: StudentInformation) -> UITableViewCell
}

class StudentLocationTableData: NSObject {

	let dataStore = (UIApplication.sharedApplication().delegate as! AppDelegate).dataStore
	weak var cellProvider: ReusableCellProviding!

	init(cellProvider: ReusableCellProviding) {
		self.cellProvider = cellProvider
	}

	var locations: [StudentInformation]? {
		return dataStore.studentLocations
	}
}

// MARK: UITableViewDataSource methods

extension StudentLocationTableData: UITableViewDataSource {

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		guard let locationData = locations else {
			print("datastore locations unexpectedly nil (1)")
			return UITableViewCell()
		}
		let info = locationData[indexPath.row]
		return cellProvider.cellForStudentLocation(info)
	}

	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let locationData = locations else {
			print("datastore locations unexpectedly nil (2)")
			return 0
		}
		return locationData.count
	}
}