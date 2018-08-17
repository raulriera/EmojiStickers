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
	private(set) var emojis: [Emoji]

	// MARK: Initialization

	private init(emojis: [Emoji]) {
		self.emojis = emojis
	}

	/// Loads previously created `Emoji`s and returns a `RecentEmojiCache` instance.
	static func load() -> RecentEmojiCache {
		var emojis: [Emoji] = []
		
		if let data = UserDefaults.standard.value(forKey: RecentEmojiCache.userDefaultsKey) as? Data, let decoded = try? PropertyListDecoder().decode([Emoji].self, from: data) {
			emojis = decoded
		}

		return RecentEmojiCache(emojis: emojis)
	}

	/// Saves the history.
	func save() {
		// Save a maximum number of stickers.
		let emojisToSave = Array(emojis.suffix(RecentEmojiCache.maximumHistorySize))
		UserDefaults.standard.set(try? PropertyListEncoder().encode(emojisToSave), forKey: RecentEmojiCache.userDefaultsKey)
	}

	/// Deletes all the history
	func clear() {
		UserDefaults.standard.set([], forKey: RecentEmojiCache.userDefaultsKey)
	}

	mutating func append(_ emoji: Emoji) {
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
