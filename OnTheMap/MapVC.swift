//
//  MapVC.swift
//  OnTheMap
//
//  Created by Dany Cabrera Vargas on 8/10/15.
//  Copyright © 2015 Dany Alejandro Cabrera Vargas. All rights reserved.
//

import Foundation
import MapKit


import UIKit

class MapVC: UIViewController, MKMapViewDelegate, ReloadableProtocol {
	var annotations = [MKPointAnnotation]()

	@IBOutlet weak var map: MKMapView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
	}

	override func viewWillAppear(animated: Bool) {
		reloadLocations()
		super.viewWillAppear(animated)
	}

	func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
		let reuseId = "pin"

		var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)

		if pinView == nil {
			pinView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)

			pinView!.canShowCallout = true
			pinView!.image = UIImage(named: "student-icon")

			pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
		}
		else {
			pinView!.annotation = annotation
		}

		return pinView
	}


	func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
		if control == view.rightCalloutAccessoryView {
			let app = UIApplication.sharedApplication()
			app.openURL(NSURL(string: view.annotation!.subtitle!!)!)
		}
	}

	func reloadLocations() {
		blockWhileLoading()

		ParseClient.sharedInstance.loadLocations({(cbError: NSError?) -> Void in
			// GUARD: was there an error trying to reload data?
			guard (cbError == nil) else {
				dispatch_async(dispatch_get_main_queue(), {
					self.unblockAfterLoading()
					Alerts.showAlert(self, msg: String(cbError!.userInfo["userMessage"]!))
					print(cbError!.userInfo["debugMessage"])
				})
				return
			}

			// If no error occurred, reload map annotations
			dispatch_async(dispatch_get_main_queue(), {
				self.map.removeAnnotations(self.annotations)
				self.annotations.removeAll()

				for location in StudentLocations.sharedInstance.locations {
					let lat = CLLocationDegrees(location.latitude)
					let long = CLLocationDegrees(location.longitude)
					let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)

					let annotation = MKPointAnnotation()
					annotation.coordinate = coordinate
					annotation.title = "\(location.firstName) \(location.lastName)"
					annotation.subtitle = location.mediaURL
					self.annotations.append(annotation)
				}
				self.map.addAnnotations(self.annotations)
				self.unblockAfterLoading()
			})
		})
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
