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

	var appearance = Appearance()

	/**
	Handles all tasks necessary at logout time.
	*/
	func onLogout() {
		// Clear the shared instance data:
		StudentLocationDataStore.sharedInstance.clearData()
	}

	/**
	Apply a consistent style to some interface elements.
	*/
	func application(application: UIApplication, willFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
		appearance.applyStyle()
		return true
	}
}

