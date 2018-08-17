//
//  String+Emoji.swift
//  EmojiKit
//
//  Created by Raul Riera on 13/05/2017.
//  Copyright © 2017 Raul Riera. All rights reserved.
//

import Foundation

extension Array where Iterator.Element: Equatable {
	@discardableResult
	public mutating func remove(where condition: (Iterator.Element) -> Bool) -> Iterator.Element? {
		guard let index = index(where: condition) else { return nil }
		return remove(at: Int(index))
	}

	@discardableResult
	public mutating func removeAll(where condition: (Iterator.Element) -> Bool) -> [Iterator.Element] {
		var result: [Iterator.Element] = []

		while let index = index(where: condition) {
			result.append(remove(at: index))
		}

		return result
	}
}

extension Emoji {
	func applying(skinTone: Int) -> String {
		guard skins.isEmpty == false else { return hexcode }
		
		if skinTone != 0 {
			return skins[skinTone-1].hexcode
		} else {
			return self.hexcode
		}
	}
}
