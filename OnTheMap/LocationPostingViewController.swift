//
//  LocationPostingViewController.swift
//  OnTheMap
//
//  Created by Brian on 17/10/15.
//  Copyright © 2015 truckin'. All rights reserved.
//

import UIKit
import CoreLocation

class LocationPostingViewController: UIViewController {

	var selfInfo: UdacityStudentInformation?
	var client = UdacityClient.sharedInstance
	var actions = ["studying", "breathing", "working", "eating", "sleeping", "smiling", "learning", "being present", "enjoying life", "creating solutions", "feeling alright", "growing wise", "meeting a friend"]
	var geoEncoder = CLGeocoder()

	@IBOutlet weak var verbLabel: UILabel!
	@IBOutlet weak var locationSearchButton: UIButton!
	@IBOutlet weak var locationTextField: UITextField!

	override func viewDidLoad() {
		verbLabel.text = actions.randomItem()
		client.selfInformation() { selfInfo, error in
			if let error = error {
				print("LocationPostingViewController::viewDidLoad - " + error.localizedDescription)
				self.showAlert("Unable to get your Udacity information")
				return
			}
			self.selfInfo = selfInfo
		}
	}
	
	@IBAction func searchForLocation(sender: AnyObject) {
		let rawText = locationTextField.text ?? ""
		let searchText = rawText.trim()
		if searchText.characters.count == 0  {
			self.showAlert("Enter a location to search for")
			return
		}

		locationSearchButton.enabled = false
		geoEncoder.geocodeAddressString(searchText) { placemarks, error in

			if let error = error {
				guard error.domain == kCLErrorDomain, let clError = CLError(rawValue: error.code) else {
					self.showAlert("Unexpected geocoding error", message: error.localizedDescription)
					return
				}
				switch clError {
				case .GeocodeFoundNoResult:
					// TODO: maybe an alert is not appropriate here - a message in the window might be better?
					self.showAlert("No matching place found")
				case .GeocodeCanceled:
					// Request was cancelled by user.
					break
				case .Denied:
					// User denied location access to this app
					self.showAlert("Enable location access for this app in settings, then try again")
				case .LocationUnknown:
					// Perhaps temporary service error:
					self.showAlert("Search service unavailable", message: "Please try again later")
				case .Network:
					self.showAlert("Network unavailable", message: "Connect to a network and try again")
				default:
					self.showAlert("Error while finding location", message: error.localizedDescription)
				}
				return
			}

			self.locationSearchButton.enabled = true
			guard let places = placemarks else {
				self.showAlert("Unexpected error occurred while searching", message: "Places value is not set")
				return
			}
			print(places)
			if places.count == 1 {
				// TODO: show on map
			} else {
				// TODO: let user select from a list?
			}
		}
	}

	@IBAction func cancel(sender: AnyObject) {
		geoEncoder.cancelGeocode()
		self.dismissViewControllerAnimated(true, completion: nil)
	}

	@IBAction func backgroundViewTapped(sender: AnyObject) {
		view.endEditing(true)
	}

	func showAlert(title: String?, message: String? = nil, addToMainQueue: Bool? = true) {
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

