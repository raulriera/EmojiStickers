//
//  CGRect+Geometry.swift
//  MessagesExtension
//
//  Created by Raul Riera on 2020-06-14.
//  Copyright © 2020 Raul Riera. All rights reserved.
//

import UIKit

extension CGRect {
	init(startPoint: CGPoint, endPoint: CGPoint) {
		self = CGRect(x: min(startPoint.x, endPoint.x),
					  y: min(startPoint.y, endPoint.y),
					  width: abs(startPoint.x - endPoint.x),
					  height: abs(startPoint.y - endPoint.y))
	}
}
