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

	@IBOutlet weak var URLBar: UITextField!
	@IBOutlet weak var webViewContainer: UIView!
	@IBOutlet weak var backButton: UIBarButtonItem!
	@IBOutlet weak var forwardButton: UIBarButtonItem!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!

	override func viewDidLoad() {
		addWebView()
		openURL(startURLString)
		// Allow user to use swipe gestures for forward / back navigation:
		webView.allowsBackForwardNavigationGestures = true

		// Assign delegates
		webView.navigationDelegate = self
		URLBar.delegate = self

		URLBar.text = startURLString
	}

	/**
	Add web view to container and make it fill out the space available in the webViewContainer view.
	*/
	func addWebView() {
		webView.translatesAutoresizingMaskIntoConstraints = false
		webViewContainer.addSubview(webView)
		webView.centerXAnchor.constraintEqualToAnchor(webViewContainer.centerXAnchor).active = true
		webView.centerYAnchor.constraintEqualToAnchor(webViewContainer.centerYAnchor).active = true
		webView.heightAnchor.constraintEqualToAnchor(webViewContainer.heightAnchor).active = true
		webView.widthAnchor.constraintEqualToAnchor(webViewContainer.widthAnchor).active = true
	}

	func openURL(urlString: String) {
		if let url = NSURL(string: urlString) {
			let request = NSURLRequest(URL: url)
			webView.loadRequest(request)
		} else {
			print("addWebView: No valid url, urlString is \"\(urlString)\"")
		}
	}

	@IBAction func backButtonPressed(sender: AnyObject) {
		if webView.canGoBack {
			webView.goBack()
		}
	}

	@IBAction func forwardButtonPressed(sender: AnyObject) {
		if webView.canGoForward {
			webView.goForward()
		}
	}

	@IBAction func openInSafari(sender: AnyObject) {
		guard let url = webView.URL else {
			print("Webview URL unexpectedly nil")
			return
		}
		if !UIApplication.sharedApplication().openURL(url) {
			print("Failed to launch Safari with url: \(url)")
		}
	}

	@IBAction func selectThisPage(sender: AnyObject) {
		completionHandler?(webView.URL)
		dismissViewControllerAnimated(true, completion: nil)
	}

	@IBAction func cancelPressed(sender: AnyObject) {
		dismissViewControllerAnimated(true, completion: nil)
	}
}

// MARK: WKNavigationDelegate

extension BrowseToURLViewController: WKNavigationDelegate {

	func webView(webView: WKWebView, didCommitNavigation navigation: WKNavigation!) {
		backButton.enabled = webView.canGoBack
		forwardButton.enabled = webView.canGoForward
		URLBar.text = webView.URL?.absoluteString
	}

	func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
		activityIndicator.startAnimating()
	}

	func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
		activityIndicator.stopAnimating()
	}

	func webView(webView: WKWebView, didFailNavigation navigation: WKNavigation!, withError error: NSError) {
		handleLoadingFailedWithError(error)
	}

	func webView(webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError) {
		handleLoadingFailedWithError(error)
	}
	
	func handleLoadingFailedWithError(error: NSError) {
		activityIndicator.stopAnimating()
		showAlert("Page load failed", message: error.localizedDescription)
	}
}

extension BrowseToURLViewController: UITextFieldDelegate {

	/**
	Open the URL that the user has entered.
	*/
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		if let urlString = textField.text {
			openURL(urlString)
		}
		textField.resignFirstResponder()
		return true
	}
}