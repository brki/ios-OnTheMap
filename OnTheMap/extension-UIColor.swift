//
//  extension-UIColor.swift
//  OnTheMap
//
//  Created by Brian on 12/10/15.
//  Copyright © 2015 truckin'. All rights reserved.
//

import UIKit

extension UIColor {
	static func rgba(red: Double, _ green: Double, _ blue: Double, _ alpha: Double) -> UIColor {
		return UIColor(red: CGFloat(red) / 255, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: CGFloat(alpha))
	}

	static func rgb(red: Double, _ green: Double, _ blue: Double) -> UIColor {
		return rgba(red, green, blue, 1)
	}
}
