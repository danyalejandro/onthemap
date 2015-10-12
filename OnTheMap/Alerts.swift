//
//  Alerts.swift
//  OnTheMap
//
//  Created by Dany Cabrera Vargas on 11/10/15.
//  Copyright © 2015 Dany Alejandro Cabrera Vargas. All rights reserved.
//

import Foundation
import UIKit

class Alerts {
	static let sharedInstance = Alerts() // Singleton pattern

	private init() {

	}
	
	// HELPER: Shows a simple Alert view with a custom message
	static func showAlert(sender: UIViewController, msg: String, title: String = "Alert", callback: ((alert: UIAlertAction!) -> Void)? = nil) {
		let alertController = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.Alert)
		alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: callback))
		sender.presentViewController(alertController, animated: true, completion: nil)
	}
}