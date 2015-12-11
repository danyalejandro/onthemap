//
//  ListVC.swift
//  OnTheMap
//
//  Created by Dany Cabrera Vargas on 10/10/15.
//  Copyright © 2015 Dany Alejandro Cabrera Vargas. All rights reserved.
//

import UIKit

class ListVC: UITableViewController, ReloadableProtocol {
	@IBOutlet var listTable: UITableView!

	override func viewDidLoad() {
		super.viewDidLoad()

		tableView.delegate = self
		tableView.dataSource = self
	}

	override func viewWillAppear(animated: Bool) {
		if (StudentLocations.sharedInstance.count() == 0) {
			reloadLocations()
		}
		super.viewWillAppear(animated)
	}

	// Reloads locations in ParseClient and updates table contents
	func reloadLocations() {
		blockWhileLoading()

		ParseClient.sharedInstance.loadLocations {(cbError: NSError?) -> Void in
			// GUARD: was there an error trying to reload data?
			guard (cbError == nil) else {
				dispatch_async(dispatch_get_main_queue(), {
					self.unblockAfterLoading()
					Alerts.showAlert(self, msg: String(cbError!.userInfo["userMessage"]!))
					print(cbError!.userInfo["debugMessage"])
				})
				return
			}

			// If no error occurred, reload table
			dispatch_async(dispatch_get_main_queue(), {
				self.listTable.reloadData()
				self.unblockAfterLoading()
			})
		}
	}
	
	func blockWhileLoading() {
		let tbc = self.tabBarController as! TabBarC
		tbc.blockControls()
		LoadingOverlay.shared.showOverlay(self.view) // show loading overlay
	}

	func unblockAfterLoading() {
		let tbc = self.tabBarController as! TabBarC
		tbc.unblockControls()
		LoadingOverlay.shared.hideOverlay() // hide loading overlay
	}
}


// UI Table View Functionality
extension ListVC {
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}

	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return StudentLocations.sharedInstance.count()
	}

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("listCell", forIndexPath: indexPath) as! ListCell

		let row = indexPath.row
		let location: StudentLocation = StudentLocations.sharedInstance.atIndex(row)
		cell.lblName?.text = location.firstName + " " + location.lastName
		cell.lblUptaded?.text = location.updatedAtDate
		cell.lblUrl?.text = location.mediaURL

		return cell
	}

	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let row = indexPath.row
		let location: StudentLocation = StudentLocations.sharedInstance.atIndex(row)
		let url: String! = location.mediaURL
		if (!url.isEmpty) {
			UIApplication.sharedApplication().openURL(NSURL(string: url)!)
		}
	}
}
