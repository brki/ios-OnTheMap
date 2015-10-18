//
//  LocationPostingViewController.swift
//  OnTheMap
//
//  Created by Brian on 17/10/15.
//  Copyright © 2015 truckin'. All rights reserved.
//

import UIKit

class LocationPostingViewController: UIViewController {

	var selfInfo: UdacityStudentInformation?
	var client = UdacityClient.sharedInstance
	var actions = ["studying", "breathing", "working", "eating", "sleeping", "smiling", "learning", "being present", "enjoying life", "creating solutions", "feeling alright", "growing wise", "meeting a friend"]

	@IBOutlet weak var verbLabel: UILabel!

	override func viewDidLoad() {
		verbLabel.text = actions.randomItem()
		client.selfInformation() { selfInfo, error in
			if let error = error {
				self.showAlert("Unable to get your Udacity information", message: error.localizedDescription)
				return
			}
			self.selfInfo = selfInfo
		}
	}
	
	@IBAction func cancel(sender: AnyObject) {
		self.dismissViewControllerAnimated(true, completion: nil)
	}

	@IBAction func backgroundViewTapped(sender: AnyObject) {
		view.endEditing(true)
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

