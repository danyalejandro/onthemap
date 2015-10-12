//
//  ReloadableProtocol.swift
//  OnTheMap
//
//  Created by Dany Cabrera Vargas on 11/10/15.
//  Copyright © 2015 Dany Alejandro Cabrera Vargas. All rights reserved.
//

import Foundation

// common functionality for the tabbar children views
protocol ReloadableProtocol {
	func reloadLocations()
	func blockWhileLoading()
	func unblockAfterLoading()
}