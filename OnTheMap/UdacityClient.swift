//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Dany Cabrera Vargas on 7/10/15.
//  Copyright © 2015 Dany Alejandro Cabrera Vargas. All rights reserved.
//
import Foundation

class UdacityClient: NSObject {
	var session: NSURLSession
	var sid: NSString?
	var userInfo: UdacityUser = UdacityUser()

	static let sharedInstance = UdacityClient() // Singleton pattern

	private override init() {
		session = NSURLSession.sharedSession()
		sid = nil

		super.init()
	}

	// creates a new Udacity user session
	// Runs completion handler after trying to create sesion
	func createSession(username: String, password: String, callback: (sid: String?, cbError: NSError?) -> Void) {
		let url = "https://www.udacity.com/api/session"
		let postBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}"
		let req = Network.newRequest(url, type: ReqType.POST, jsonBody: postBody)

		Network.runRequest(session, request: req, offset: 5, completionHandler: {(result, error) in

			// GUARD: Was the request successfully run?
			guard (error == nil) else {
				callback(sid: nil, cbError: error)
				return
			}

			let resDict: NSDictionary = result as! NSDictionary

			// GUARD: Is the "session" key in parsedResult?
			guard let sessionData = resDict.valueForKey("session") as! NSDictionary? else {
				callback(sid: nil, cbError: NSError(domain: "createSession", code: 10, userInfo: [
					"debugMessage": "Cannot find key 'session' in \(result)",
					"userMessage": "There was a problem contacting the server."
					]))
				return
			}

			// GUARD: Is the "account" key in parsedResult?
			guard let accountData = resDict.valueForKey("account") as! NSDictionary? else {
				callback(sid: nil, cbError: NSError(domain: "createSession", code: 11, userInfo: [
					"debugMessage": "Cannot find key 'account' in \(result)",
					"userMessage": "There was a problem contacting the server."
					]))
				return
			}

			// Store session id and user id
			self.sid = sessionData.valueForKey("id")! as! String
			self.userInfo.uid = accountData.valueForKey("key")! as! String

			callback(sid: String(self.sid), cbError: nil)
		})
	}

	// Retrieves and stores current user information
	func getUserInfo(callback: (cbError: NSError?) -> Void) {
		let url = "https://www.udacity.com/api/users/\(userInfo.uid)"
		let req = Network.newRequest(url, type: ReqType.GET)

		Network.runRequest(session, request: req, offset: 5, completionHandler: {(result, error) in

			// GUARD: Was the request successfully run?
			guard (error == nil) else {
				callback(cbError: error)
				return
			}

			// GUARD: Is the "session" key in parsedResult?
			guard let userData = result!["user"] as! NSDictionary? else {
				callback(cbError: NSError(domain: "getUserInfo", code: 20, userInfo: [
					"debugMessage": "Cannot find key 'user' in \(result)",
					"userMessage": "There was a problem retrieving the user information."
					]))
				return
			}

			// Store udacity user information
			self.userInfo.last_name = userData["last_name"] as! String
			self.userInfo.first_name = userData["first_name"] as! String

			callback(cbError: nil)
		})
	}
	


	// ends session
	func logout(callback: (cbError: NSError?) -> Void) {
		let req = Network.newRequest("https://www.udacity.com/api/session", type: ReqType.DELETE)

		var xsrfCookie: NSHTTPCookie? = nil
		let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
		for cookie in sharedCookieStorage.cookies as [NSHTTPCookie]! {
			if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
		}
		if let xsrfCookie = xsrfCookie {
			req.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
		}

		Network.runRequest(session, request: req, offset: 5, completionHandler: {(result, error) in
			// GUARD: Was the request successfully run?
			guard (error == nil) else {
				callback(cbError: error)
				return
			}

			callback(cbError: nil)
		})
	}
}
