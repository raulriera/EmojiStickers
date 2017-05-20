//
//  EmojiCategoryOffsetCache.swift
//  EmojiStickers
//
//  Created by Raul Riera on 27/08/2016.
//  Copyright © 2016 Raul Riera. All rights reserved.
//

import UIKit

struct EmojiCategoryOffsetCache {
	// MARK: Properties

	private static let userDefaultsKey = "emojiCategoryOffsetCache"
	private(set) var offset: CGPoint

	// MARK: Initialization

	private init(offset: CGPoint) {
		self.offset = offset
	}

	static func load() -> EmojiCategoryOffsetCache {
		var offset = CGPoint.zero
		let defaults = UserDefaults.standard

		if let previousTone = defaults.string(forKey: EmojiCategoryOffsetCache.userDefaultsKey) {
			offset = CGPointFromString(previousTone)
		}

		return EmojiCategoryOffsetCache(offset: offset)
	}

	/// Saves the history.
	func save(offset: CGPoint) {
		let defaults = UserDefaults.standard
		defaults.set(NSStringFromCGPoint(offset), forKey: EmojiCategoryOffsetCache.userDefaultsKey)
	}

	/// Deletes all the history
	func clear() {
		UserDefaults.standard.set(nil, forKey: EmojiCategoryOffsetCache.userDefaultsKey)
	}
}
