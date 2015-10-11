//
//  AppDelegate.swift
//  OnTheMap
//
//  Created by Brian on 23/09/15.
//  Copyright © 2015 truckin'. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	var dataStore = StudentLocationDataStore()

	func onLogout() {
		dataStore = StudentLocationDataStore()
	}
}

