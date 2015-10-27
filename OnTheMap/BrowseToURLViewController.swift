//
//  BrowseToURLViewController.swift
//  OnTheMap
//
//  Created by Brian on 27/10/15.
//  Copyright © 2015 truckin'. All rights reserved.
//

import UIKit
import WebKit

class BrowseToURLViewController: UIViewController {
	let webView = WKWebView()
	var startURLString = "https://duckduckgo.com"
	var completionHandler: ((NSURL?) -> Void)?

	@IBOutlet weak var webViewContainer: UIView!

	override func viewDidLoad() {
		addWebView()
	}

	func addWebView() {
		webView.translatesAutoresizingMaskIntoConstraints = false
		webViewContainer.addSubview(webView)
		webView.centerXAnchor.constraintEqualToAnchor(webViewContainer.centerXAnchor).active = true
		webView.centerYAnchor.constraintEqualToAnchor(webViewContainer.centerYAnchor).active = true
		let heightConstraint = NSLayoutConstraint(item: webView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: webViewContainer, attribute: NSLayoutAttribute.Height, multiplier: 1, constant: 0)
		webViewContainer.addConstraint(heightConstraint)
		let widthConstraint = NSLayoutConstraint(item: webView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: webViewContainer, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0)
		webViewContainer.addConstraint(widthConstraint)
//		webView.heightAnchor.constraintEqualToAnchor(webViewContainer.heightAnchor).active = true
//		webView.widthAnchor.constraintEqualToAnchor(webViewContainer.widthAnchor).active = true
		if let url = NSURL(string: startURLString) {
			let request = NSURLRequest(URL: url)
			webView.loadRequest(request)
		} else {
			print("addWebView: No valid url, startURLString is \"\(startURLString)\"")
		}
	}
}
