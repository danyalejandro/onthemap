//
//  PostingVC.swift
//  OnTheMap
//
//  Created by Dany Cabrera Vargas on 11/10/15.
//  Copyright © 2015 Dany Alejandro Cabrera Vargas. All rights reserved.
//

import UIKit
import MapKit

class PostLocationVC: VCAdaptToKeyBoard, MKMapViewDelegate {
	@IBOutlet weak var txtLocation: UITextView!
	@IBOutlet weak var btnFind: UIButton!

	var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
	var locationText: String! = ""


    override func viewDidLoad() {
        super.viewDidLoad()
		atkViewDidLoad()
    }

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		atkViewWillAppear()
	}

	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		atkViewWillDisappear()
	}


	@IBAction func btnFindTouch(sender: UIButton) {
		locationText = txtLocation.text
		let gc = CLGeocoder()

		// GUARD: locationText should not be empty
		guard (!locationText.isEmpty) else {
			Alerts.showAlert(self, msg: "Please enter your location.")
			return
		}

		self.view.endEditing(true)
		blockWhileLoading()

		gc.geocodeAddressString(locationText, completionHandler: {(placemarks: [CLPlacemark]?, error: NSError?) in
			self.unblockAfterLoading()

			if (error != nil) {
				print("Geocode failed with error: \(error!.localizedDescription)")
				dispatch_async(dispatch_get_main_queue(), {
					Alerts.showAlert(self, msg: "Unable to determine location coordinates.")
				})
				return
			}
			else if (placemarks!.count > 0) {
				let placemark = placemarks![0]
				let location = placemark.location
				dispatch_async(dispatch_get_main_queue(), {
					self.coordinate = location!.coordinate
					self.performSegueWithIdentifier("segPostUrl", sender: self)
				})
			}
		})
	}

	@IBAction func btCancelTouch(sender: UIButton) {
		self.dismissViewControllerAnimated(true, completion: nil)
	}

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "segPostUrl" {
			let postUrlVC = segue.destinationViewController as! PostUrlVC
			postUrlVC.coordinate = self.coordinate
			postUrlVC.locationName = self.locationText
		}
	}

	// Blocks controls and shows loading overlay
	func blockWhileLoading() {
		self.view.userInteractionEnabled = false
		btnFind.alpha = 0.5
		LoadingOverlay.shared.showOverlay(self.view) // show loading overlay
	}

	func unblockAfterLoading() {
		self.view.userInteractionEnabled = true
		btnFind.alpha = 1.0
		LoadingOverlay.shared.hideOverlay() // hide loading overlay
	}
}