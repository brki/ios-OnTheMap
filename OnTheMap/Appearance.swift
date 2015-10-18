//
//  Appearance.swift
//  OnTheMap
//
//  Created by Brian on 12/10/15.
//  Copyright © 2015 truckin'. All rights reserved.
//

import UIKit

protocol Theme {
	var colors: [String: UIColor] { get }
}

struct GreenTheme: Theme {

	var colors = [
		"tabBarTint": UIColor.rgb(17, 161, 29),
		"buttonActiveText": UIColor.rgb(17, 161, 29),
		"textFieldBackground": UIColor.rgb(220, 222, 224),
		// Unfortunately it doesn't work to just set the background color for all views, but here
		// are the RGB values for the light green backgound:
		"background": UIColor.rgb(238, 255, 236),
	]
}

class Appearance {

	var theme = GreenTheme()

	func applyStyle() {
		if let tint = theme.colors["tabBarTint"] {
			UITabBar.appearance().tintColor = tint
			UITextField.appearance().tintColor = tint
		}
		if let tint = theme.colors["buttonActiveText"] {
			UIButton.appearance().tintColor = tint
		}
		if let color = theme.colors["textFieldBackground"] {
			UITextField.appearance().backgroundColor = color
		}
	}
}