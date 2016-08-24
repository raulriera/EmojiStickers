//
//  RecentEmojiCache.swift
//  EmojiStickers
//
//  Created by Raul Riera on 24/08/2016.
//  Copyright © 2016 Raul Riera. All rights reserved.
//

import Foundation

struct RecentEmojiCache {
	// MARK: Properties

	fileprivate static let maximumHistorySize = 100
	fileprivate static let userDefaultsKey = "recentlyUsedEmojiHistory"

	/// An array of previously used `Emoji`.
	private(set) var emojis: [String]

	// MARK: Initialization

	private init(emojis: [String]) {
		self.emojis = emojis
	}

	/// Loads previously created `Emoji`s and returns a `RecentEmojiCache` instance.
	static func load() -> RecentEmojiCache {
		var emojis = [String]()
		let defaults = UserDefaults.standard

		if let recentEmojis = defaults.object(forKey: RecentEmojiCache.userDefaultsKey) as? [String] {
			emojis = recentEmojis
		}

		return RecentEmojiCache(emojis: emojis)
	}

	/// Saves the history.
	func save() {
		// Save a maximum number of stickers.
		let emojisToSave = Array(emojis.suffix(RecentEmojiCache.maximumHistorySize))

		let defaults = UserDefaults.standard
		defaults.set(emojisToSave as Any, forKey: RecentEmojiCache.userDefaultsKey)
	}

	mutating func append(_ emoji: String) {
		/*
		Filter any existing instances of the new emoji from the current
		history before adding it to the end of the history.
		*/
		var newEmojis = self.emojis.filter { $0 != emoji }
		newEmojis.append(emoji)

		emojis = newEmojis

		save()
	}
}
