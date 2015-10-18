//
//  UdacityStudentInformation.swift
//  OnTheMap
//
//  Created by Brian on 18/10/15.
//  Copyright © 2015 truckin'. All rights reserved.
//

import Foundation

/**
Holds student information fetched from a call to Udacity's API for public user profile information.
*/
struct UdacityStudentInformation {
	let firstName: String
	let lastName: String
	var websiteURL: String?
}