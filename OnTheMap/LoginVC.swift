//
//  LoginVC.swift
//  OnTheMap
//
//  Created by Dany Cabrera Vargas on 7/10/15.
//  Copyright © 2015 Dany Alejandro Cabrera Vargas. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class LoginVC: UIViewController, FBSDKLoginButtonDelegate {

	@IBOutlet weak var txtEmail: UITextField!
	@IBOutlet weak var txtPassword: UITextField!
	@IBOutlet weak var lblError: UILabel!

	@IBOutlet weak var btnLogin: UIButton!
	@IBOutlet weak var btnSignup: UIButton!
	@IBOutlet weak var btnFbLogin: FBSDKLoginButton!

	var tapRecognizer: UITapGestureRecognizer? = nil
	var keyboardAdjusted = false
	var lastKeyboardOffset : CGFloat = 0.0

	override func viewDidLoad() {
		super.viewDidLoad()
		btnFbLogin.readPermissions = ["public_profile", "email"]


		/* Configure tap recognizer for Keyboard show/hide */
		tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
		tapRecognizer?.numberOfTapsRequired = 1
	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		self.addKeyboardDismissRecognizer()
		self.subscribeToKeyboardNotifications()
	}

	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		self.removeKeyboardDismissRecognizer()
		self.unsubscribeToKeyboardNotifications()
	}

	// On login button touch, initiate login procedure
	@IBAction func btnLoginTouch(sender: UIButton) {
		let email: String = txtEmail.text!
		let password: String = txtPassword.text!

		lblError.hidden = true
		self.view.endEditing(true)

		// Check for email & password values
		guard (email != "" && password != "") else {
			shakeError("Please enter your Udacity account email and password")
			return
		}

		blockWhileLoading()

		let udaClient = UdacityClient.sharedInstance
		udaClient.createSession(email, password: password, callback: {(sid: String?, error: NSError?) -> Void in
			// GUARD: An error happened?
			guard (error == nil) else {
				dispatch_async(dispatch_get_main_queue(), {
					self.unblockAfterLoading()
					self.shakeError(String(error!.userInfo["userMessage"]!))
					print(error!.userInfo["debugMessage"]!)
				})
				return
			}

			dispatch_async(dispatch_get_main_queue(), {
				self.retrieveUserInfo()
			})
		})
	}



	// Shake the window and show an error message
	func shakeError(message: String) {
		let animation:CAKeyframeAnimation = CAKeyframeAnimation(keyPath: "transform.translation.y")
		animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
		animation.duration = 0.6
		animation.values = [-20, 20, -10, 10, -5, 5, 0]
		self.view.layer.addAnimation(animation, forKey: "shake")

		lblError.text = message
		lblError.hidden = false
	}

	// Retrieve and store Udacity user information for later use
	func retrieveUserInfo() {
		UdacityClient.sharedInstance.getUserInfo({(error: NSError?) in
			// GUARD: An error happened?
			guard (error == nil) else {
				dispatch_async(dispatch_get_main_queue(), {
					self.unblockAfterLoading()
					Alerts.showAlert(self, msg: String(error!.userInfo["userMessage"]!))
					print(error!.userInfo["debugMessage"]!)
				})
				return
			}

			// No errors -> retrieve location info if exists
			dispatch_async(dispatch_get_main_queue(), {
				self.retrieveLocationInfo()
			})
		})
	}

	func retrieveLocationInfo() {
		print("retrieving user location")
		ParseClient.sharedInstance.searchLocation(UdacityClient.sharedInstance.userInfo.uid, callback: {(location: StudentLocation?, error: NSError?) in
			// GUARD: An error happened?
			guard (error == nil) else {
				dispatch_async(dispatch_get_main_queue(), {
					self.unblockAfterLoading()
					Alerts.showAlert(self, msg: String(error!.userInfo["userMessage"]!))
					print(error!.userInfo["debugMessage"]!)
				})
				return
			}

			// No errors -> show next view
			dispatch_async(dispatch_get_main_queue(), {
				self.txtPassword.text = ""
				self.unblockAfterLoading()
				let controller = self.storyboard!.instantiateViewControllerWithIdentifier("mapNavController") as! UINavigationController
				self.presentViewController(controller, animated: true, completion: nil)
			})
		})

	}


	// On Sign up button touch, open udacity sign up page
	@IBAction func btnSignupTouch(sender: UIButton) {
		UIApplication.sharedApplication().openURL(NSURL(string: "https://www.udacity.com/account/auth#!/signup")!)
	}

	// Blocks controls and shows loading overlay
	func blockWhileLoading() {
		self.view.userInteractionEnabled = false
		btnLogin.alpha = 0.5
		LoadingOverlay.shared.showOverlay(self.view) // show loading overlay
	}

	func unblockAfterLoading() {
		self.view.userInteractionEnabled = true
		btnLogin.alpha = 1.0
		LoadingOverlay.shared.hideOverlay() // hide loading overlay
	}
}

// LoginVC (Facebook delegate)
extension LoginVC {

	// On facebook login, creade udacity sesion (facebook started) and continue as expected
	func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
		lblError.hidden = true

		if (!result.isCancelled) {
			blockWhileLoading()

			let udaClient = UdacityClient.sharedInstance
			udaClient.createFbSession(result.token.tokenString, callback: {(sid: String?, error: NSError?) -> Void in
				// GUARD: An error happened?
				guard (error == nil) else {
					dispatch_async(dispatch_get_main_queue(), {
						self.unblockAfterLoading()

						// Custom error for when we cannot login into Udacity using Facebook
						var userMessage = String(error!.userInfo["userMessage"]!)
						if (error!.code == 2) {
							userMessage = "Unable to login into Udacity using Facebook session"
						}
						self.shakeError(userMessage)
						print(error!.userInfo["debugMessage"]!)

						// just in case, log out
						let loginManager = FBSDKLoginManager()
						loginManager.logOut()
					})
					return
				}

				dispatch_async(dispatch_get_main_queue(), {
					self.retrieveUserInfo()
				})
			})
		}
	}


	func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
		lblError.hidden = true
		print("Facebook session closed.")
	}
	
}


// LoginVC (Show/Hide Keyboard functionality)
extension LoginVC {

	func addKeyboardDismissRecognizer() {
		self.view.addGestureRecognizer(tapRecognizer!)
	}

	func removeKeyboardDismissRecognizer() {
		self.view.removeGestureRecognizer(tapRecognizer!)
	}

	func handleSingleTap(recognizer: UITapGestureRecognizer) {
		self.view.endEditing(true)
	}

	func subscribeToKeyboardNotifications() {
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
	}

	func unsubscribeToKeyboardNotifications() {
		NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
	}

	func keyboardWillShow(notification: NSNotification) {

		if keyboardAdjusted == false {
			lastKeyboardOffset = getKeyboardHeight(notification) / 2
			self.view.superview?.frame.origin.y -= lastKeyboardOffset
			keyboardAdjusted = true
		}
	}

	func keyboardWillHide(notification: NSNotification) {

		if keyboardAdjusted == true {
			self.view.superview?.frame.origin.y += lastKeyboardOffset
			keyboardAdjusted = false
		}
	}

	func getKeyboardHeight(notification: NSNotification) -> CGFloat {
		let userInfo = notification.userInfo
		let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
		return keyboardSize.CGRectValue().height
	}
}