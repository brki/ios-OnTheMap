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
	let CELL_LABEL_TAG = 2

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
		if let indexPath = tableView.indexPathForRowAtPoint(buttonPosition), tbController = tabBarController {

			guard let studentInfo = tableData.locations?[indexPath.row] else {
				print("mapButtonTapped: no location data available")
				return
			}
			guard let navVC = tbController.viewControllers?[0] as? UINavigationController, mapVC = navVC.viewControllers[0] as? MapViewController else {
				print("mapButtonTapped: not able to get reference to MapViewController")
				return
			}
			mapVC.autoOpenAnnotationId = studentInfo.objectId
			tbController.selectedIndex = 0
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
				// TODO: cleanup data on logout
				self.dismissViewControllerAnimated(true, completion: nil)
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

// MARK UITableViewDelegate methods
extension ListViewController: UITableViewDelegate {
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		guard let studentInfo = tableData.locations?[indexPath.row] else {
			print("tableView(_:didSelectRowAtIndexPath): no location data available")
			return
		}
		openURL(studentInfo.mediaURL)
	}
}

// MARK: ReusableCellProviding methods

extension ListViewController: ReusableCellProviding {

	func cellForStudentLocation(location: StudentInformation) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("studentCell")!
		(cell.viewWithTag(CELL_LABEL_TAG) as! UILabel).text = location.fullName
		return cell
	}
}