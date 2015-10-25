//
//  extension-CLPlacemark.swift
//  OnTheMap
//
//  Created by Brian on 25/10/15.
//  Copyright © 2015 truckin'. All rights reserved.
//

import MapKit

extension CLPlacemark {
	func formattedAddress() -> String {
		if let addressLines = self.addressDictionary?["FormattedAddressLines"] as? [String] {
			return addressLines.joinWithSeparator(", ")
		}
		return self.name ?? "Unknown"
	}
}
