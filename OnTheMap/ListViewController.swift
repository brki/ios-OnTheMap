//
//  ListViewController.swift
//  OnTheMap
//
//  Created by Brian on 23/09/15.
//  Copyright © 2015 truckin'. All rights reserved.
//

import UIKit

class ListViewController: UIViewController {

	@IBOutlet var tableView: UITableView!
	var tableData: StudentLocationTableData!

	let CELL_BUTTON_TAG = 1
	let CELL_NAME_TAG = 2
	let CELL_PLACE_NAME_TAG = 3

	override func viewDidLoad() {
		super.viewDidLoad()
		tableData = StudentLocationTableData(cellProvider: self)
		tableView.dataSource = tableData
	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		// In the case of just switching from one tabbed view to another, there is no
		// need to refresh the data from the network source.
		refreshStudentLocations(forceRefresh: false)
	}

	@IBAction func refreshButtonTapped(sender: AnyObject) {
		refreshStudentLocations()
	}

	@IBAction func logout(sender: UIBarButtonItem) {
		UdacityClient.sharedInstance.logout() { result, error in
			guard error == nil else {
				self.showAlert("Logout error", message: error!.localizedDescription)
				return
			}
			on_main_queue {
				self.dismissViewControllerAnimated(true, completion: nil)
				(UIApplication.sharedApplication().delegate as! AppDelegate).onLogout()
			}
		}
	}

	/**
	Gets the student locations and triggers the reloading of the table view's data.
	
	The table view is scrolled to the first row if the data refresh is successful.
	
	``forceRefresh: false`` can be used if there's no need to refresh the data from the network source.
	*/
	func refreshStudentLocations(forceRefresh forceRefresh: Bool = true) {
		tableData.dataStore.fetchStudentLocations(forceRefresh) { locations, error in
			guard error == nil && locations != nil else {
				self.showAlert("Unable to update locations", message: error?.localizedDescription ?? "Unknown error")
				return
			}
			on_main_queue {
				self.tableView.reloadData()
				self.scrollToFirstRow()
			}
		}
	}

	/**
	Tries to open the URL if it appears to be valid.
	*/
	func openURL(string: String?) -> Bool {
		guard let urlString = string, url = extractValidHTTPURL(urlString) else {
			print("Missing or invalid URL, not opening: \"\(string)\"")
			return false
		}
		if !UIApplication.sharedApplication().openURL(url) {
			print("Failed to launch Safari with url: \(url)")
			return false
		}
		return true
	}

	/**
	Scrolls to first row in the table, if the table has any rows.
	*/
	func scrollToFirstRow() {
		if tableView.numberOfRowsInSection(0) > 0 {
			let indexPath = NSIndexPath(forRow: 0, inSection: 0)
			self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
		}
	}
}

// MARK: UITableViewDelegate methods

extension ListViewController: UITableViewDelegate {

	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		guard let studentInfo = tableData.studentInformationForIndexPath(indexPath) else {
			print("tableView(_:didSelectRowAtIndexPath): no location data available")
			return
		}
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		openURL(studentInfo.mediaURL)
	}

	func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
		performSegueWithIdentifier("ListToDetail", sender: indexPath)
	}
}

// MARK: ReusableCellProviding methods

extension ListViewController: ReusableCellProviding {

	func cellForStudentLocation(location: StudentInformation) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("studentCell")!
		(cell.viewWithTag(CELL_NAME_TAG) as! UILabel).text = location.fullName
		(cell.viewWithTag(CELL_PLACE_NAME_TAG) as! UILabel).text = location.mapString
		return cell
	}
}

// MARK: Segues

extension ListViewController {

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "ListToDetail" {
			guard let indexPath = sender as? NSIndexPath else {
				print("listToDetail expects sender to be an indexPath")
				return
			}
			guard let studentInfo = tableData.studentInformationForIndexPath(indexPath) else {
				print("segue listToDetail: no location data available")
				return
			}
			let detailVC = segue.destinationViewController as! ListDetailViewController
			detailVC.studentInformation = studentInfo

		} else if segue.identifier == "ListToLocationPosting" {
			let locationPostingVC = segue.destinationViewController as! LocationPostingViewController

			// If a location was posted, refresh the list of locations.
			locationPostingVC.locationPostedHandler = { [unowned self] coordinate, objectId in
				self.refreshStudentLocations()
			}
		}
	}
}
