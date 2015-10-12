//
//  Network.swift
//  OnTheMap
//
//  Created by Dany Cabrera Vargas on 7/10/15.
//  Copyright © 2015 Dany Alejandro Cabrera Vargas. All rights reserved.
//

import Foundation

enum ReqType {
	case GET
	case POST
	case DELETE
	case PUT
}

class Network {

	// executes the request and runs the completion handler
	// if an error occurrs, stops and runs the completion handler with a NSError describing the error (debugMessage for developers, userMessage for users)
	static func runRequest(session: NSURLSession, request: NSMutableURLRequest, offset: Int! = 0,  completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
		let task = session.dataTaskWithRequest(request) {(data, response, error) in
			/* GUARD: Was there an error? */
			guard (error == nil) else {
				completionHandler(result: nil, error: NSError(domain: "request", code: 1, userInfo: [
					"debugMessage": "There was an error with your request: \(error).",
					"userMessage": "There was a problem contacting the server."
				]))
				return
			}

			/* GUARD: Did we get a successful 2XX response? */
			guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
				var debugMsg: String! = "Your request returned an invalid response!"
				var userMsg: String! = "There was a problem contacting the server."

				if let response = response as? NSHTTPURLResponse {
					debugMsg = "Your request returned an invalid response! Status code: \(response.statusCode)!"
					if (response.statusCode == 403) {
						userMsg = "Invalid credentials."
					}

				} else if let response = response {
					debugMsg = "Your request returned an invalid response! Response: \(response)!"
				}

				completionHandler(result: nil, error: NSError(domain: "request", code: 2, userInfo: [
					"debugMessage": debugMsg,
					"userMessage": userMsg
				]))
				return
			}

			/* GUARD: Was there any data returned? */
			guard let data = data else {
				completionHandler(result: nil, error: NSError(domain: "request", code: 3, userInfo: [
					"debugMessage": "No data was returned by the request!",
					"userMessage": "There was a problem contacting the server."
				]))
				return
			}

			var data2: NSData!
			if (offset > 0) {
				data2 = data.subdataWithRange(NSMakeRange(offset, data.length - offset)) /* subset response data! */
			} else {
				data2 = data
			}

			//print(NSString(data: data2, encoding: NSUTF8StringEncoding))

			/* 5. Parse the data */
			let parsedResult: AnyObject!
			do {
				parsedResult = try NSJSONSerialization.JSONObjectWithData(data2, options: .AllowFragments)
			} catch {
				completionHandler(result: nil, error: NSError(domain: "request", code: 4, userInfo: [
					"debugMessage": "Could not parse the data as JSON: '\(data2)'",
					"userMessage": "There was a problem contacting the server."
				]))
				return
			}

			// Did an error happen?
			guard (parsedResult.valueForKey("error") == nil) else {
				let errorMsg = parsedResult.valueForKey("error")
				completionHandler(result: nil, error: NSError(domain: "request", code: 5, userInfo: [
					"debugMessage": "The server returned an error: '\(errorMsg)'",
					"userMessage": "There was a problem contacting the server."
				]))
				return
			}

			completionHandler(result: parsedResult, error: nil)
		}
		
		task.resume()
	}

	// prepares a POST type NSMutableURLRequest
	static func newRequest(url: String!, type: ReqType, query: [String : AnyObject]? = nil, jsonBody: String? = nil) -> NSMutableURLRequest {
		let urlObj = NSURLComponents(string: url)!


		var q: String! = ""
		if (query != nil) {
			q = escapedParameters(query!)
			urlObj.query = q
		}

		let request = NSMutableURLRequest(URL: urlObj.URL!)
		//print("url: \(urlObj.URL)")

		switch (type) {
		case .GET:
			request.HTTPMethod = "GET"
		case .POST:
			request.HTTPMethod = "POST"
			request.addValue("application/json", forHTTPHeaderField: "Accept")
			request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		case .DELETE:
			request.HTTPMethod = "DELETE"
		case .PUT:
			request.HTTPMethod = "PUT"
			request.addValue("application/json", forHTTPHeaderField: "Accept")
			request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		}

		if (jsonBody != nil) {
			request.HTTPBody = jsonBody!.dataUsingEncoding(NSUTF8StringEncoding)!
		}

		return request
	}


	/* Helper function: Given a dictionary of parameters, convert to a string for a url */
	static func escapedParameters(parameters: [String : AnyObject]) -> String {
		var urlVars = [String]()

		for (key, value) in parameters {
			let stringValue = "\(value)"
			urlVars += [key + "=" + "\(stringValue)"]
		}

		return urlVars.joinWithSeparator("&")
	}

	// HELPER: Prints an NSData variable into console
	static func printData(data: NSData) {
		let string1 = NSString(data: data, encoding: NSUTF8StringEncoding)
		print(string1)
	}
}