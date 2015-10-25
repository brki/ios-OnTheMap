//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Brian on 23/09/15.
//  Copyright © 2015 truckin'. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
	@IBOutlet weak var usernameField: UITextField!
	@IBOutlet weak var passwordField: UITextField!
	@IBOutlet weak var loginButton: UIButton!
	@IBOutlet weak var loginForm: UIStackView!
	@IBOutlet weak var loginActivityIndicator: UIActivityIndicatorView!

	// The loginFormWrapper exists to avoid a problem of the left margin
	// of the text fields being shifted (and leftover text still appearing
	// between the left edge and the shifted margin) if the shake animation
	// is applied directly to the UIStackView.
	@IBOutlet weak var loginFormWrapper: UIView!

	var shakeAnimation: CAKeyframeAnimation?

	let udacityClient = UdacityClient.sharedInstance

	override func viewDidLoad() {
		super.viewDidLoad()
		// Round the corner of the login button:
		usernameField.layer.cornerRadius = 3
		passwordField.layer.cornerRadius = 3
	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)

		// Clear the password field before displaying view, so that when the user returns
		// to the login screen after having logged out, their password must be entered again.
		passwordField.text = ""
	}

	@IBAction func loginToUdacity(sender: UIButton) {
		view.endEditing(true)

		// Ensure username and password are present
		guard let username = usernameField.text where username.characters.count > 0 else {
			showErrorMessage("Please enter your username")
			return
		}
		let trimmedUsername = username.trim()
		guard trimmedUsername.characters.count > 0 else {
			showErrorMessage("Please enter a non-blank username")
			return
		}
		guard let password = passwordField.text where password.characters.count > 0 else {
			showErrorMessage("Please enter your password")
			return
		}

		loginButton.enabled = false
		loginActivityIndicator.startAnimating()
		udacityClient.authenticate(trimmedUsername, password: password) { success, error in
			on_main_queue {
				self.loginButton.enabled = true
				self.loginActivityIndicator.stopAnimating()
				if success {
					let viewController = self.storyboard!.instantiateViewControllerWithIdentifier("MainTabViewController")
					self.presentViewController(viewController, animated: true, completion: nil)
				} else {
					guard let err = error else {
						print("Unexpected authentication error: \(error)")
						self.showErrorMessage("Unknown error occurred during login")
						return
					}
					if err.code == UdacityClient.Error.InvalidLogin.rawValue {
						on_main_queue {
							self.shakeView()
						}
					} else {
						self.showErrorMessage("Error in login process", detail: err.localizedDescription)
					}
				}
			}
		}
	}

	@IBAction func viewTapped(sender: AnyObject) {
		view.endEditing(true)
	}

	func showErrorMessage(title: String?, detail: String? = nil, completionHandler: ((UIAlertAction) -> Void)? = nil) {
		on_main_queue {
			let alertController = UIAlertController(title: title, message: detail, preferredStyle: .Alert)
			alertController.addAction(
				UIAlertAction(title: "OK", style: .Default, handler: completionHandler)
			)
			self.presentViewController(alertController, animated: true, completion: nil)
		}
	}

	func shakeView() {
		// From http://stackoverflow.com/a/9371196/948341 :
		let anim = CAKeyframeAnimation(keyPath:"transform")
		shakeAnimation = anim
		anim.values = [
			NSValue(CATransform3D:CATransform3DMakeTranslation(-5, 0, 0)),
			NSValue(CATransform3D:CATransform3DMakeTranslation(5, 0, 0))
		]
		anim.autoreverses = true
		anim.repeatCount = 2
		anim.duration = 7/100
		loginFormWrapper.layer.addAnimation(anim, forKey:nil)
	}
}