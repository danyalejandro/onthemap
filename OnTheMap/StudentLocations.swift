//
//  StudentLocations.swift
//  OnTheMap
//
//  Created by Dany Cabrera Vargas on 7/12/15.
//  Copyright © 2015 Dany Alejandro Cabrera Vargas. All rights reserved.
//

import Foundation

// Singleton Class that stores the studentLocations
class StudentLocations {
	var locations: [StudentLocation] = []

	static let sharedInstance = StudentLocations() // Singleton pattern

	private init() {

	}

	func clear() {
		locations.removeAll()
	}

	func add(dicLocation: NSDictionary) {
		locations.append(StudentLocation(values: dicLocation))
	}

	func count() -> Int {
		return locations.count
	}

	func atIndex(index: Int) -> StudentLocation {
		if (index >= 0 && index < count()) {
			return locations[index]
		}
		return StudentLocation()
	}
}