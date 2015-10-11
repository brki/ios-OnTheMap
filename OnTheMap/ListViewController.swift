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
		refreshStudentLocations(forceRefresh: false)
	}

	/**
	Show the related annotation in the map view tab.
	*/
	@IBAction func mapButtonTapped(sender: UIButton) {
		let buttonPosition = sender.convertPoint(CGPointZero, toView: tableView)
		if let indexPath = tableView.indexPathForRowAtPoint(buttonPosition), tabController = tabBarController {

			guard let studentInfo = tableData.locations?[indexPath.row] else {
				print("mapButtonTapped: no location data available")
				return
			}
			guard let navVC = tabController.viewControllers?[0] as? UINavigationController, mapVC = navVC.viewControllers[0] as? MapViewController else {
				print("mapButtonTapped: not able to get reference to MapViewController")
				return
			}
			mapVC.autoOpenAnnotationId = studentInfo.objectId
			tabController.selectedIndex = 0
		}
	}

	@IBAction func refreshButtonTapped(sender: AnyObject) {
		refreshStudentLocations(forceRefresh: true)
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

	func refreshStudentLocations(forceRefresh forceRefresh: Bool = false) {

		tableData.dataStore.fetchStudentLocations(forceRefresh) { locations, error in
			guard error == nil && locations != nil else {
				self.showAlert("Unable to update locations", message: error?.localizedDescription ?? "Unknown error")
				return
			}
			on_main_queue {
				self.tableView.reloadData()
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

	func showAlert(title: String?, message: String?, addToMainQueue: Bool? = true) {
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
		alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
		if let main = addToMainQueue where main == true {
			on_main_queue {
				self.presentViewController(alertController, animated: true, completion: nil)
			}
		} else {
			presentViewController(alertController, animated: true, completion: nil)
		}
	}
}

// MARK: UITableViewDelegate methods

extension ListViewController: UITableViewDelegate {

	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		guard let studentInfo = tableData.locations?[indexPath.row] else {
			print("tableView(_:didSelectRowAtIndexPath): no location data available")
			return
		}
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
			guard let studentInfo = tableData.locations?[indexPath.row] else {
				print("segue listToDetail: no location data available")
				return
			}
			let detailVC = segue.destinationViewController as! ListDetailViewController
			detailVC.studentInformation = studentInfo
		}
	}
}
