//
//  ParseClient.swift
//  OnTheMap
//
//  Created by Brian on 29/09/15.
//  Copyright © 2015 truckin'. All rights reserved.
//

import Foundation

class ParseClient: WebClient {

	static let sharedInstance = ParseClient(baseURL: ParseClient.baseURL)!

	let parseApplicationID = parseAPICredentials.applicationID
	let parseAPIKey = parseAPICredentials.APIKey

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


// MARK: Web service URLs and application-specific methods

extension ParseClient {

	static let baseURL = "https://api.parse.com/1/classes/"

	enum Path: String, PathComponentProviding {
		case StudentLocation = "StudentLocation"
		case StudentLocationUpdate = "StudentLocation/{objectId}"

		func pathComponent() -> String {
			return self.rawValue
		}
	}

	func getStudentLocations(page: Int = 1, perPage: Int = 100, order: String = "-updatedAt", completionHandler: (results: [[String: AnyObject]]?, error: NSError?) -> Void) {
		var params = [
			"order": order,
			"limit": String(perPage),
		]
		if page > 1 {
			params["skip"] = String((page-1) * perPage)
		}

		APIRequest(router.url(Path.StudentLocation, queryParams: params)!, requestMethod: .GET) { jsonObject, response, error in
			if let error = error {
				completionHandler(results: nil, error: error)
			} else if let json = jsonObject as? [String: AnyObject], results = json["results"] as? [[String: AnyObject]] {
				completionHandler(results: results, error: nil)
			} else {
				completionHandler(results: nil, error: Error.UnexpectedJSONStructure.asNSError())
			}
		}
	}
}

// MARK: StudentInformation fetching

extension ParseClient {

	func latestStudentInfos(handler: ([StudentInformation]?, NSError?) -> Void) {
		getStudentLocations() { results, error in
			guard let results = results else {
				if error == nil {
					handler(nil, NSError(domain: "ParseClient", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unknown error"]))
				} else {
					handler(nil, error)
				}
				return
			}
			var newStudentInfos = [StudentInformation]()
			for result in results {
				if let info = StudentInformation(values: result) {
					newStudentInfos.append(info)
				}
			}
			handler(newStudentInfos, nil)
		}
	}
}

// MARK: StudentInformation posting

extension ParseClient {

	/**
	Submit the user's provided location and associated information.

	The completion handler will be called with the Parse-generated objectId if successful, or with nil and and error if unsuccessful.
	*/
	func addLocation(uniqueKey: String, firstName: String, lastName: String, mapString: String, mediaURL: NSURL, latitude: Double, longitude: Double, completion: (objectId: String?, error: NSError?) -> Void) {

		let data = [
			"uniqueKey": uniqueKey,
			"firstName": firstName,
			"lastName": lastName,
			"mapString": mapString,
			"mediaURL": mediaURL.absoluteString,
			"latitude": latitude,
			"longitude": longitude,
		]
		let postURL = router.url(Path.StudentLocation)
		guard let body = objectToJsonString(data) else {
			completion(objectId: nil, error: Error.JSONSerializationError.asNSError("ParseClient", detail: "Unable to encode data for posting"))
			return
		}
		APIRequest(postURL!, requestMethod: .POST, body: body) { jsonObject, response, error in
			guard error == nil else {
				completion(objectId: nil, error: error)
				return
			}
			guard let json = jsonObject, objectId = json["objectId"] as? String else {
				completion(objectId: nil, error: Error.UnexpectedJSONStructure.asNSError())
				return
			}
			completion(objectId: objectId, error: nil)
		}
	}
}
