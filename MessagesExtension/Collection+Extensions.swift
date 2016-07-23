//
//  Collection+Extensions.swift
//  EmojiStickers
//
//  Created by Raul Riera on 24/07/2016.
//  Copyright © 2016 Raul Riera. All rights reserved.
//

import Foundation

extension MutableCollection where Index == Int {
	/// Shuffle the elements of `self` in-place.
	mutating func shuffle() {
		// empty and single-element collections don't shuffle
		if count < 2 { return }

		for i in startIndex ..< endIndex - 1 {
			let j = Int(arc4random_uniform(UInt32(endIndex - i))) + i
			guard i != j else { continue }
			swap(&self[i], &self[j])
		}
	}
}

extension Collection {
	/// Return a copy of `self` with its elements shuffled
	func shuffled() -> [Iterator.Element] {
		var list = Array(self)
		list.shuffle()
		return list
	}
}

