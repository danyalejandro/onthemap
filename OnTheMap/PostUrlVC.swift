//
//  PostUrlVC.swift
//  OnTheMap
//
//  Created by Dany Cabrera Vargas on 11/10/15.
//  Copyright © 2015 Dany Alejandro Cabrera Vargas. All rights reserved.
//

import UIKit
import MapKit

class PostUrlVC: UIViewController, MKMapViewDelegate {

	var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
	var locationName: String! = ""
	let regionRadius: CLLocationDistance = 100000

	@IBOutlet weak var txtUrl: UITextField!
	@IBOutlet weak var map: MKMapView!
	@IBOutlet weak var btnSubmit: UIButton!

	override func viewDidLoad() {
		super.viewDidLoad()
	}

	override func viewWillAppear(animated: Bool) {
		let annotation = MKPointAnnotation()
		annotation.coordinate = coordinate
		annotation.title = locationName
		map.addAnnotation(annotation)
		map.selectAnnotation(annotation, animated: true)
		centerMapOnLocation()
	}

	@IBAction func btCancelTouch(sender: UIButton) {
		self.performSegueWithIdentifier("segUnwind", sender: self)
	}
	
	@IBAction func btnSubmitTouch(sender: UIButton) {
		// GUARD: locationText should not be empty
		guard (!txtUrl.text!.isEmpty) else {
			Alerts.showAlert(self, msg: "Please enter your URL.")
			return
		}

		// build student location object
		let userInfo = UdacityClient.sharedInstance.userInfo
		let studentLoc = StudentLocation()
		
		studentLoc.uniqueKey = userInfo.uid
		studentLoc.mapString = locationName
		studentLoc.mediaURL = txtUrl.text
		studentLoc.latitude = Float(coordinate.latitude)
		studentLoc.longitude = Float(coordinate.longitude)
		studentLoc.firstName = userInfo.first_name
		studentLoc.lastName = userInfo.last_name

		blockWhileLoading()

		// If this user has already placed a pin on the map, update it. If not, create a new one.

		if (ParseClient.sharedInstance.myLocation.isEmpty()) {
			// Create a new location
			ParseClient.sharedInstance.newLocation(studentLoc, callback: {(error: NSError?) in
				// GUARD: An error happened?
				guard (error == nil) else {
					dispatch_async(dispatch_get_main_queue(), {
						self.unblockAfterLoading()
						Alerts.showAlert(self, msg: String(error!.userInfo["userMessage"]!))
						print(error!.userInfo["debugMessage"]!)
					})
					return
				}

				// No errors -> return to tabbar view
				dispatch_async(dispatch_get_main_queue(), {
					self.unblockAfterLoading()
					Alerts.showAlert(self, msg: "The new location was successfully registered.", title: "Success", callback: {(alert: UIAlertAction!) in
						self.performSegueWithIdentifier("segUnwind", sender: self)
					})
					
				})
			})
		}
		else {
			// Update current location
			studentLoc.objectId = ParseClient.sharedInstance.myLocation.objectId

			ParseClient.sharedInstance.updateLocation(studentLoc, callback: {(error: NSError?) in
				// GUARD: An error happened?
				guard (error == nil) else {
					dispatch_async(dispatch_get_main_queue(), {
						self.unblockAfterLoading()
						Alerts.showAlert(self, msg: String(error!.userInfo["userMessage"]!))
						print(error!.userInfo["debugMessage"]!)
					})
					return
				}

				// No errors -> return to tabbar view
				dispatch_async(dispatch_get_main_queue(), {
					self.unblockAfterLoading()
					Alerts.showAlert(self, msg: "Your location was successfully updated.", title: "Success", callback: {(alert: UIAlertAction!) in
						self.performSegueWithIdentifier("segUnwind", sender: self)
					})

				})
			})

		}
	}

	func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
		let reuseId = "pin"

		var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView

		if (pinView == nil) {
			pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
			pinView!.canShowCallout = true
			pinView!.pinTintColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
			pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
		}
		else {
			pinView!.annotation = annotation
		}

		return pinView
	}

	func centerMapOnLocation() {
		let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate, regionRadius * 2.0, regionRadius * 2.0)
		map.setRegion(coordinateRegion, animated: true)
	}

	// Blocks controls and shows loading overlay
	func blockWhileLoading() {
		self.view.userInteractionEnabled = false
		btnSubmit.alpha = 0.5
		LoadingOverlay.shared.showOverlay(self.view) // show loading overlay
	}

	func unblockAfterLoading() {
		self.view.userInteractionEnabled = true
		btnSubmit.alpha = 1.0
		LoadingOverlay.shared.hideOverlay() // hide loading overlay
	}

}