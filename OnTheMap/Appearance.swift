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
		"background": UIColor.rgb(238, 255, 236),
		"textFieldBackground": UIColor.rgb(220, 222, 224),
	]
}

class Appearance {

	var theme = GreenTheme()

	func applyStyle() {
//		if let bg = theme.colors["background"] {
//			UIView.appearance().backgroundColor = bg
//		}
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