//
//  CAKeyframeAnimation+Extensions.swift
//  EmojiStickers
//
//  Created by Raul Riera on 28/07/2016.
//  Copyright © 2016 Raul Riera. All rights reserved.
//

import UIKit

extension CAKeyframeAnimation {
	static func jiggle() -> [CAKeyframeAnimation] {
		func positionAnimation() -> CAKeyframeAnimation {
			let animation = CAKeyframeAnimation(keyPath: "position")
			animation.beginTime = 0.8
			animation.duration = 0.25
			animation.values = [
				NSValue(cgPoint: CGPoint(x: -1, y: -1)),
				NSValue(cgPoint: CGPoint(x: 0, y: 0)),
				NSValue(cgPoint: CGPoint(x: 0, y: -1)),
				NSValue(cgPoint: CGPoint(x: -1, y: -1))
			]
			animation.calculationMode = "linear"
			animation.isRemovedOnCompletion = false
			animation.repeatCount = Float.greatestFiniteMagnitude
			animation.beginTime = Double(arc4random() % 25) / 100.0
			animation.isAdditive = true

			return animation
		}

		func transformAnimation() -> CAKeyframeAnimation {
			let animation = CAKeyframeAnimation(keyPath: "transform")
			animation.beginTime = 2.6
			animation.duration = 0.25
			animation.valueFunction = CAValueFunction(name:kCAValueFunctionRotateZ)
			animation.values = [
				-0.03525565,
				0.03525565,
				-0.03525565
			]
			animation.calculationMode = "linear"
			animation.isRemovedOnCompletion = false
			animation.repeatCount = Float.greatestFiniteMagnitude
			animation.beginTime = Double(arc4random() % 25) / 100.0
			animation.isAdditive = true
			
			return animation
		}

		return [positionAnimation(), transformAnimation()]
	}
}
