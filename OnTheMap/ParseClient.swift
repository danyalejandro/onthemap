//
//  ParseAPI.swift
//  OnTheMap
//
//  Created by Dany Cabrera Vargas on 10/10/15.
//  Copyright © 2015 Dany Alejandro Cabrera Vargas. All rights reserved.
//
import Foundation

class ParseClient: NSObject {
	var session: NSURLSession
	var apiKey: String! = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
	var appId: String! = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
	var studentLocations: [StudentLocation] = []
	var myLocation: StudentLocation = StudentLocation()

	static let sharedInstance = ParseClient() // Singleton pattern

	private override init() {
		session = NSURLSession.sharedSession()
		super.init()
	}

	// Loads 100 most recent locations and stores them in the singleton
	func loadLocations(callback: (cbError: NSError?) -> Void) {
		let queryData = ["limit": 100, "order": "-updatedAt"]
		let url = "https://api.parse.com/1/classes/StudentLocation"

		let req = Network.newRequest(url, type: ReqType.GET, query: queryData)
		addMandatoryValues(req)

		Network.runRequest(session, request: req, completionHandler: {(result, error) in
			// GUARD: Was the request successfully run?
			guard (error == nil) else {
				callback(cbError: error)
				return
			}
			
			// Convert result into an array of StudentLocation objects
			let dicResult = result as! NSDictionary
			let arrayDicts = dicResult.valueForKey("results") as! [NSDictionary]

			for dicLocation in arrayDicts {
				self.studentLocations.append(StudentLocation(values: dicLocation))
			}

			callback(cbError: nil)
		})
	}

	// Posts a new student location to the server
	func newLocation(location: StudentLocation, callback: (cbError: NSError?) -> Void) {
		let url = "https://api.parse.com/1/classes/StudentLocation"

		let req = Network.newRequest(url, type: ReqType.POST, jsonBody: location.jsonString())
		addMandatoryValues(req)

		Network.runRequest(session, request: req, completionHandler: {(result, error) in
			// GUARD: Was the request successfully run?
			guard (error == nil) else {
				callback(cbError: error)
				return
			}

			let resDict: NSDictionary = result as! NSDictionary

			// GUARD: Is the "objectId" key in the parsedResult?
			guard let objectId = resDict.valueForKey("objectId") as! String? else {
				callback(cbError: NSError(domain: "newLocation", code: 30, userInfo: [
					"debugMessage": "Cannot find key 'objectId' in \(result)",
					"userMessage": "A problem occurred while registering the new location."
					]))
				return
			}

			location.objectId = objectId
			location.createdAt = resDict.valueForKey("createdAt") as! String
			self.myLocation = location

			callback(cbError: nil)
		})
	}

	// Updates the student location with its specified objectId
	func updateLocation(location: StudentLocation, callback: (cbError: NSError?) -> Void) {
		let url = "https://api.parse.com/1/classes/StudentLocation/\(location.objectId)"

		let req = Network.newRequest(url, type: ReqType.PUT, jsonBody: location.jsonString())
		addMandatoryValues(req)

		Network.runRequest(session, request: req, completionHandler: {(result, error) in
			// GUARD: Was the request successfully run?
			guard (error == nil) else {
				callback(cbError: error)
				return
			}

			let resDict: NSDictionary = result as! NSDictionary

			// GUARD: Is the "objectId" key in the parsedResult?
			guard let _ = resDict.valueForKey("updatedAt") as! String? else {
				callback(cbError: NSError(domain: "updateLocation", code: 40, userInfo: [
					"debugMessage": "Cannot find key 'updatedAt' in \(result)",
					"userMessage": "A problem occurred while updating the location."
					]))
				return
			}

			callback(cbError: nil)
		})
	}

	// Loads a student location from the server, given the user id
	func searchLocation(uid: String, callback: (location: StudentLocation?, cbError: NSError?) -> Void) {
		let url = "https://api.parse.com/1/classes/StudentLocation"
		let req = Network.newRequest(url, type: ReqType.GET, query: ["where": "{\"uniqueKey\":\"\(uid)\"}"])
		addMandatoryValues(req)

		Network.runRequest(session, request: req, completionHandler: {(result, error) in
			// GUARD: Was the request successfully run?
			guard (error == nil) else {
				callback(location: nil, cbError: error)
				return
			}

			let resDict: NSDictionary = result as! NSDictionary

			// GUARD: Did the service return an error?
			guard (resDict.valueForKey("error") == nil) else {
				let errorDesc = resDict.valueForKey("error") as! String
				callback(location: nil, cbError: NSError(domain: "searchLocation", code: 31, userInfo: [
					"debugMessage": "The server returned an error: \(errorDesc)",
					"userMessage": "A problem occurred while loading your location."
					]))
				return
			}

			// GUARD: Did the service return results? If no error or results, return nil
			guard let locationsFound = resDict.valueForKey("results") else {
				callback(location: nil, cbError: nil)
				return
			}

			self.myLocation = StudentLocation(values: (locationsFound[0] as! NSDictionary))
			callback(location: self.myLocation, cbError: nil)
		})

	}

	// HELPER: Appends mandatory Parse values to the request
	func addMandatoryValues(req: NSMutableURLRequest) {
		req.addValue(appId, forHTTPHeaderField: "X-Parse-Application-Id")
		req.addValue(apiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
	}
}
