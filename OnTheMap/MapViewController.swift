//
//  MapViewController
//  OnTheMap
//
//  Created by Brian on 23/09/15.
//  Copyright © 2015 truckin'. All rights reserved.
//

import UIKit

class MapViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		ParseClient.sharedInstance.getStudentLocations() { results, error in
			guard let results = results where error == nil else {
				print("TODO: deal with error: \(error)")
				return
			}
			var infos = [StudentInformation]()
			for result in results {
				if let info = StudentInformation(values: result) {
					infos.append(info)
				}
			}
			print(infos)
		}
		// Do any additional setup after loading the view, typically from a nib.
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	@IBAction func logout(sender: UIBarButtonItem) {
		UdacityClient.sharedInstance.logout() { result, error in
			dispatch_async(dispatch_get_main_queue()) {
				guard error == nil else {
					self.showAlert("Logout error", message: error!.localizedDescription)
					return
				}
				self.dismissViewControllerAnimated(true, completion: nil)
			}
		}
	}

	func showAlert(title: String?, message: String?) {
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
		alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
		presentViewController(alertController, animated: true, completion: nil)
	}

}

