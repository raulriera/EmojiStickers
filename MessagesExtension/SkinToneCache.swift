//
//  SkinToneCache.swift
//  EmojiStickers
//
//  Created by Raul Riera on 20/07/2016.
//  Copyright © 2016 Raul Riera. All rights reserved.
//

import Foundation

struct SkinToneCache {
	private static let userDefaultsKey = "skinToneHistory"
	private(set) var tone: Int
	
	// MARK: Initialization
	
	/**
	`SkinToneCache`'s initializer is marked as private. Instead instances should
	be loaded via the `load` method.
	*/
	private init(tone: Int) {
		self.tone = tone
	}
	
	/// Loads previously created `Emoji`s and returns a `EmojiHistory` instance.
	static func load() -> SkinToneCache {
		let tone = UserDefaults.standard.integer(forKey: SkinToneCache.userDefaultsKey)
		return SkinToneCache(tone: tone)
	}

	/// Deletes all the history
	func clear() {
		UserDefaults.standard.set("", forKey: SkinToneCache.userDefaultsKey)
	}
	
	/// Saves the history.
	func save(tone: Int) {
		let defaults = UserDefaults.standard
		defaults.set(tone, forKey: SkinToneCache.userDefaultsKey)
	}
}
