//
//  LocationPostingViewController.swift
//  OnTheMap
//
//  Created by Brian on 17/10/15.
//  Copyright © 2015 truckin'. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class LocationPostingViewController: UIViewController {

	var selfInfo: UdacityStudentInformation?
	var client = UdacityClient.sharedInstance
	var actions = ["studying", "breathing", "working", "eating", "sleeping", "smiling", "learning", "being present", "enjoying life", "creating solutions", "feeling alright", "growing wise", "meeting a friend"]
	var geoEncoder = CLGeocoder()
	var selectedPlacemark: CLPlacemark?

	@IBOutlet weak var locationPrompt: UILabel!
	@IBOutlet weak var locationSearchButton: UIButton!
	@IBOutlet weak var locationTextField: UITextField!
	@IBOutlet weak var stepOneView: UIView!
	@IBOutlet weak var stepTwoView: UIView!
	@IBOutlet weak var mapView: MKMapView!

	override func viewDidLoad() {
		locationPrompt.attributedText = attributedLocationPrompt()
		client.selfInformation() { selfInfo, error in
			if let error = error {
				print("LocationPostingViewController::viewDidLoad - " + error.localizedDescription)
				self.showAlert("Unable to get your Udacity information")
				return
			}
			self.selfInfo = selfInfo
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

// MARK: step 1 specific methods

/**
Step 1 involves prompting the user for a location and forward-geocoding it.

Step 1 and step 2 have different views for the main window content.
*/
extension LocationPostingViewController {

	func attributedLocationPrompt() -> NSAttributedString {
		let fontSize = CGFloat(17)
		let actionString = actions.randomItem()
		let normalAttributes = [NSFontAttributeName: UIFont.systemFontOfSize(fontSize)]
		let boldAttributes = [NSFontAttributeName: UIFont.boldSystemFontOfSize(fontSize)]
		let attributedString = NSMutableAttributedString(string: "Where are you", attributes: normalAttributes)
		attributedString.appendAttributedString(NSAttributedString(string: " \(actionString) ", attributes: boldAttributes))
		attributedString.appendAttributedString(NSAttributedString(string: "today?", attributes: normalAttributes))
		return NSAttributedString(attributedString: attributedString)
	}

	@IBAction func searchForLocation(sender: AnyObject) {
		let rawText = locationTextField.text ?? ""
		let searchText = rawText.trim()
		if searchText.characters.count == 0  {
			self.showAlert("Enter a location to search for")
			return
		}
		view.endEditing(true)

		// TODO: make it clear to user that activity is happening (spinning indicator or similar)
		locationSearchButton.enabled = false
		geoEncoder.geocodeAddressString(searchText) { placemarks, error in

			self.locationSearchButton.enabled = true
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

			guard let places = placemarks else {
				self.showAlert("Unexpected error occurred while searching", message: "Places value is not set")
				return
			}

			print(places)
			if places.count == 1 {
				guard let _ = places[0].location else {
					self.showAlert("No geocoordinates ", message: "Matching place found, but no latitude / longitude values are available.  Try being more specific.")
					return
				}
				self.selectedPlacemark = places[0]
				on_main_queue {
					self.transitionToURLPostingView()
				}
			} else {
				for place in places {
					print(self.placemarkAddress(place))
				}
				// TODO: show a UIPickerView to let user select options
			}
		}
	}

	func placemarkAddress(placemark: CLPlacemark) -> String {
		if let addressLines = placemark.addressDictionary?["FormattedAddressLines"] as? [String] {
			return addressLines.joinWithSeparator(", ")
		}
		return placemark.name ?? "Unknown"
	}
	
	func transitionToURLPostingView() {
		showSelectedLocationOnMap()
		view.endEditing(true)
		UIView.transitionWithView(
			stepOneView,
			duration: 0.3,
			options: .TransitionCrossDissolve,
			animations: { self.stepOneView.hidden = true },
			completion: { finished in
				UIView.transitionWithView(
					self.stepTwoView,
					duration: 0.4,
					options: .TransitionCrossDissolve,
					animations: {self.stepTwoView.hidden = false},
					completion: nil)
			}
		)
	}
}

// MARK: step 2 specific methods

/**
Step 2 involves prompting the user for a URL, showing the location from step 1, and submitting the StudentLocation through the Parse API.
*/
extension LocationPostingViewController {

	func showSelectedLocationOnMap() {
		guard let coordinate = selectedPlacemark?.location?.coordinate else {
			print("showSelecteLocationOnMap: coordinate unexpectedly nil")
			return
		}
		let pin = MKPointAnnotation()
		pin.coordinate = coordinate
		let displayRegion = displayRegionForPlacemark(selectedPlacemark!)
		on_main_queue {
			self.mapView.centerCoordinate = coordinate
			if let region = displayRegion {
				self.mapView.region = region
			}
			self.mapView.addAnnotation(pin)
		}
	}

	/**
	Determine a suitable region to display based on the region found in the placemark object.

	The returned region will always be at least 600 meter wide region, even if the placemark's region radius
	is smaller.
	*/
	func displayRegionForPlacemark(placemark: CLPlacemark) -> MKCoordinateRegion? {
		guard let center = placemark.location?.coordinate else {
			print("No center found; unable to calculate display region")
			return nil
		}
		let minRadius = 300.0
		guard let radius = (placemark.region as? CLCircularRegion)?.radius where radius > minRadius else {
			return MKCoordinateRegionMakeWithDistance(center, minRadius, minRadius)
		}
		return MKCoordinateRegionMakeWithDistance(center, radius, radius)
	}
}
