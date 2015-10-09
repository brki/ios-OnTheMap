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

	var autoOpenAnnotationId: String?
	var annotationManager: AnnotationManager!

	override func viewDidLoad() {
		super.viewDidLoad()
		mapView.delegate = self
		annotationManager = AnnotationManager()
		// TODO perhaps: try to get user's most recent coordinates and set initial map region to a fairly large region
		//		mapView.region = MKCoordinateRegion(center: mapView.region.center, span: MKCoordinateSpan(latitudeDelta: 15, longitudeDelta: 15))
	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		refreshStudentAnnotations(foreceRefresh: false) { updated in
			self.autoOpenAnnotation()
		}
	}

	deinit {
		mapView.delegate = nil
	}

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		autoOpenAnnotation()
	}

	@IBAction func logout(sender: UIBarButtonItem) {
		UdacityClient.sharedInstance.logout() { result, error in
			guard error == nil else {
				self.showAlert("Logout error", message: error!.localizedDescription)
				return
			}
			on_main_queue {
				// TODO: cleanup data on logout

				self.dismissViewControllerAnimated(true, completion: nil)
			}
		}
	}

	@IBAction func refreshStudentLocations(sender: AnyObject? = nil) {
		refreshStudentAnnotations()
	}

	/**
	Open the annotation that has the uniqueStringId == self.autoOpenAnnotationId.
	*/
	func autoOpenAnnotation() {
		guard let annotationId = autoOpenAnnotationId else {
			return
		}
		autoOpenAnnotationId = nil
		for annotation in mapView.annotations {
			if let studentAnnotation = annotation as? StudentAnnotation where studentAnnotation.uniqueStringId == annotationId {
				mapView.selectAnnotation(studentAnnotation, animated: true)
			}
		}
	}

	/**
	Ensures the lateste student annotations are display
	
	:param: forceRefresh If true, the StudentInformation structures will be downloaded again.  If false, they will only be
			downloaded if none have already been downloaded.
	:param: postUpdateHandler handler to call after the annotation refresh fails or succeeds.  It ``updated`` parameter will
	        be set to true if the annotation refresh suceeded.
	*/
	func refreshStudentAnnotations(foreceRefresh forceRefresh: Bool = true, postUpdateHandler: ((updated: Bool) -> Void)? = nil) {
		refreshButton.enabled = false
		annotationManager.updateStudentAnnotations(foreceRefresh: forceRefresh) { addedLocations, removedLocations, error in
			guard let added = addedLocations, removed = removedLocations where error == nil else {
				self.showAlert("Unable to update locations", message: error?.localizedDescription ?? "Unknown error")
				postUpdateHandler?(updated: false)
				self.refreshButton.enabled = true
				return
			}
			on_main_queue {
				if removed.count > 0 {
					self.mapView.removeAnnotations(removed as [MKAnnotation])
				}
				if added.count > 0 {
					self.mapView.addAnnotations(added as [MKAnnotation])
				}
				self.refreshButton.enabled = true
			}
			postUpdateHandler?(updated: true)
		}
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
			on_main_queue {
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
			print("Failed to launch Safari with url: \(url)")
			return false
		}
		return true
	}
}