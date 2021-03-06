//
//  extension-UIViewController.swift
//  OnTheMap
//
//  Created by Brian on 28/10/15.
//  Copyright © 2015 truckin'. All rights reserved.
//

import UIKit

extension UIViewController {

	/**
	Show an alert.
	
	By default, the presentation of the alert is explicity added to the main thread queue,
	so that this method can be called from non-main-threads without the calling code needing
    to dispatch the call to this method on the main queue.
	*/
	func showAlert(title: String?, message: String? = nil, addToMainQueue: Bool? = true) {
		guard let _ = self.view.superview else {
			// Main view not currently on screen, so don't show the alert VC.
			print("showAlert: not currently on screen.  Alert: \(title), message: \(message)")
			return
		}

		let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
		alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
		if let main = addToMainQueue where main == true {
			dispatch_async(dispatch_get_main_queue()) { [weak self] in
				self?.presentViewController(alertController, animated: true, completion: nil)
			}
		} else {
			self.presentViewController(alertController, animated: true, completion: nil)
		}
	}
}