//
//  MapViewController
//  OnTheMap
//
//  Created by Brian on 23/09/15.
//  Copyright © 2015 truckin'. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var refreshButton: UIBarButtonItem!

	var parse = ParseClient.sharedInstance

	override func viewDidLoad() {
		super.viewDidLoad()
		mapView.delegate = self
		//		mapView.region = MKCoordinateRegion(center: mapView.region.center, span: MKCoordinateSpan(latitudeDelta: 15, longitudeDelta: 15))
	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		refreshStudentLocations()
	}

	deinit {
		mapView.delegate = nil
	}

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)

	}

	override func didReceiveMemoryWarning() {
		// TODO: anything to do here?  Throwing away studentInfos perhaps not worth it.
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	@IBAction func logout(sender: UIBarButtonItem) {
		UdacityClient.sharedInstance.logout() { result, error in
			on_main_queue() {
				guard error == nil else {
					self.showAlert("Logout error", message: error!.localizedDescription)
					return
				}
				self.dismissViewControllerAnimated(true, completion: nil)
			}
		}
	}

	@IBAction func refreshStudentLocations(sender: AnyObject? = nil) {
		refreshButton.enabled = false
		parse.latestStudentInfos() { studentInfos, error in
			on_main_queue() {
				self.refreshButton.enabled = true
			}
			guard let infos = studentInfos else {
				on_main_queue() {
					self.showAlert("Unable to update locations", message: error?.localizedDescription ?? "Unknown error")
				}
				return
			}
			AnnotationManager.sharedInstance.updateAnnotationsWithStudentInformation(infos) { added, removed in
				if removed.count > 0 {
					on_main_queue() {
						self.mapView.removeAnnotations(removed as [MKAnnotation])
					}
				}
				if added.count > 0 {
					on_main_queue() {
						self.mapView.addAnnotations(added as [MKAnnotation])
					}
				}
			}
		}
	}

	func showAlert(title: String?, message: String?) {
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
		alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
		presentViewController(alertController, animated: true, completion: nil)
	}


}

// MARK: MKMapViewDelegate methods

extension MapViewController: MKMapViewDelegate {

	func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
		let studentAnnotation = annotation as! StudentAnnotation
		let recentness = CGFloat(studentAnnotation.recentness)
		var mapPin = mapView.dequeueReusableAnnotationViewWithIdentifier("pin") as? MKPinAnnotationView
		if mapPin != nil {
			mapPin!.annotation = studentAnnotation
		} else {
			mapPin = MKPinAnnotationView(annotation: studentAnnotation, reuseIdentifier: "pin")
			if let pin = mapPin {
				pin.canShowCallout = true
				pin.animatesDrop = true
				let button = UIButton(type: .DetailDisclosure)
				button.userInteractionEnabled = false
				pin.rightCalloutAccessoryView = button
			}
		}

		guard let pin = mapPin else {
			return nil
		}

		// Add custom detail view
		let dateString = DateFormatter.sharedInstance.localizedDateString(studentAnnotation.date)
		pin.detailCalloutAccessoryView = DetailCallout(labelTexts: [studentAnnotation.subtitle!, dateString])

		// Recent pins will be bright red, older ones faded out a bit:
		let fade = (1 - recentness) / 1.5
		pin.pinTintColor = UIColor(red: 1, green: fade, blue: fade, alpha: 1)
		return pin
	}

	func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
		view.addGestureRecognizer(
			UITapGestureRecognizer(target: self, action: "annotationViewTapped:")
		)
	}

	func mapView(mapView: MKMapView, didDeselectAnnotationView view: MKAnnotationView) {
		removeTapGestureRecognizers(view)
	}
}

// MARK: annotation callout view selected / deselected handlers
extension MapViewController {

	/**
	Trigger the opening of the URL contained in the StudentAnnotation.
	*/
	func annotationViewTapped(sender: UITapGestureRecognizer) {
		if let view = sender.view as? MKAnnotationView where view.selected == true, let annotation = view.annotation as? StudentAnnotation {
			on_main_queue() {
				if !self.openAnnotationURL(annotation) {
					// Opening failed because there is no valid URL.  No need to try again if user taps again.
					self.removeTapGestureRecognizers(view)
				}
			}
		}
	}

	/**
	Remove all tap gesture recognizers from the provided view.
	*/
	func removeTapGestureRecognizers(view: MKAnnotationView) {
		if let gestureRecognizers = view.gestureRecognizers {
			for recognizer in gestureRecognizers {
				if let tapRecognizer = recognizer as? UITapGestureRecognizer {
					view.removeGestureRecognizer(tapRecognizer)
				}
			}
		}
	}

	/**
	Tries to open the URL present in the annotation.
	*/
	func openAnnotationURL(annotation: StudentAnnotation) -> Bool {
		guard let urlString = annotation.subtitle, url = extractValidHTTPURL(urlString) else {
			print("Missing or invalid URL, not opening: \"\(annotation.subtitle)\"")
			return false
		}
		if !UIApplication.sharedApplication().openURL(url) {
			print("Failed to launch safari with url: \(url)")
			return false
		}
		return true
	}

	/**
	Try to extract a valid URL from the given string.  If no protocol is present
	in the given string, it will be prefixed with http://.

	Note that this may return a url that is not valid in a particular environment,
	but that could be a valid URL in some environments.  For example,
	http://foo is a valid URL, and could actually resolve to a valid resource,
	but for most people it will not.
	*/
	func extractValidHTTPURL(URLString: String) -> NSURL? {
		guard URLString.characters.count > 0 else {
			return nil
		}
		var url: NSURL?
		url = NSURL(string: URLString)

		if url == nil || url!.scheme == "" {
			// Make an effort to create a valid URL, assuming http protocol:
			url = NSURL(string: "http://" + URLString)
		}

		guard let validURL = url where validURL.host != nil && (validURL.scheme == "http" || validURL.scheme == "https") else {
			return nil
		}

		return validURL
	}
}