//
//  AdaptViewToKeyboard.swift
//  OnTheMap
//
//  Created by Dany Cabrera Vargas on 8/12/15.
//  Copyright © 2015 Dany Alejandro Cabrera Vargas. All rights reserved.
//

import Foundation
import UIKit

class VCAdaptToKeyBoard : UIViewController {

	var tapRecognizer: UITapGestureRecognizer? = nil
	var keyboardAdjusted = false
	var lastKeyboardOffset : CGFloat = 0.0


	// invoke manually on viewDidLoad()
	func atkViewDidLoad() {
		tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
		tapRecognizer?.numberOfTapsRequired = 1
	}

	// invoke manually on viewWillAppear()
	func atkViewWillAppear() {
		self.addKeyboardDismissRecognizer()
		self.subscribeToKeyboardNotifications()
	}

	// invoke manually on viewWillDisappear()
	func atkViewWillDisappear() {
		self.removeKeyboardDismissRecognizer()
		self.unsubscribeToKeyboardNotifications()
	}

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
			lastKeyboardOffset = getKeyboardHeight(notification)
			self.view.superview?.frame = CGRectMake(0 , 0, self.view.frame.width, self.view.frame.height - lastKeyboardOffset)
			keyboardAdjusted = true
		}
	}

	func keyboardWillHide(notification: NSNotification) {

		if keyboardAdjusted == true {
			self.view.superview?.frame = CGRectMake(0 , 0, self.view.frame.width, self.view.frame.height + lastKeyboardOffset)
			keyboardAdjusted = false
		}
	}

	func getKeyboardHeight(notification: NSNotification) -> CGFloat {
		let userInfo = notification.userInfo
		let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
		return keyboardSize.CGRectValue().height
	}
}