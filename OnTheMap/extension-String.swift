//
//  extension-String.swift
//  OnTheMap
//
//  Created by Brian on 18/10/15.
//  Copyright © 2015 truckin'. All rights reserved.
//

import Foundation

extension String {
	func trim() -> String {
		return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
	}
}