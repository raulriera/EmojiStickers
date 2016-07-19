//
//  UIView+Geometry.swift
//  EmojiStickers
//
//  Created by Raul Riera on 23/06/2016.
//  Copyright © 2016 Raul Riera. All rights reserved.
//

import UIKit

extension UIView {
	func subviewsUnion() -> CGRect {
		guard subviews.isEmpty == false else { fatalError("This view has no subviews") }
		
		var unionRect = subviews.first!.frame
		
		subviews.forEach() {
			unionRect = unionRect.union($0.frame)
		}
		
		return unionRect
	}
}
