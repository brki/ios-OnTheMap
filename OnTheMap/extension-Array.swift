//
//  extension-Array.swift
//  OnTheMap
//
//  Created by Brian on 18/10/15.
//  Copyright © 2015 truckin'. All rights reserved.
//

import Foundation

// From http://stackoverflow.com/a/24101606/948341 :
extension Array {
	func randomItem() -> Element {
		let index = Int(arc4random_uniform(UInt32(self.count)))
		return self[index]
	}
}