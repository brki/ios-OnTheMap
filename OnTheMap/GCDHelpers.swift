//
//  GCDHelpers.swift
//  OnTheMap
//
//  Created by Brian on 07/10/15.
//  Copyright © 2015 truckin'. All rights reserved.
//

import Foundation

/**
Shortcut to dispatch a block to the main queue.
*/
func on_main_queue(dispatch_block: dispatch_block_t) {
	dispatch_async(dispatch_get_main_queue(), dispatch_block)
}