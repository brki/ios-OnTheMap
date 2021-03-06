//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Brian on 23/09/15.
//  Copyright © 2015 truckin'. All rights reserved.
//

import Foundation

class UdacityClient: WebClient {

	static let sharedInstance = UdacityClient(baseURL: "https://www.udacity.com/api")!

	var sessionID: String?
	var accountKey: String?

	/**
	Log in using Udacity username and password.
	*/
	func authenticate(username: String, password: String, completionHandler: (Bool, NSError?) -> Void) {
		let url = router.url(URLs.Session)!

		let bodyInfo = ["udacity": ["username": username, "password": password]]
		guard let body = objectToJsonString(bodyInfo) else {
			completionHandler(false, Error.JSONSerializationError.asNSError())
			return
		}

		udacityRequest(url, requestMethod: .POST, body: body) { jsonObject, response, error in

			// If jsonObject or response are nil, error will be an NSError.
			// Call completion hander with error:
			guard let jsonObject = jsonObject, response = response where error == nil else {
				completionHandler(false, error)
				return
			}

			// Handle response codes other than 200 (which represents success):
			guard response.statusCode >= 200 && response.statusCode < 300 else {
				if response.statusCode == 403 {
					completionHandler(false, Error.InvalidLogin.asNSError())
				} else {
					completionHandler(false, Error.UnexpectedResponseCode.asNSError(detail: "Response status code: \(response.statusCode)"))
				}
				return
			}

			if let json = jsonObject as? [String: AnyObject],
				session = json["session"] as? [String: AnyObject],
				sessionIDString = session["id"] as? String,
				account = json["account"] as? [String: AnyObject],
				key = account["key"] as? String {

					self.sessionID = sessionIDString
					self.accountKey = key
					completionHandler(true, nil)

			} else {
				completionHandler(false, Error.UnexpectedJSONStructure.asNSError())
			}
		}
	}

	/**
	Logout of the Udacity account.
	*/
	func logout(completionHandler: (Bool, NSError?) -> Void) {

		let url = router.url(URLs.Session)!
		var headers = [String: String]()

		var xsrfCookie: NSHTTPCookie? = nil
		let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
		for cookie in sharedCookieStorage.cookies as [NSHTTPCookie]! {
			if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
		}
		if let xsrfCookie = xsrfCookie {
			headers["X-XSRF-TOKEN"] = xsrfCookie.value
		}

		udacityRequest(url, requestMethod: .DELETE, headers: headers) { jsonObject, response, error in
			// If jsonObject or response are nil, error will be an NSError.
			// Call completion hander with error:
			guard let jsonObject = jsonObject, response = response where error == nil else {
				completionHandler(false, error)
				return
			}

			// Handle response codes other than 200 (which represents success):
			guard response.statusCode >= 200 && response.statusCode < 300 else {
				if response.statusCode == 403 {
					completionHandler(false, Error.InvalidLogin.asNSError())
				} else {
					completionHandler(false, Error.UnexpectedResponseCode.asNSError(detail: "Response status code: \(response.statusCode)"))
				}
				return
			}

			if let json = jsonObject as? [String: AnyObject] where json.indexForKey("session") != nil && json.count == 1 {
				self.accountKey = nil
				self.sessionID = nil
				completionHandler(true, nil)
			} else {
				completionHandler(false, Error.UnexpectedJSONStructure.asNSError())
			}

		}
	}

	/**
	Get the logged-in user's information.
	*/
	func selfInformation(completionHandler: (UdacityStudentInformation?, NSError?) -> Void) {
		guard let selfId = accountKey else {
			completionHandler(nil, Error.PreconditionNotMet.asNSError(detail: "Udacity account ID not available"))
			return
		}
		let url = router.url(URLs.UserInfo, pathParams: ["{id}": selfId])!

		udacityRequest(url, requestMethod: .GET) { jsonObject, response, error in

			// If jsonObject or response are nil, error will be an NSError.
			// Call completion hander with error:
			guard let jsonObject = jsonObject, response = response where error == nil else {
				completionHandler(nil, error)
				return
			}

			guard response.statusCode >= 200 && response.statusCode < 300 else {
				completionHandler(nil, Error.UnexpectedResponseCode.asNSError(detail: "Response status code: \(response.statusCode)"))
				return
			}

			if let json = jsonObject as? [String: AnyObject],
				user = json["user"] as? [String: AnyObject],
				firstName = user["first_name"] as? String,
				lastName = user["last_name"] as? String {
					let url = user["website_url"] as? String
					let selfInfo = UdacityStudentInformation(firstName: firstName, lastName: lastName, websiteURL: url)
					completionHandler(selfInfo, nil)
			} else {
				completionHandler(nil, Error.UnexpectedJSONStructure.asNSError())
			}
		}
	}
}

// MARK: Web service URLs and helper methods

extension UdacityClient {

	enum URLs: String, PathComponentProviding {
		case Session = "session"
		case UserInfo = "users/{id}"

		func pathComponent() -> String {
			return self.rawValue
		}
	}

	func dataPreprocessor(data: NSData) -> NSData {
		// Remove the first 5 characters which Udacity responses have as a security measure:
		return data.subdataWithRange(NSMakeRange(5, data.length - 5))
	}

	func udacityRequest(url: NSURL, requestMethod: MethodType, headers: [String: String]? = nil, body: String? = nil, completionHandler: (jsonObject: AnyObject?, response: NSHTTPURLResponse?, error: NSError?) -> Void) -> NSURLSessionDataTask {
		return makeJSONDataRequest(url, requestMethod: requestMethod, headers: headers, body: body, dataPreprocessor: dataPreprocessor, completionHandler: completionHandler)
	}
}