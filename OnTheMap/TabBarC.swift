//
//  TabBarC.swift
//  OnTheMap
//
//  Created by Dany Cabrera Vargas on 8/10/15.
//  Copyright © 2015 Dany Alejandro Cabrera Vargas. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class TabBarC: UITabBarController {

	override func viewDidLoad() {
		super.viewDidLoad()

		let btnAdd = UIBarButtonItem(image: UIImage(named: "pin-icon"), style: .Plain, target: self, action: "postPin")
		let btnRefresh = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "refresh")
		let btnLogout = UIBarButtonItem(title: "Logout", style: .Plain, target: self, action: "logout")

		self.navigationItem.leftBarButtonItems = [btnLogout]
		self.navigationItem.rightBarButtonItems = [btnRefresh, btnAdd]
	}

	override func viewWillAppear(animated: Bool) {

		super.viewWillAppear(animated)
	}

	// Shows the "add new pin" view
	func postPin() {
		let controller = self.storyboard!.instantiateViewControllerWithIdentifier("postLocation") as! PostLocationVC
		self.presentViewController(controller, animated: true, completion: nil)
	}

	// Ends user session
	func logout() {
		(selectedViewController as! ReloadableProtocol).blockWhileLoading()

		// If there's a facebook session, terminate it as well
		let loginManager = FBSDKLoginManager()
		loginManager.logOut()

		UdacityClient.sharedInstance.logout {(error: NSError?) -> Void in
			// GUARD: was there an error trying to end user session?
			guard (error == nil) else {
				dispatch_async(dispatch_get_main_queue(), {
					let visibleVC = self.selectedViewController as! ReloadableProtocol
					visibleVC.unblockAfterLoading()
					Alerts.showAlert(self.selectedViewController!, msg: String(error!.userInfo["userMessage"]!))
					print(error!.userInfo["debugMessage"])
				})
				return
			}

			// If no error occurred, dismiss view and return to login view
			dispatch_async(dispatch_get_main_queue(), {
				(self.selectedViewController as! ReloadableProtocol).unblockAfterLoading()
				self.dismissViewControllerAnimated(true, completion: nil)
			})

		}
	}

	//reload current view
	func refresh() {
		(selectedViewController as! ReloadableProtocol).reloadLocations()
	}

	func blockControls() {
		self.navigationController?.navigationBar.userInteractionEnabled = false
		self.view.userInteractionEnabled = false
	}

	func unblockControls() {
		self.navigationController?.navigationBar.userInteractionEnabled = true
		self.view.userInteractionEnabled = true
	}

	@IBAction func unwindToTBVC(segue: UIStoryboardSegue) {
	}
}
