//
//  operators.swift
//  OnTheMap
//
//  Created by Brian on 12/10/15.
//  Copyright © 2015 truckin'. All rights reserved.
//

import Foundation

/**
Returns a copy of the left-side dictionary with the addition of the values from the right-side dictionary.

Existing values in the the left-side dictionary are overwritten if the right-side dictionary has the corresponding key.

["hello": "there", "goodbye": "now"] + ["hello": "world", "foo": "bar"] == ["hello": "world", "goodbye": "now", "foo": "bar"]
*/
func +<K, V> (var left: [K : V], right: [K : V]) -> [K: V] {
	for (k, v) in right { left[k] = v }
	return left
}