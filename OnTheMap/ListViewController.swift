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
	var studentLocationData: StudentLocationData!

	let CELL_BUTTON_TAG = 1
	let CELL_LABEL_TAG = 2

	override func viewDidLoad() {
		super.viewDidLoad()
		studentLocationData = StudentLocationData(cellProvider: self)
		tableView.dataSource = studentLocationData
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

			let studentInfo = studentLocationData.studentInfos[indexPath.row]
			if let navVC = tbController.viewControllers?[0] as? UINavigationController,
				mapVC = navVC.viewControllers[0] as? MapViewController {

					mapVC.autoOpenAnnotationId = studentInfo.objectId
					tbController.selectedIndex = 0
			}
		}
	}

	@IBAction func refreshButtonTapped(sender: AnyObject) {
		refreshStudentLocations(forceRefresh: true)
	}

	@IBAction func logout(sender: UIBarButtonItem) {
		UdacityClient.sharedInstance.logout() { result, error in
			on_main_queue {
				guard error == nil else {
					self.showAlert("Logout error", message: error!.localizedDescription)
					return
				}
				self.dismissViewControllerAnimated(true, completion: nil)
			}
		}
	}

	func refreshStudentLocations(forceRefresh forceRefresh: Bool = false) {
		studentLocationData.fetchStudentInfos(forceRefresh: forceRefresh) { success, error in
			on_main_queue {
				guard error == nil && success == true else {
					self.showAlert("Unable to update locations", message: error?.localizedDescription ?? "Unknown error")
					return
				}
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

	func showAlert(title: String?, message: String?) {
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
		alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
		presentViewController(alertController, animated: true, completion: nil)
	}
}

// MARK UITableViewDelegate methods
extension ListViewController: UITableViewDelegate {
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let studentInfo = studentLocationData.studentInfos[indexPath.row]
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