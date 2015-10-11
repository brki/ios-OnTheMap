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
	@IBOutlet weak var URL: UILabel!
	@IBOutlet weak var mapString: UILabel!

	var studentInformation: StudentInformation?

	override func viewDidLoad() {
		super.viewDidLoad()
		let backButton = UIBarButtonItem()
		backButton.title = "Locations"
		navigationController?.navigationBar.topItem?.backBarButtonItem = backButton;

		if let info = studentInformation {
			name.text = info.fullName
			URL.text = info.mediaURL
			mapString.text = info.mapString
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
}