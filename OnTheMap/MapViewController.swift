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

	var parse = ParseClient.sharedInstance
//	var pins = MapPins()
//	var studentInfos: [StudentInformation]?

	override func viewDidLoad() {
		super.viewDidLoad()
		mapView.delegate = self
//		mapView.region = MKCoordinateRegion(center: mapView.region.center, span: MKCoordinateSpan(latitudeDelta: 15, longitudeDelta: 15))
	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
	}

	deinit {
		mapView.delegate = nil
	}

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)

		parse.latestStudentInfos() { studentInfos, error in
			guard let infos = studentInfos else {
				// TODO: handle error
				return
			}
			AnnotationManager.sharedInstance.updateAnnotationsWithStudentInformation(infos) { added, removed in
				if removed.count > 0 {
					dispatch_async(dispatch_get_main_queue()) {
						self.mapView.removeAnnotations(removed as [MKAnnotation])
					}
				}
				if added.count > 0 {
					dispatch_async(dispatch_get_main_queue()) {
						self.mapView.addAnnotations(added as [MKAnnotation])
					}
				}
			}
		}
	}

	override func didReceiveMemoryWarning() {
		// TODO: anything to do here?  Throwing away studentInfos perhaps not worth it.
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

// MARK: map view delegate

extension MapViewController: MKMapViewDelegate {
	// TODO: implement method to get annotation view, and set pin color
	func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
		let recentness = CGFloat((annotation as! StudentAnnotation).recentness)
		var pin: MKPinAnnotationView?
		pin = mapView.dequeueReusableAnnotationViewWithIdentifier("pin") as? MKPinAnnotationView
		if pin == nil {
			pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
			pin?.canShowCallout = true
			// perhaps TODO: use pin?.detailCalloutAccessoryView (which replaces the subtitle), and
			// use a vertical stack view with "student url" info and posted date.
			// For this, create a custom view.
		}

		guard let mapPin = pin else {
			return nil
		}

		mapPin.annotation = annotation
		mapPin.pinTintColor = UIColor(red: CGFloat(1), green: recentness, blue: CGFloat(recentness / 2), alpha: CGFloat(1))
		return mapPin
	}
}

