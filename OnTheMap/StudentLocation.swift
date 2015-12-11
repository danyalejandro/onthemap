//
//  StudentLocation.swift
//  OnTheMap
//
//  Created by Dany Cabrera Vargas on 10/10/15.
//  Copyright © 2015 Dany Alejandro Cabrera Vargas. All rights reserved.
//

import Foundation

struct StudentLocation {
	var createdAt: String! = ""
	var firstName: String! = ""
	var lastName: String! = ""
	var latitude: Float! = 0.0
	var longitude: Float! = 0.0
	var mapString: String! = ""
	var mediaURL: String! = ""
	var objectId: String! = ""
	var uniqueKey: String! = ""
	var updatedAt: String! = ""
	var updatedAtDate: String! = ""

	// Initializes from a dictionary
	init(values: NSDictionary? = nil) {
		if (values != nil) {
			createdAt = values!.valueForKey("createdAt") as! String!
			firstName = values!.valueForKey("firstName") as! String!
			lastName = values!.valueForKey("lastName") as! String!
			latitude = values!.valueForKey("latitude") as! Float!
			longitude = values!.valueForKey("longitude") as! Float!
			mapString = values!.valueForKey("mapString") as! String!
			mediaURL = values!.valueForKey("mediaURL") as! String!
			objectId = values!.valueForKey("objectId") as! String!
			uniqueKey = values!.valueForKey("uniqueKey") as! String!
			updatedAt = values!.valueForKey("updatedAt") as! String!
			if !updatedAt.isEmpty {
				let dateString = updatedAt.substringToIndex(updatedAt.startIndex.advancedBy(10))
				let hourString = updatedAt[updatedAt.startIndex.advancedBy(11)..<updatedAt.startIndex.advancedBy(19)]
				updatedAtDate = dateString + " " + hourString
			}
		}
	}

	// HELPER: TRUE if object is deemed empty
	func isEmpty() -> Bool {
		return (firstName == "" && objectId == "")
	}

	// HELPER: Builds a JSON string with this object's information, for POST purposes
	func jsonString() -> String {
		return "{\"uniqueKey\": \"\(uniqueKey)\", \"firstName\": \"\(firstName)\", \"lastName\": \"\(lastName)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}"
	}

	// HELPER: Prints object contents
	func printValues() {
		print("objectId = \(objectId)")
		print("uniqueKey = \(uniqueKey)")
		print("firstName = \(firstName)")
		print("lastName = \(lastName)")
		print("latitude = \(latitude)")
		print("longitude = \(longitude)")
		print("mapString = \(mapString)")
		print("mediaURL = \(mediaURL)")
		print("createdAt = \(createdAt)")
		print("updatedAt = \(updatedAt)")
		print("updatedAtDate = \(updatedAtDate)")
	}
}