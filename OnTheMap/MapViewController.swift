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

// MARK: map view delegate

extension MapViewController: MKMapViewDelegate {
	func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
		let studentAnnotation = annotation as! StudentAnnotation
		let recentness = CGFloat(studentAnnotation.recentness)
		var pin: MKPinAnnotationView?
		pin = mapView.dequeueReusableAnnotationViewWithIdentifier("pin") as? MKPinAnnotationView
		if pin == nil {
			pin = MKPinAnnotationView(annotation: studentAnnotation, reuseIdentifier: "pin")
		}

		guard let mapPin = pin else {
			return nil
		}
		mapPin.annotation = studentAnnotation
		mapPin.canShowCallout = true
		mapPin.animatesDrop = true
		let dateString = DateFormatter.sharedInstance.localizedDateString(studentAnnotation.date)
		mapPin.detailCalloutAccessoryView = DetailCallout(labelTexts: [studentAnnotation.subtitle!, dateString])

		// Recent pins will be bright red, older ones faded red:
		let fade = (1 - recentness) / 1.5
		mapPin.pinTintColor = UIColor(red: 1, green: fade, blue: fade, alpha: 1)
		return mapPin
	}
}

