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

	// Contains the last-fetched student location information structs:
	var studentInformations: [StudentInformation]?

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

	/**
	Convenience method to get the most-recently fetched student info results.
	
	If no student info results have ever been fetched, then this method will
	do the initial fetching.
	*/
	func studentInfos(handler: ([StudentInformation]?, NSError?) -> Void) {
		if let studentInfos = studentInformations {
			handler(studentInfos, nil)
		} else {
			latestStudentInfos(handler)
		}
	}

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
			self.studentInformations = newStudentInfos
			handler(newStudentInfos, nil)
		}
	}
}
