//
//  ListDetailViewController.swift
//  OnTheMap
//
//  Created by Brian on 10/10/15.
//  Copyright © 2015 truckin'. All rights reserved.
//

import UIKit

class ListDetailViewController: UIViewController {

	@IBOutlet weak var name: UILabel!
	@IBOutlet weak var mapString: UILabel!
	@IBOutlet weak var when: UILabel!
	@IBOutlet weak var URL: UIButton!

	var studentInformation: StudentInformation?

	override func viewDidLoad() {
		super.viewDidLoad()
		let backButton = UIBarButtonItem()
		backButton.title = "Locations"
		navigationController?.navigationBar.topItem?.backBarButtonItem = backButton;

		if let info = studentInformation {
			name.text = info.fullName
			mapString.text = info.mapString
			when.text = DateFormatter.sharedInstance.localizedDateString(info.updatedAt)
			URL.setTitle(info.mediaURL, forState: .Normal)
			if extractValidHTTPURL(info.mediaURL) == nil {
				URL.enabled = false
			}
		}
	}

	@IBAction func seeOnMap(sender: UIButton) {
		if let info = studentInformation {
			guard let tabController = tabBarController,
				navVC = tabController.viewControllers?[0] as? UINavigationController,
				mapVC = navVC.viewControllers[0] as? MapViewController else {
					print("seeOnMap: not able to get reference to MapViewController")
					return
			}
			mapVC.autoOpenAnnotationId = info.objectId
			tabController.selectedIndex = 0
		}
	}

	/**
	Tries to open the URL if it appears to be valid.
	*/
	@IBAction func openURL(sender: AnyObject) {
		guard let info = studentInformation, url = extractValidHTTPURL(info.mediaURL) else {
			print("Missing or invalid URL, not opening URL.")
			return
		}
		UIApplication.sharedApplication().openURL(url)
	}
}