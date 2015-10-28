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
	let udacityClient = UdacityClient.sharedInstance
	let parseClient = ParseClient.sharedInstance
	var actions = ["studying", "breathing", "working", "eating", "sleeping", "smiling", "learning", "being present", "enjoying life", "creating solutions", "feeling alright", "growing wise", "meeting a friend"]
	var geoEncoder = CLGeocoder()
	var selectedPlacemark: CLPlacemark?
	var pickerData: PlacePickerData?
	var locationPostedHandler: ((coordinate: CLLocationCoordinate2D, objectId: String) -> Void)?

	@IBOutlet weak var stepOneView: UIView!
	@IBOutlet weak var locationPrompt: UILabel!
	@IBOutlet weak var locationSearchButton: UIButton!
	@IBOutlet weak var locationTextField: UITextField!
	@IBOutlet weak var placePickerView: UIPickerView!
	@IBOutlet weak var searchActivityIndicator: UIActivityIndicatorView!

	@IBOutlet weak var stepTwoView: UIView!
	@IBOutlet weak var linkTextField: UITextField!
	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var submitLocationButton: UIButton!

	override func viewDidLoad() {
		locationPrompt.attributedText = attributedLocationPrompt()
		udacityClient.selfInformation() { selfInfo, error in
			if let error = error {
				print("LocationPostingViewController::viewDidLoad - " + error.localizedDescription)
				self.showAlert("Unable to get your Udacity information")
				on_main_queue {
					// There's no point in letting the user doing anything other than returning to
					// the previous screen at this point.
					self.stepOneView.hidden = true
				}
				return
			}
			self.selfInfo = selfInfo
		}

		// Make the activity indicator a bit bigger:
		searchActivityIndicator.transform = CGAffineTransformMakeScale(2.0, 2.0)
	}
	
	@IBAction func cancel(sender: AnyObject) {
		geoEncoder.cancelGeocode()
		self.dismissViewControllerAnimated(true, completion: nil)
	}

	@IBAction func backgroundViewTapped(sender: AnyObject) {
		view.endEditing(true)
	}

	func showAlert(title: String?, message: String? = nil, addToMainQueue: Bool? = true) {
		OnTheMap.showAlert(self, title: title, message: message, addToMainQueue: addToMainQueue)
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

		on_main_queue {
			self.locationSearchButton.enabled = false
			self.searchActivityIndicator.hidden = false
			self.searchActivityIndicator.startAnimating()
		}

		geoEncoder.geocodeAddressString(searchText) { placemarks, error in

			on_main_queue {
				self.locationSearchButton.enabled = true
				self.searchActivityIndicator.stopAnimating()
			}

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

			if places.count == 1 {
				self.handleSelectedPlace(places[0])
			} else {
				self.showPickerViewForPlaces(places)
			}
		}
	}

	func handleSelectedPlace(place: CLPlacemark) {
		guard let _ = place.location else {
			self.showAlert("No geocoordinates ", message: "Matching place found, but no latitude / longitude values are available.  Try being more specific.")
			return
		}
		self.selectedPlacemark = place
		on_main_queue {
			self.placePickerView.hidden = true
			self.transitionToURLPostingView()
		}
	}

	func showPickerViewForPlaces(places: [CLPlacemark]) {
		self.pickerData = PlacePickerData(placemarks: places, placeSelectedHandler: { [unowned self] place in
			self.handleSelectedPlace(place)
		})
		placePickerView.delegate = pickerData
		placePickerView.dataSource = pickerData
		on_main_queue {
			self.placePickerView.hidden = false
		}
	}

	/**
	Blend out the step 1 (location prompt) view, blend in the step 2 (map + url prompt) view.
	*/
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

	@IBAction func submitLocation(sender: AnyObject) {
		guard let linkText = linkTextField.text?.trim() where linkText.characters.count > 0 else {
			showAlert("Please enter a URL to share")
			return
		}
		guard let url = extractValidHTTPURL(linkText) else {
			showAlert("Please enter a valid URL")
			return
		}

		guard let userInfo = selfInfo else {
			print("submitLocation: userInfo unexpectedly nil")
			return
		}

		guard let mapString = locationTextField.text?.trim() else {
			print("submitLocation: mapString unexpectedly nil")
			return
		}
		guard let coordinate = selectedPlacemark?.location?.coordinate else {
			print("submitLocation: coordinate unexpectedly nil")
			return
		}
		guard let accountKey = udacityClient.accountKey else {
			print("submitLocation: accountKey unexpectedly nil")
			return
		}

		self.submitLocationButton.enabled = false

		parseClient.addLocation(accountKey, firstName: userInfo.firstName, lastName: userInfo.lastName, mapString: mapString, mediaURL: url, latitude: coordinate.latitude, longitude: coordinate.longitude) { objectId, error in

			on_main_queue {
				self.submitLocationButton.enabled = true
			}

			guard error == nil else {
				self.showAlert("Error while posting location", message: error!.localizedDescription)
				return
			}

			// Call locationPostedHandler which the presenting view controller may have set,
			// and dismiss back to presenting view controller.
			self.locationPostedHandler?(coordinate: coordinate, objectId: objectId!)
			on_main_queue {
				self.dismissViewControllerAnimated(true, completion: nil)
			}
		}
	}
}


// MARK: Segues

extension LocationPostingViewController {

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "LocationPostingToBrowseToURL" {
			let vc = segue.destinationViewController as! BrowseToURLViewController

			// If the link text field's value appears to be a valid URL, start browsing with it.
			if let urlText = linkTextField.text, url = extractValidHTTPURL(urlText) {
				vc.startURLString = url.absoluteString
			}
			vc.completionHandler = {selectedURL in
				if let url = selectedURL {
					self.linkTextField.text = url.absoluteString
				}
			}
		}
	}
}