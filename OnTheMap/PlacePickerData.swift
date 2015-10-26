//
//  PlacePickerData.swift
//  OnTheMap
//
//  Created by Brian on 25/10/15.
//  Copyright © 2015 truckin'. All rights reserved.
//

import UIKit
import MapKit

/**
Data for picker view which is shown when more than one location is returned from forward geo search.

An empty row is maintained at the top and bottom of the list, so that the user can select a
no-action row (e.g. selecting the empty row does not initiate the transition to step 2).
*/
class PlacePickerData: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {

	var placemarks: [CLPlacemark?]!
	var placeSelectedHandler: ((CLPlacemark) -> Void)

	init(placemarks: [CLPlacemark], placeSelectedHandler: (CLPlacemark) -> Void) {

		self.placemarks = [nil]
		self.placemarks.appendContentsOf(placemarks.map { $0 })
		self.placemarks!.append(nil)
		self.placeSelectedHandler = placeSelectedHandler
		super.init()
	}

	func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
		return 1
	}

	func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return placemarks.count
	}

	func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		guard let place = placemarks[row] else {
			// Empty first or last row:
			return ""
		}
		return place.formattedAddress()
	}

	func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		guard let place = placemarks[row] else {
			// Empty first or last row selected, do nothing.
			return
		}
		self.placeSelectedHandler(place)
	}
}
