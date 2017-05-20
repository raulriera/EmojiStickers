//
//  SkinToneCache.swift
//  EmojiStickers
//
//  Created by Raul Riera on 20/07/2016.
//  Copyright © 2016 Raul Riera. All rights reserved.
//

import Foundation

struct SkinToneCache {
	// MARK: Properties
	
	private static let userDefaultsKey = "skinToneHistory"
	private(set) var tone: String
	
	// MARK: Initialization
	
	/**
	`SkinToneCache`'s initializer is marked as private. Instead instances should
	be loaded via the `load` method.
	*/
	private init(tone: String) {
		self.tone = tone
	}
	
	/// Loads previously created `Emoji`s and returns a `EmojiHistory` instance.
	static func load() -> SkinToneCache {
		var tone = ""
		let defaults = UserDefaults.standard
		
		if let previousTone = defaults.string(forKey: SkinToneCache.userDefaultsKey) {
			tone = previousTone
		}
		
		return SkinToneCache(tone: tone)
	}

	/// Deletes all the history
	func clear() {
		UserDefaults.standard.set("", forKey: SkinToneCache.userDefaultsKey)
	}
	
	/// Saves the history.
	func save(tone: String) {
		let defaults = UserDefaults.standard
		defaults.set(tone, forKey: SkinToneCache.userDefaultsKey)
	}
}
