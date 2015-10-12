//
//  LoadingOverlay.swift
//  OnTheMap
//
//  Created by Dany Cabrera Vargas on 11/10/15.
//  Copyright © 2015 Dany Alejandro Cabrera Vargas. All rights reserved.
//

import Foundation
import UIKit

public class LoadingOverlay {

	var overlayView = UIView()
	var activityIndicator = UIActivityIndicatorView()

	static let shared: LoadingOverlay = LoadingOverlay() // Singleton pattern

	private init() {
		overlayView.frame = CGRectMake(0, 0, 80, 80)
		overlayView.backgroundColor = UIColor(white: 0.3, alpha: 0.7)
		overlayView.clipsToBounds = true
		overlayView.layer.cornerRadius = 10

		activityIndicator.frame = CGRectMake(0, 0, 40, 40)
		activityIndicator.activityIndicatorViewStyle = .WhiteLarge
		activityIndicator.center = CGPointMake(overlayView.bounds.width / 2, overlayView.bounds.height / 2)

		overlayView.addSubview(activityIndicator)
	}

	public func showOverlay(view: UIView) {
		overlayView.center = view.center
		view.addSubview(overlayView)
		activityIndicator.startAnimating()
	}

	public func hideOverlay() {
		activityIndicator.stopAnimating()
		overlayView.removeFromSuperview()
	}
}