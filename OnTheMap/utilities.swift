//
//  utilities.swift
//  OnTheMap
//
//  Created by Brian on 08/10/15.
//  Copyright © 2015 truckin'. All rights reserved.
//

import UIKit

/**
Try to extract a valid URL from the given string.  If no protocol is present
in the given string, it will be prefixed with http://.

Note that this fails for some potentially valid URL names.  For example,
your DNS server might provide you an IP address for http://foobar .

This method, written for the Udacity ios networking course, assumes
that a valid hostname with a toplevel domain (e.g. foo.com) is required.
*/
func extractValidHTTPURL(URLString: String) -> NSURL? {
	guard URLString.characters.count > 3 else {
		return nil
	}

	var url: NSURL?
	url = NSURL(string: URLString)

	if url == nil || url!.scheme == "" {
		// Make an effort to create a valid URL, assuming http protocol:
		url = NSURL(string: "http://" + URLString)
	}

	guard let validURL = url, host = validURL.host where (validURL.scheme == "http" || validURL.scheme == "https") else {
		return nil
	}

	// An imperfect hostname regex check (but useful for weeding out many invalid values):
	guard host.rangeOfString("[a-zA-Z0-9-]\\.[a-zA-Z-]{1,}[a-zA-Z]$", options: .RegularExpressionSearch) != nil else {
		return nil
	}

	return validURL
}

