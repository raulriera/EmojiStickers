//
//  CGPoint+Geometry.swift
//  EmojiStickers
//
//  Created by Raul Riera on 24/07/2016.
//  Copyright © 2016 Raul Riera. All rights reserved.
//

import UIKit

extension CGPoint {
	func insetBy(dx: CGFloat, dy: CGFloat) -> CGPoint {
		return CGPoint(x: x + dx, y: y + dy)
	}
}
