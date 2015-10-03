//
//  ParseClient.swift
//  OnTheMap
//
//  Created by Brian on 29/09/15.
//  Copyright © 2015 truckin'. All rights reserved.
//

import Foundation

class ParseClient: WebClient {

	static let sharedInstance = ParseClient(baseURL: "https://api.parse.com/1/classes/")!

	let parseApplicationID = parseAPICredentials.applicationID
	let parseAPIKey = parseAPICredentials.APIKey

	func getStudentLocations(page: Int = 1, perPage: Int = 100, order: String = "-updatedAt", completionHandler: (results: [[String: AnyObject]]?, error: NSError?) -> Void) {
		var params = [
			"order": order,
			"limit": String(perPage),
		]
		if page > 1 {
			params["skip"] = String((page-1) * perPage)
		}

		APIRequest(router.url(URL.StudentLocation, params: params)!, requestMethod: .GET) { jsonObject, response, error in
			if let json = jsonObject as? [String: AnyObject],
				results = json["results"] as? [[String: AnyObject]] {
					completionHandler(results: results, error: nil)
			} else {
				completionHandler(results: nil, error: Error.UnexpectedJSONStructure.asNSError())
			}
		}
	}
}


// MARK: Web service URLs and helper methods

extension ParseClient {
	enum URL: String, PathComponentProviding {
		case StudentLocation = "StudentLocation"
		case StudentLocationUpdate = "StudentLocation/{objectId}"

		func pathComponent() -> String {
			return self.rawValue
		}
	}

	/**
	Add the Parse application headers and make the request
	*/
	func APIRequest(url: NSURL, requestMethod: MethodType, var headers: [String: String]? = nil, body: String? = nil, completionHandler: ((jsonObject: AnyObject?, response: NSURLResponse?, error: NSError?) -> Void)? = nil) -> NSURLSessionDataTask {

		if headers == nil {
			headers = [String: String]()
		}
		headers!["X-Parse-Application-Id"] = parseApplicationID
		headers!["X-Parse-REST-API-Key"] = parseAPIKey

		return makeJSONDataRequest(url, requestMethod: requestMethod, headers: headers, body: body, completionHandler: completionHandler)
	}
}