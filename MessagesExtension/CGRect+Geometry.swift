//
//  CGRect+Geometry.swift
//  EmojiStickers
//
//  Created by Raul Riera on 24/07/2016.
//  Copyright © 2016 Raul Riera. All rights reserved.
//

import UIKit

extension CGRect {
	/// CGPoint of all the corners of the view, ordered as top left, bottom left, bottom right, top right
	///
	/// - returns: Array of CGPoint
	func corners() -> [CGPoint] {
		return [CGPoint(x: minX, y: minY),
		        CGPoint(x: minX, y: maxY),
		        CGPoint(x: maxX, y: maxY),
		        CGPoint(x: maxX, y: minY)]
	}
}
